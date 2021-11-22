//
//  DQN.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 02/11/21.
//

import CoreML


public class DeepQNetwork<S, A, R> {
    /// S: type of sensors
    /// A: type of actions
    /// R: type of reward
    /// The <S, A, R> types are inherited by the Environment
    
    /// Define the buffer
    public var buffer: ExperienceReplayBuffer<S, A, R>
    /// Define the SarsaTuple type
    private typealias SarsaTuple = SarsaTupleGeneric<S, A, R>
    
    /// Name of model's inputs
    let inputName = "data"
    let outputName = "actions_true"
    
    let environment: Env<S, A, R>
    
    /// Timers for ListenMode
    var timerListen : Timer? = nil { willSet { timerListen?.invalidate() }}
    var timerTrain : Timer? = nil { willSet { timerTrain?.invalidate() }}
    
    /// Training parameters
    var learningRate: Double
    var epochs: Double
    var epsilon: Double
    var gamma: Double
    var countTargetUpdate: Int = 0
    let epochsAlignTarget: Int = 10
    
    /// The updated Model model.
    private var updatedModel: AppleRLModel?
    /// The default Model model.
    private var defaultModel: AppleRLModel {
        do {
            return try AppleRLModel(configuration: .init())
        } catch {
            fatalError("Couldn't load AppleRLModel due to: \(error.localizedDescription)")
        }
    }
    
    /// Target model, a clone of the live model
    private var targetModel: AppleRLModel?
    /// The default TargetModel model.
    private var defaultTargetModel: AppleRLModel {
        do {
            return try AppleRLModel(configuration: .init())
        } catch {
            fatalError("Couldn't load AppleRLModel due to: \(error.localizedDescription)")
        }
    }

    /// The Model model currently in use.
    private var liveModel: AppleRLModel {
        updatedModel ?? defaultModel
    }
    
    /// The TargetModel model currently in use.
    private var liveTargetModel: AppleRLModel {
        targetModel ?? defaultTargetModel
    }
    
