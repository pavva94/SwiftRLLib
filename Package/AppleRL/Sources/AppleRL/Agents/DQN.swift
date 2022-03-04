//
//  DQN.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 02/11/21.
//

import CoreML
import BackgroundTasks
import MetricKit


open class DeepQNetwork: Agent {
    /// Define the buffer
    open var buffer: ExperienceReplayBuffer = ExperienceReplayBuffer()
    /// Define the SarsaTuple type
    typealias SarsaTuple = SarsaTupleGeneric
    
    /// Name of model's inputs
    let inputName = modelInputName
    let outputName = modelOutputName
    
    var environment: Env
    var policy: Policy
    /// Function to define the end of the episode
    private var episodeEnd: (() -> Bool)
    
    /// Training parameters
    var learningRate: [Double] = [0.0001]
    var learningRateDecayMode: Bool = false
    var trainingCounter: Int = 0
//    var secondsObserveProcess: Int
//    var secondsTrainProcess: Int
    var epochs: Int = 10
    var gamma: Double = 0.9
    var miniBatchSize: Int = 32
    var trainingSetSize: Int = 256
    
    var countTargetUpdate: Int = 0
    let epochsAlignTarget: Int = 10
    
    /// A Boolean that indicates whether the instance has all the required data:  the minibatch size
    var isReadyForTraining: Bool { buffer.count >= trainingSetSize }
    
    /// The updated Model model.
    var updatedModel: AppleRLModel?
   
    /// Target model, a clone of the live model
    var targetModel: AppleRLModel?
    
    /// The location of the app's Application Support directory for the user.
    private let appDirectory = FileManager.default.urls(for: .documentDirectory,
                                                               in: .userDomainMask).first!
    
    /// The default Model model's file URL.
    let defaultModelURL = AppleRLModel.urlOfModelInThisBundle
    /// The permanent location of the updated Model model.
    var updatedModelURL: URL = URL(fileURLWithPath: "")
    /// The temporary location of the updated Model model.
    var tempUpdatedModelURL: URL = URL(fileURLWithPath: "")
    /// The permanent location of the updated Target Model model.
    var updatedTargetModelURL: URL = URL(fileURLWithPath: "")
    
    /// Initialize every variables
    required public init(env: Env, policy: Policy, parameters: Dictionary<ModelParameters, Any>) {
        self.environment = env
        self.policy = policy
        super.init()
    
        // General parameter
        self.modelID = parameters.keys.contains(.agentID) ? (parameters[.agentID] as? Int)! : self.modelID
        self.bufferPath = parameters.keys.contains(.bufferPath) ? (parameters[.bufferPath] as? String)! : self.bufferPath + String(self.modelID) + dataManagerFileExtension
        self.databasePath = parameters.keys.contains(.databasePath) ? (parameters[.databasePath] as? String)! : self.databasePath + String(self.modelID) + dataManagerFileExtension
        self.trainingSetSize = parameters.keys.contains(.trainingSetSize) ? (parameters[.trainingSetSize] as? Int)! : self.trainingSetSize
        self.buffer = ExperienceReplayBuffer(self.trainingSetSize, bufferPath: self.bufferPath, databasePath: self.databasePath)
        
        // Model parameter
        self.gamma = parameters.keys.contains(.gamma) ? (parameters[.gamma] as? Double)! : self.gamma
        self.epochs = parameters.keys.contains(.epochs) ? (parameters[.epochs] as? Int)! : self.epochs
        self.trainingCounter = self.defaults.integer(forKey: "trainingCounter" + String(self.modelID))
        self.miniBatchSize = parameters.keys.contains(.batchSize) ? (parameters[.batchSize] as? Int)! : self.miniBatchSize
        self.secondsTrainProcess = parameters.keys.contains(.secondsTrainProcess) ? (parameters[.secondsTrainProcess] as? Int)! : 2*60*60 // 2 ore
        self.secondsObserveProcess = parameters.keys.contains(.secondsObserveProcess) ? (parameters[.secondsObserveProcess] as? Int)! : 10*60 // 10 minuti
        self.episodeEnd = parameters.keys.contains(.episodeEnd) ? (parameters[.episodeEnd] as? (() -> Bool))! : { return false }

        // allows the possibility to use a variable learning rate
        if type(of: parameters[.learning_rate]) == Double.self {
            self.learningRate = [(parameters[.learning_rate] as? Double)!]
            self.learningRateDecayMode = false
        } else if type(of: parameters[.learning_rate]) == [Double].self {
            self.learningRate = (parameters[.learning_rate] as? [Double])!
            self.learningRateDecayMode = true
        }
        
        /// The permanent location of the updated Model model.
        self.updatedModelURL = appDirectory.appendingPathComponent(personalizedModelFileName + String(self.modelID) + modelFileExtension)
        /// The temporary location of the updated Model model.
        self.tempUpdatedModelURL = appDirectory.appendingPathComponent(tempModelFileName + String(self.modelID) + modelFileExtension)
        /// The permanent location of the updated Target Model model.
        self.updatedTargetModelURL = appDirectory.appendingPathComponent(personalizedTargetModelFileName + String(self.modelID) + modelFileExtension)
        
        
//        if parameters.keys.contains(.secondsTrainProcess) {
//            self.secondsTrainProcess = parameters[.secondsTrainProcess] as! Int
//        } else {
//            self.secondsTrainProcess = 2*60*60
//        }
        
//        if parameters.keys.contains(.secondsObserveProcess) {
//            self.secondsObserveProcess = parameters[.secondsObserveProcess] as! Int
//        } else {
//            self.secondsObserveProcess = 10*60 // 10 minuti
//        }
        defaultLogger.log("DQN Initialized")
        loadUpdatedModel()
            
    }
    
