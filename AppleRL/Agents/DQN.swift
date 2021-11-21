//
//  DQN.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 02/11/21.
//

import CoreML


public class DeepQNetwork<S, A, R: BinaryInteger> {
    // S: type of sensors
    // A: type of actions
    // R: type of reward
    // the <S, A, R> types are inherited by the Environment
        
    public var buffer: ExperienceReplayBuffer<S, A, R>
    private typealias SarsaTuple = SarsaTupleGeneric<S, A, R>
    
    let environment: Env<S, A, R>
    
    var timerListen : Timer? = nil {
            willSet {
                timerListen?.invalidate()
            }
        }
    
    var timerTrain : Timer? = nil {
            willSet {
                timerTrain?.invalidate()
            }
        }
    
    var learningRate: Double
    var epochs: Double
    var epsilon: Double
    var gamma: Double
    
    // MARK: - Private Type Properties
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
    
    private var targetModel: AppleRLModel {
        do {
            return try AppleRLModel(configuration: .init())
        } catch {
            fatalError("Couldn't load AppleRLModel due to: \(error.localizedDescription)")
        }
    }

    // The Model model currently in use.
    private var liveModel: AppleRLModel {
        updatedModel ?? defaultModel
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
            
    }
    
    func store(state: MLMultiArray, action: A, reward: R, nextState: MLMultiArray) {
        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
        buffer.addData(tuple)
    }
    
    func epsilonGreedy(state: MLMultiArray) -> A {
        if Double.random(in: 0..<1) < epsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<self.environment.get_action_size()+1)
            print("Epsilon Choice \(choice)")
            return choice as! A
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value
            let stateTarget = liveModel.predictFor(stateValue)
//            print("PredictFor ACT")
//            print(stateTarget!.actions)
            print("Model Choice " + String(convertToArray(from: stateTarget!.actions).argmax()!))
            return convertToArray(from: stateTarget!.actions).argmax() as! A
        }
    }
    
    public func act(state: MLMultiArray) -> A {
        
        return epsilonGreedy(state: state)
    }
    
    func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
        
        // Init our output array
        var array: [Double] = []
        
        // Get length
        let length = mlMultiArray.count
        
        // Set content of multi array to our out put array
        for i in 0...length - 1 {
            array.append(Double(truncating: mlMultiArray[i]))
        }
        
        return array
    }
    
    func convertToMLMultiArrayFloat(from singleArray: [S]) -> MLMultiArray{
        var featureMultiArray: MLMultiArray
        do {
            featureMultiArray = try MLMultiArray(shape: [NSNumber(value: singleArray.count)], dataType: MLMultiArrayDataType.float)
            for index in 0..<singleArray.count {
                featureMultiArray[index] = NSNumber(value: singleArray[index] as! Float)
            }
        } catch {
            fatalError("Error converting in MLMultiArrayFloat")
        }
        return featureMultiArray
    }
    
    private func createUpdateFeatures() -> MLArrayBatchProvider {
        // firstly we need to create and update the target
        
        // get the tuples
        let data = buffer.batchProvider
        var target: MLFeatureValue
        var featureProviders = [MLFeatureProvider]()
        let inputName = "data"
        let outputName = "actions_true"
        print("START creating batch")
        for d in data {
            print(d)
            let state = d.getState()
            let action = d.getAction()
            let reward = d.getReward()
            let nextState = d.getNextState()
            
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value
            let stateTarget = liveModel.predictFor(stateValue)!.actions
            print("PredictFor Update livemodel \(stateTarget)")
            
            let nextStateValue = MLFeatureValue(multiArray: nextState)
            
            //let nextStateValue = MLFeatureValue(int64: Int64(nextState))
            // take value for next state
            let nextStateActions = self.targetModel.predictFor(nextStateValue)!.actions
            let nextStateTarget = convertToArray(from: nextStateActions)
            print("PredictFor Update nextState TargetModel \(nextStateTarget)")
            // update the taget with the max q-value of next state
            // using a greedy policy
            stateTarget[action as! Int] = NSNumber(value: Double(reward) + self.gamma * nextStateTarget.max()!)
//            let targetValue = convertToArray(from: stateTarget)
            print("target Updated \(stateTarget)")
//            do {
//                featureMultiArray = try MLMultiArray(shape: [environment.get_action_size() as! NSNumber, 1], dataType: MLMultiArrayDataType.double)
//                for index in 0..<stateTarget.count {
//                    featureMultiArray[index] = NSNumber(value: Double(truncating: stateTarget[index]))
//                }
//            } catch {
//                print("MEGAERRORE4")
//                return MLArrayBatchProvider()
//            }
            target = MLFeatureValue(multiArray: stateTarget)
//            target = MLFeatureValue(multiArray: stateTarget)
//        }
//            print("Batch created")
//            print(target)
        
        /// Creates a batch provider of training data given the contents of `trainingData`.
        /// - Tag: DrawingBatchProvider
         

            
                 
//        for i in 0..<data.count {
//            let inputValue = data[i].getState()
//            let outputValue = target[i]

//            let a = MLFeatureValue(double: Double(inputValue))
//            let b = AppleRLModelInput(data: MLMultiArray)
            
            

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
        
//        // Update the Drawing Classifier with the drawings.
//        DispatchQueue.global(qos: .userInitiated).async {
//            ModelUpdater.updateWith(trainingData: drawingTrainingData, parameters: config) {
//                DispatchQueue.main.async { print("Trained") }
//            }
//        } REPLACED BY ->
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
            //saveUpdatedModel(updateContext)
            
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
        
//        // Update the Drawing Classifier with the drawings.
//        DispatchQueue.global(qos: .userInitiated).async {
//            ModelUpdater.updateWith(trainingData: drawingTrainingData, parameters: config) {
//                DispatchQueue.main.async { print("Trained") }
//            }
//        } REPLACED BY ->
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
            //saveUpdatedModel(updateContext)
            
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
    
    @objc public func listen() {
        let state = environment.read()
        let newState = convertToMLMultiArrayFloat(from:state)
        print(state)
        let action = self.act(state: newState)
        let (next_state, reward) = environment.act(s: state, a: action)
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
        print("Save is only allowed after an Update")
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
            print(updatedModel)
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
            return
        }
        
        // Create an instance of the updated model.
        guard let model = try? AppleRLModel(contentsOf: updatedModelURL) else {
            return
        }
        
        // Use this updated model to make predictions in the future.
        updatedModel = model
        print("Loaded Model")
    }
    
}