    /// The location of the app's Application Support directory for the user.
    private let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask).first!
    
    /// The default Model model's file URL.
    private let defaultModelURL = AppleRLModel.urlOfModelInThisBundle
    /// The permanent location of the updated Model model.
    private var updatedModelURL: URL
    /// The temporary location of the updated Model model.
    private var tempUpdatedModelURL: URL
    /// The permanent location of the updated Target Model model.
    private var updatedTargetModelURL: URL
    /// The temporary location of the updated Target Model model.
    private var tempUpdatedTargetModelURL: URL
    
    /// Initialize every variables
    required public init(env: Env<S, A, R>, parameters: Dictionary<String, Any>) {
        environment = env
        self.updatedModelURL = appDirectory.appendingPathComponent("personalized.mlmodelc")
        self.tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp.mlmodelc")
        self.updatedTargetModelURL = appDirectory.appendingPathComponent("personalizedTarget.mlmodelc")
        self.tempUpdatedTargetModelURL = appDirectory.appendingPathComponent("personalizedTarget_tmp.mlmodelc")
        
        self.buffer = ExperienceReplayBuffer()
        self.epsilon = (parameters["epsilon"] as? Double)!
        self.gamma = (parameters["gamma"] as? Double)!
        self.epochs = 10 //(parameters["epochs"] as? Float)!
        self.learningRate = (parameters["learning_rate"] as? Double)!
        
        loadUpdatedModel()
            
    }
    
    /// Create and store SarsaTuple into the buffer
    func store(state: MLMultiArray, action: A, reward: R, nextState: MLMultiArray) {
        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
        buffer.addData(tuple)
    }
    
    /// Epsilon Greedy policy based on class parameters
    func epsilonGreedy(state: MLMultiArray) -> A {
        if Double.random(in: 0..<1) < epsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<self.environment.getActionSize()+1)
            print("Epsilon Choice \(choice)")
            return choice as! A
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value from model
            let stateTarget = liveModel.predictFor(stateValue)
            print("Model Choice " + String(convertToArray(from: stateTarget!.actions).argmax()!))
            print("Model List \(convertToArray(from: stateTarget!.actions))")
            return convertToArray(from: stateTarget!.actions).argmax() as! A
        }
    }
    
    /// Public function to make a choice about what action do
    public func act(state: MLMultiArray) -> A {
        return epsilonGreedy(state: state)
    }
    
    /// Create the MLArrayBatchProvider used to train the MLModel
    /// It's created using the buffer data,
    private func createUpdateFeatures() -> MLArrayBatchProvider {
        // Get the SarsaTuples
        let data = buffer.batchProvider
        // Create the variable for the Target
        var target: MLFeatureValue
        // Array of MLFeatureProvider that will compose the MLArrayBatchProvider
        // It's composed by MLDictionaryFeatureProvider that contains the 'data' and the 'actions_true' as a dict
        var featureProviders = [MLFeatureProvider]()
        
        // Iter over data from buffer
        for d in data {
            print("__________\(d.getAction())___________")
            let state = d.getState()
            let action = d.getAction()
            let reward = d.getReward() as! Double
            let nextState = d.getNextState()
            
            // Create a MLFeatureValue as input for the model
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value
            let stateTarget = liveModel.predictFor(stateValue)!.actions
            print("Predict livemodel \(stateTarget)")
            
            // Create a MLFeatureValue as input for the target model
            let nextStateValue = MLFeatureValue(multiArray: nextState)
            
            // take value for next state
            let nextStateActions = self.liveTargetModel.predictFor(nextStateValue)!.actions
            let nextStateTarget = convertToArray(from: nextStateActions)
            print("Predict TargetModel \(nextStateActions)")
            // Update the taget with the max q-value of next state, using a greedy policy
            stateTarget[action as! Int] = NSNumber(value: Double(reward) + self.gamma * nextStateTarget.max()!)

            print("target Updated \(stateTarget)")
            target = MLFeatureValue(multiArray: stateTarget)
            
            // Create the final Dictionary to build the input
            let dataPointFeatures: [String: MLFeatureValue] = [inputName: stateValue,
                                                            outputName: target]

            if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
             featureProviders.append(provider)
            }
         }
         
        return MLArrayBatchProvider(array: featureProviders)
        
    }
    
    public func update() {
        
        // Convert the drawings into a batch provider as the update input.
        let trainingData = createUpdateFeatures()
        print(trainingData.array)
        
        // This is how we can change the hyperparameters before training. If you
        // don't do this, the defaults as defined in the mlmodel file are used.
        // Note that the values you choose here must match what is allowed in the
        // mlmodel file, or else Core ML throws an exception.
        let parameters: [MLParameterKey: Any] = [
            .epochs: self.epochs,
            //.seed: 1234,
            .miniBatchSize: 2,
            .learningRate: self.learningRate,
            //.shuffle: false,
        ]

        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.parameters = parameters
        
        // The URL of the currently active Model.
        let usingUpdatedModel = updatedModel != nil
        let currentModelURL = usingUpdatedModel ? updatedModelURL : defaultModelURL
        
        /// The closure an MLUpdateTask calls when it finishes updating the model.
        func updateModelCompletionHandler(updateContext: MLUpdateContext) {
            if updateContext.task.state == .failed {
                print("Failed")
                print(updateContext.task.error)
                return
              }
            // Save the updated model to the file system.
            saveUpdatedModel(updateContext)
            
            // Begin using the saved updated model.
            loadUpdatedModel()
            
            // Inform the calling View Controller when the update is complete
            DispatchQueue.main.async { print("Trained") }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: currentModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                        completionHandler: updateModelCompletionHandler)
        }
    }
    
    let progressHandler = { (context: MLUpdateContext) in
        switch context.event {
        case .trainingBegin:
            print("Training begin")

        case .miniBatchEnd:
            let batchIndex = context.metrics[.miniBatchIndex] as! Int
            let batchLoss = context.metrics[.lossValue] as! Double
//            print("Mini batch \(batchIndex), loss: \(batchLoss)")

        case .epochEnd:
            let epochIndex = context.metrics[.epochIndex] as! Int
            let trainLoss = context.metrics[.lossValue] as! Double
            print("Epoch \(epochIndex) Loss \(trainLoss)")
            
            
        default:
            print("Unknown event")
        }
    }
    
    @objc public func batchUpdate(batchSize: Int = 32) {
        
        // Convert the drawings into a batch provider as the update input.
        let trainingData = createUpdateFeatures()
        print(trainingData.array)
        
        // This is how we can change the hyperparameters before training. If you
        // don't do this, the defaults as defined in the mlmodel file are used.
        // Note that the values you choose here must match what is allowed in the
        // mlmodel file, or else Core ML throws an exception.
        let parameters: [MLParameterKey: Any] = [
            .epochs: self.epochs,
            //.seed: 1234,
            .miniBatchSize: 2,
            .learningRate: self.learningRate,
            //.shuffle: false,
        ]

        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.parameters = parameters
        
        /// The URL of the currently active Model.
        let usingUpdatedModel = updatedModel != nil
        let currentModelURL = usingUpdatedModel ? updatedModelURL : defaultModelURL
        
        /// The closure an MLUpdateTask calls when it finishes updating the model.
        func updateModelCompletionHandler(updateContext: MLUpdateContext) {
            if updateContext.task.state == .failed {
                print("Failed")
                print(updateContext.task.error)
                return
              }
            // Save the updated model to the file system.
            saveUpdatedModel(updateContext)
            
            // Begin using the saved updated model.
            loadUpdatedModel()
            
            // Inform the calling View Controller when the update is complete
            DispatchQueue.main.async { self.buffer.reset() }
        }
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: currentModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                        completionHandler: updateModelCompletionHandler)
        }
    }
    
    @objc public func listen() {
        let state = environment.read()
        let newState = convertToMLMultiArrayFloat(from:state)
        print(state)
        let action = self.act(state: newState)
        let (next_state, reward) = environment.act(state: state, action: action)
        let newNextState = convertToMLMultiArrayFloat(from:next_state)
        self.store(state: newState, action: action, reward: reward, nextState: newNextState)
    }
    
    public func startListen(interval: Int) {
        stopListen()
        guard self.timerListen == nil else { return }
        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }

    public func stopListen() {
        guard timerListen != nil else { return }
        timerListen?.invalidate()
        timerListen = nil
    }
    
    public func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.batchUpdate), userInfo: nil, repeats: true)
    }

    public func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
    
    public func save() {
        print("Save")
        fatalError("Save is only allowed after an Update")
    }
    
    public func load() {
        print("Load")
        // Read from file
        self.loadUpdatedModel()
        
    }
    
    private func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        let fileManager = FileManager.default
        do {
            // Create a directory for the updated model.
            try fileManager.createDirectory(at: tempUpdatedModelURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            print("filemanagerCreateed")
            
            // Save the updated model to temporary filename.
            try updatedModel.write(to: tempUpdatedModelURL)
            
            print("modelwritten")
            
            // Replace any previously updated model with this one.
            _ = try fileManager.replaceItemAt(updatedModelURL,
                                              withItemAt: tempUpdatedModelURL)
            
            print("Updated model saved to:\n\t\(updatedModelURL)")
        } catch let error {
            print("Could not save updated model to the file system: \(error)")
            return
        }
        print("Saved Model")
    }
    
    
    /// Loads the updated Model, if available.
    /// - Tag: LoadUpdatedModel
    private func loadUpdatedModel() {
        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
            // The updated model is not present at its designated path.
            print("The updated model is not present at its designated path.")
            return
        }
        
        // Create an instance of the updated model.
        guard let model = try? AppleRLModel(contentsOf: updatedModelURL) else {
            print("Error loading the Model")
            return
        }
        
        // Use this updated model to make predictions in the future.
        updatedModel = model
        print("Model Loaded")
        
        // Align target model after epochsAlignTarget updates
        if self.countTargetUpdate >= self.epochsAlignTarget {
            targetModel = model
            self.countTargetUpdate = 0
            print("Target model updated")
        }
        self.countTargetUpdate += 1
        
    }
    
}

