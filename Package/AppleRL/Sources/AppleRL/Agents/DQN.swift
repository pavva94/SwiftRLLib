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
        self.trainingCounter = self.defaults.integer(forKey: "trainingCounter")
        self.miniBatchSize = parameters.keys.contains(.batchSize) ? (parameters[.batchSize] as? Int)! : self.miniBatchSize
        self.secondsTrainProcess = parameters.keys.contains(.secondsTrainProcess) ? (parameters[.secondsTrainProcess] as? Int)! : 2*60*60 // 2 ore
        self.secondsObserveProcess = parameters.keys.contains(.secondsObserveProcess) ? (parameters[.secondsObserveProcess] as? Int)! : 10*60 // 10 minuti

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