    /// Return the default model URL, used at the early stages after the first installation
    open func getDeafultModelURL() -> URL {
        return defaultModelURL
    }
    
    // Return the model URL, used after the early stages when the app has already trained the network
    open func getModelURL() -> URL {
        return updatedModelURL
    }
    
    // Return the target model URL
    open func getTargetModelURL() -> URL {
        return updatedTargetModelURL
    }
    
    /// Create and store SarsaTuple into the buffer
    open func store(state: MLMultiArray, action: Int, reward: Double, nextState: MLMultiArray) {
        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
        buffer.addData(tuple)
    }
    
    /// open function to make a choice about what action do
    open func act(state: MLMultiArray, greedy: Bool = false) -> Int {
        do {
            let model = try AppleRLModel(contentsOf: updatedModelURL).model
            return self.policy.exec(model: model, state: state)
        } catch {
            defaultLogger.error("\(error.localizedDescription)")
            fatalError()
        }
    }
    
    open override func save() {
        defaultLogger.log("Save")
        fatalError("Save is only allowed after an Update")
    }
    
    open override func load() {
        defaultLogger.log("Load")
        // Read from file
        self.loadUpdatedModel()
        
    }
    
    @objc open override func listen() {
        // read new state and do things like act
        let state = self.environment.read()
        
        // check if state is terminal
        if state == [] {
            do {
                defaultLogger.log("Terminal State reached")
                let newState = try MLMultiArray([Double]())
                let reward = self.environment.reward(state: convertToArray(from: self.buffer.lastData.getState()), action: self.buffer.lastData.getAction(), nextState: state)
                self.store(state: self.buffer.lastData.getState(), action: self.buffer.lastData.getAction(), reward: reward, nextState: newState)
                // wait the overriding of last tuple to save current tuple
                self.buffer.isEmpty = true
                return
            } catch {
                defaultLogger.error("Error saving terminal state: \(error.localizedDescription)")
                return
            }
        }
        
        let newState = convertToMLMultiArrayFloat(from:state)
        defaultLogger.log("Listen State: \(state)")
        let action = self.act(state: newState)
        self.environment.act(state: state, action: action)

        
        defaultLogger.log("Buffer count \(self.buffer.count)")
        // then we are done with the current tuple we can take care of finish the last one
        if !self.buffer.isEmpty {
            defaultLogger.log("Listen Old State: \(self.buffer.lastData.getState())")
            // retrieve the reward based on the old state, the current state and the action done in between
            let reward = self.environment.reward(state: convertToArray(from: self.buffer.lastData.getState()), action: self.buffer.lastData.getAction(), nextState: state)
            
            self.store(state: self.buffer.lastData.getState(), action: self.buffer.lastData.getAction(), reward: reward, nextState: newState)
        }
        
        // wait the overriding of last tuple to save current tuple
        self.buffer.setLastData(SarsaTuple(state: newState, action: action, reward: 0.0))
        
        // add metrics
        let listenLogHandle = MXMetricManager.makeLogHandle(category: "Listen")
        mxSignpost(
          .event,
          log: listenLogHandle,
          name: "Listen")
    }
    
    // Batch update used by the Timer mode (that needs the function to be @objc)
    /// Calls the updateModel on the AppleRLModel with data from createUpdateFeatures() and parameter from Env
    @objc open override func update() {
        
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
            .seed: 42,
            .miniBatchSize: self.miniBatchSize,
            .learningRate: self.learningRateDecayMode ? self.learningRate[
                        self.trainingCounter<self.learningRate.count ? self.trainingCounter: self.learningRate.count-1
                    ] : self.learningRate[0],
            .shuffle: true,
        ]

        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.parameters = parameters
        defaultLogger.log("currentModelURL \(self.updatedModelURL)")
        
