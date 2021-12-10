//
//  DQN.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 02/11/21.
//

import CoreML
import BackgroundTasks


open class DeepQNetwork {
    /// Define the buffer
    open var buffer: ExperienceReplayBuffer
    /// Define the SarsaTuple type
    private typealias SarsaTuple = SarsaTupleGeneric
    
    /// Name of model's inputs
    let inputName = "data"
    let outputName = "actions_true"
    
    let environment: Env
    let fileManager = FileManager.default
    
    /// Timers for ListenMode
    var timerListen : Timer? = nil { willSet { timerListen?.invalidate() }}
    var timerTrain : Timer? = nil { willSet { timerTrain?.invalidate() }}
    
    /// Training parameters
    var learningRate: Double
    var epochs: Double
    var epsilon: Double
    var gamma: Double
    var timeIntervalBackgroundMode: Double
    var timeIntervalTrainingBackgroundMode: Double
    var miniBatchSize: Int = 8
    
    var countTargetUpdate: Int = 0
    let epochsAlignTarget: Int = 10
    
    /// A Boolean that indicates whether the instance has all the required data: 2 times the minibatch size
    var isReadyForTraining: Bool { buffer.count >= miniBatchSize * 2 }
    
    
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
    
    /// Initialize every variables
    required public init(env: Env, parameters: Dictionary<String, Any>) {
        environment = env
        self.updatedModelURL = appDirectory.appendingPathComponent("personalized.mlmodelc")
        self.tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp.mlmodelc")
        self.updatedTargetModelURL = appDirectory.appendingPathComponent("personalizedTarget.mlmodelc")
        
        self.buffer = ExperienceReplayBuffer()
        self.epsilon = (parameters["epsilon"] as? Double)!
        self.gamma = (parameters["gamma"] as? Double)!
        self.epochs = 10 //(parameters["epochs"] as? Float)!
        self.learningRate = (parameters["learning_rate"] as? Double)!
        self.timeIntervalTrainingBackgroundMode = Double(20*60)
        if let val = parameters["timeIntervalBackgroundMode"] {
            self.timeIntervalBackgroundMode = val as! Double
        } else {
            self.timeIntervalBackgroundMode = Double(1*60)
        }
        defaultLogger.log("DQN Initialized")
        loadUpdatedModel()
            
    }
    
    /// Create and store SarsaTuple into the buffer
    open func store(state: MLMultiArray, action: Int, reward: Double, nextState: MLMultiArray) {
        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
        buffer.addData(tuple)
    }
    
    /// Create and store SarsaTuple into the buffer and delete from database
    open func storeAndDelete(id: Int, state: MLMultiArray, action: Int, reward: Double, nextState: MLMultiArray) {
        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
        buffer.addData(tuple)
        deleteFromDataset(id: id, path: databasePath)
    }
    