// train test
//[0.09120198339223862,0.03973470628261566,0.01435149274766445,-0.02724559232592583,0.02169860899448395] .first
//
//[0.04767553508281708,0.1081157997250557,-0.004447195213288069,-0.103394590318203,0.0506153479218483]
//
//[0.05088436603546143,0.05092423409223557,0.03019963018596172,-0.5132191777229309,-0.04031703621149063]
//
//[0.03314311802387238,0.03358393907546997,0.02671210467815399,-0.9411672949790955,-0.3377813994884491] after 5/6 training iT CHANGEs!! IT TRAINs!

// a bit different on the next run after reload the app but it's ok
//[0.03375066816806793,0.03317856043577194,0.02958793565630913,-0.9496716260910034,-0.4104157686233521]

// loadModel test done correctly, save and reload after reload the app works
//Model List [0.04388461634516716, 0.035614483058452606, 0.0495888814330101, -0.9496716260910034, -0.5101786851882935]
//Model List [0.04388461634516716, 0.035614483058452606, 0.0495888814330101, -0.9496716260910034, -0.5101786851882935]
//
//Model List [0.04121972993016243, 0.048581261187791824, 0.04852025955915451, -0.9568986296653748, -0.5867434144020081]
//Model List [0.04121972993016243, 0.048581261187791824, 0.04852025955915451, -0.9568986296653748, -0.5867434144020081]