        let trainLogHandle = MXMetricManager.makeLogHandle(category: "Train")
        mxSignpost(
            .begin,
          log: trainLogHandle,
          name: "Train")
        
        let startTrainLogHandle = MXMetricManager.makeLogHandle(category: "Train")
        mxSignpost(
            .begin,
          log: startTrainLogHandle,
          name: "Start Train")
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: self.updatedModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                     completionHandler: self.updateModelCompletionHandler)
        }
    }
    
    /// Create the MLArrayBatchProvider used to train the MLModel
    /// It's created using the buffer data,
    func createUpdateFeatures() -> MLArrayBatchProvider {
        // Get the SarsaTuples
        let data = buffer.batchProvider()
        // Create the variable for the Target
        var target: MLFeatureValue
        // Array of MLFeatureProvider that will compose the MLArrayBatchProvider
        // It's composed by MLDictionaryFeatureProvider that contains the 'data' and the 'actions_true' as a dict
        var featureProviders = [MLFeatureProvider]()
        
        // Iter over data from buffer
        for d in data {
            defaultLogger.log("__________\(d.getAction())___________")
            defaultLogger.log("__________\(d.getState())___________")
            defaultLogger.log("__________\(d.getReward())___________")
            defaultLogger.log("__________\(d.getNextState())___________")
            let state = d.getState()
            let action = d.getAction()
            let reward = d.getReward()
            let nextState = d.getNextState()
            var nextStateArray: [Double] = convertToArray(from: d.getNextState())
            
            // if use simulator do not use the state with the battery == 0; [1] notification, [0]battery
            if self.episodeEnd() {
                print("state battery 0: end of the episode")
                nextStateArray = []
            }
            
            // Create a MLFeatureValue as input for the model
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value
            let stateTarget = updatedModel!.predictFor(stateValue)!.actions
            defaultLogger.log("Predict livemodel \(stateTarget)")
            
            if nextStateArray != [] {
                // Create a MLFeatureValue as input for the target model
                let nextStateValue = MLFeatureValue(multiArray: nextState)
                
                // take value for next state
                let nextStateActions = targetModel!.predictFor(nextStateValue)!.actions
                let nextStateTarget = convertToArray(from: nextStateActions)
                defaultLogger.log("Predict TargetModel \(nextStateActions)")
                // Update the taget with the max q-value of next state, using a greedy policy
                stateTarget[action] = NSNumber(value: Double(reward) + self.gamma * nextStateTarget.max()!)
            } else {
                stateTarget[action] = NSNumber(value: Double(reward))
            }

            defaultLogger.log("Target Updated \(stateTarget)")
            target = MLFeatureValue(multiArray: stateTarget)
            
            // Create the final Dictionary to build the input
            let dataPointFeatures: [String: MLFeatureValue] = [inputName: stateValue,
                                                            outputName: target]

            if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
             featureProviders.append(provider)
            }
         }
         
        return MLArrayBatchProvider(array: featureProviders.shuffled())
        
    }
    
    /// The closure an MLUpdateTask calls when it finishes updating the model.
    func updateModelCompletionHandler(updateContext: MLUpdateContext) {
        
        defaultLogger.log("Training completed with state \(updateContext.task.state.rawValue)")
        if updateContext.task.state == .failed {
            defaultLogger.log("Failed")
            defaultLogger.log("\(updateContext.task.error!.localizedDescription)")
            return
          }
        
        self.countTargetUpdate += 1
        
        // Save the updated model to the file system.
        saveUpdatedModel(updateContext)

        // Begin using the saved updated model.
        loadUpdatedModel()
        
        let endTrainLogHandle = MXMetricManager.makeLogHandle(category: "Train")
        mxSignpost(
            .end,
          log: endTrainLogHandle,
          name: "End Train")

        // Inform the calling View Controller when the update is complete
        DispatchQueue.main.async { defaultLogger.log("Trained") }
    }
    
    // Handle the progress during the MLUpdateTask
    func progressHandler(context: MLUpdateContext) {
        switch context.event {
        case .trainingBegin:
            defaultLogger.info("Training begin")
        case .miniBatchEnd:
            let batchIndex = context.metrics[.miniBatchIndex] as! Int
//            let batchLoss = context.metrics[.lossValue] as! Double
//            defaultLogger.log("Mini batch \(batchIndex), loss: \(batchLoss)")
            print("batchIndex: \(batchIndex)")
//            Tester.readWeights(currentModel: context.model)

        case .epochEnd:
            let epochIndex = context.metrics[.epochIndex] as! Int
            let trainLoss = context.metrics[.lossValue] as! Double
            defaultLogger.info("Epoch \(epochIndex) Loss \(trainLoss)")
            
//            Tester.readWeights(currentModel: context.model)
            
        default:
            defaultLogger.log("Unknown event")
        }
    }
}
 