    /// Epsilon Greedy policy based on class parameters
    func epsilonGreedy(state: MLMultiArray) -> Int {
        if Double.random(in: 0..<1) < epsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<self.environment.getActionSize())
            defaultLogger.log("Epsilon Choice \(choice)")
            return choice
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value from model
            defaultLogger.log("State Value \(convertToArray(from: state))")
            let stateTarget = liveModel.predictFor(stateValue)
            var k = stateTarget!.actions
            defaultLogger.log("Model Choice \(convertToArray(from: stateTarget!.actions).argmax()!)")
            defaultLogger.log("Model List \(convertToArray(from: stateTarget!.actions))")
            return convertToArray(from: stateTarget!.actions).argmax()!
        }
    }
    
    /// open function to make a choice about what action do
    open func act(state: MLMultiArray) -> Int {
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
            defaultLogger.log("__________\(d.getAction())___________")
            defaultLogger.log("__________\(d.getState())___________")
            let state = d.getState()
            let action = d.getAction()
            let reward = d.getReward()
            let nextState = d.getNextState()
            
            // Create a MLFeatureValue as input for the model
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value
            let stateTarget = liveModel.predictFor(stateValue)!.actions
            defaultLogger.log("Predict livemodel \(stateTarget)")
            
            // Create a MLFeatureValue as input for the target model
            let nextStateValue = MLFeatureValue(multiArray: nextState)
            
            // take value for next state
            let nextStateActions = self.liveTargetModel.predictFor(nextStateValue)!.actions
            let nextStateTarget = convertToArray(from: nextStateActions)
            defaultLogger.log("Predict TargetModel \(nextStateActions)")
            // Update the taget with the max q-value of next state, using a greedy policy
            stateTarget[action] = NSNumber(value: Double(reward) + self.gamma * nextStateTarget.max()!)

            defaultLogger.log("target Updated \(stateTarget)")
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
    
    open func update() {
        
        // Convert the drawings into a batch provider as the update input.
        let trainingData = createUpdateFeatures()
        defaultLogger.log("\(trainingData.array)")
        if trainingData.count == 0 {
            defaultLogger.info("Training not started caused by no data in buffer")
            return
        }
        
        if !self.isReadyForTraining {
            defaultLogger.info("Training not started caused by too little data in buffer")
            return
        }
        
        // This is how we can change the hyperparameters before training. If you
        // don't do this, the defaults as defined in the mlmodel file are used.
        // Note that the values you choose here must match what is allowed in the
        // mlmodel file, or else Core ML throws an exception.
        let parameters: [MLParameterKey: Any] = [
            .epochs: self.epochs,
            //.seed: 1234,
            .miniBatchSize: self.miniBatchSize,
            .learningRate: self.learningRate,
            //.shuffle: false,
        ]

        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.parameters = parameters
        
        // The URL of the currently active Model.
        let usingUpdatedModel = updatedModel != nil
        let currentModelURL = usingUpdatedModel ? updatedModelURL : defaultModelURL
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: currentModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                     completionHandler: self.updateModelCompletionHandler)
        }
    }
    
    /// The closure an MLUpdateTask calls when it finishes updating the model.
    func updateModelCompletionHandler(updateContext: MLUpdateContext) {
        if updateContext.task.state == .failed {
            defaultLogger.log("Failed")
            defaultLogger.log("\(updateContext.task.error!.localizedDescription)")
            return
          }
        // Save the updated model to the file system.
        saveUpdatedModel(updateContext)

        // Begin using the saved updated model.
        loadUpdatedModel()
        
        // reset the buffer only after the model trained for sure
        buffer.reset()

        // Inform the calling View Controller when the update is complete
        DispatchQueue.main.async { defaultLogger.log("Trained") }
    }
    
    let progressHandler = { (context: MLUpdateContext) in
        switch context.event {
        case .trainingBegin:
            defaultLogger.info("Training begin")

        case .miniBatchEnd:
            let batchIndex = context.metrics[.miniBatchIndex] as! Int
//            let batchLoss = context.metrics[.lossValue] as! Double
//            defaultLogger.log("Mini batch \(batchIndex), loss: \(batchLoss)")

        case .epochEnd:
            let epochIndex = context.metrics[.epochIndex] as! Int
            let trainLoss = context.metrics[.lossValue] as! Double
            defaultLogger.info("Epoch \(epochIndex) Loss \(trainLoss)")
            
            
        default:
            defaultLogger.log("Unknown event")
        }
    }
    
    @objc open func batchUpdate(batchSize: Int = 32) {
        
        // Convert the drawings into a batch provider as the update input.
        let trainingData = createUpdateFeatures()
//        defaultLogger.log(trainingData.array)
        
        if trainingData.count == 0 {
            defaultLogger.info("Training not started, caused by no data in buffer")
            return
        }
        
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: currentModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                     completionHandler: self.updateModelCompletionHandler)
        }
    }
    
    @objc open func listen() {
        let state = environment.read()
        let newState = convertToMLMultiArrayFloat(from:state)
        defaultLogger.log("Listen: \(state)")
        let action = self.act(state: newState)
        environment.act(state: state, action: action)
        // in-App use means the user needs to give a reward using the app and only then the SarsaTuple is saved and used for training
        // here the online-use
//        let newNextState = convertToMLMultiArrayFloat(from:next_state)
//        self.store(state: newState, action: action, reward: reward, nextState: newNextState)
    }
    
    open func startListen(interval: Int) {
        stopListen()
        guard self.timerListen == nil else { return }
        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }
    
    open func stopListen() {
        guard timerListen != nil else { return }
        timerListen?.invalidate()
        timerListen = nil
    }
    
    open func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.batchUpdate), userInfo: nil, repeats: true)
    }

    open func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
    
    open func save() {
        defaultLogger.log("Save")
        fatalError("Save is only allowed after an Update")
    }
    
    open func load() {
        defaultLogger.log("Load")
        // Read from file
        self.loadUpdatedModel()
        
    }
    
    private func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        do {
            // Create a directory for the updated model.
            try fileManager.createDirectory(at: tempUpdatedModelURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            defaultLogger.log("filemanagerCreateed")
            
            // Save the updated model to temporary filename.
            try updatedModel.write(to: tempUpdatedModelURL)
            
            defaultLogger.log("modelwritten")
            
            // Replace any previously updated model with this one.
            _ = try fileManager.replaceItemAt(updatedModelURL,
                                              withItemAt: tempUpdatedModelURL)
            
            defaultLogger.log("Updated model saved to:\n\t\(self.updatedModelURL)")
        } catch let error {
            defaultLogger.error("Could not save updated model to the file system: \(error.localizedDescription)")
            return
        }
        defaultLogger.log("Saved Model")
    }
    
    
    /// Loads the updated Model, if available.
    /// - Tag: LoadUpdatedModel
    private func loadUpdatedModel() {
        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
            // The updated model is not present at its designated path.
            defaultLogger.info("The updated model is not present at its designated path.")
            return
        }
        
        // Create an instance of the updated model.
        guard let model = try? AppleRLModel(contentsOf: updatedModelURL) else {
            defaultLogger.error("Error loading the Model")
            return
        }
        
        // Use this updated model to make predictions in the future.
        updatedModel = model
        defaultLogger.log("Model Loaded")
        
        // Align target model after epochsAlignTarget updates
        if self.countTargetUpdate >= self.epochsAlignTarget {
            targetModel = model
            do {
                // Save the updated model to temporary filename.
            
                // Replace any previously updated model with this one.
                _ = try fileManager.replaceItemAt(updatedTargetModelURL,
                                                  withItemAt: updatedModelURL)
            } catch {
                defaultLogger.error("Target model not saved")
            }
            self.countTargetUpdate = 0
            defaultLogger.log("Target model updated")
        }
        self.countTargetUpdate += 1
        
    }
    
    public func handleAppRefreshTask(task: BGAppRefreshTask) {
        defaultLogger.log("Handling Listen ask")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
      
      
//    NotificationCenter.default.post(name: .newPokemonFetched,
//                                    object: self,
//                                    userInfo: ["pokemon": pokemon])
        self.listen()
        task.setTaskCompleted(success: true)
      
        scheduleBackgroundSensorFetch()
    }

    public func scheduleBackgroundSensorFetch() {
        defaultLogger.log("Background fetch activate")
        let sensorFetchTask = BGAppRefreshTaskRequest(identifier: "com.pavesialessandro.applerl.backgroundListen")
        sensorFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: self.timeIntervalBackgroundMode) // launch at least every x minutes
        do {
            try BGTaskScheduler.shared.submit(sensorFetchTask)
            defaultLogger.log("task scheduled")
        } catch {
            defaultLogger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    public func handleTrainingTask(task: BGProcessingTask) {
        defaultLogger.log("Handling Training task")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        self.update()
        task.setTaskCompleted(success: true)
      
      
        scheduleBackgroundTrainingFetch()
    }

    public func scheduleBackgroundTrainingFetch() {
        defaultLogger.log("backgroundmode training activate")
        
        let request = BGProcessingTaskRequest(identifier: "com.pavesialessandro.applerl.backgroundTrain")
//        request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
        request.requiresExternalPower = true // Need to true if your task requires a device connected to power source. Defaults to false.

        request.earliestBeginDate = Date(timeIntervalSinceNow: self.timeIntervalTrainingBackgroundMode) // Process after x minutes.

        do {
            try BGTaskScheduler.shared.submit(request)
            defaultLogger.log("training task scheduled")
        } catch {
            defaultLogger.error("Unable to submit task: \(error.localizedDescription)")
        }
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


// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.pavesialessandro.applerl.backgroundListen"]
