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
    typealias SarsaTuple = SarsaTupleGeneric
    
    /// Name of model's inputs
    let inputName = modelInputName
    let outputName = modelOutputName
    
    let environment: Env
    let fileManager = FileManager.default
    let defaults = UserDefaults.standard
    
    /// Timers for ListenMode
    var timerListen : Timer? = nil { willSet { timerListen?.invalidate() }}
    var timerTrain : Timer? = nil { willSet { timerTrain?.invalidate() }}
    
    /// Training parameters
    var learningRate: [Double]
    var learningRateDecayMode: Bool
    var trainingCounter: Int
    var timeIntervalBackgroundMode: Int
    var timeIntervalTrainingBackgroundMode: Int
    var epochs: Int = 10
    var epsilon: Double = 0.3
    var gamma: Double = 0.9
    var miniBatchSize: Int = 8
    
    var countTargetUpdate: Int = 0
    let epochsAlignTarget: Int = 10
    
    /// A Boolean that indicates whether the instance has all the required data: 2 times the minibatch size
    var isReadyForTraining: Bool { buffer.count >= miniBatchSize * epochs }
    
    /// The updated Model model.
    var updatedModel: AppleRLModel?
   
    /// Target model, a clone of the live model
    var targetModel: AppleRLModel?
    
    /// The location of the app's Application Support directory for the user.
    private static let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask).first!
    
    /// The default Model model's file URL.
    let defaultModelURL = AppleRLModel.urlOfModelInThisBundle
    /// The permanent location of the updated Model model.
    var updatedModelURL: URL = appDirectory.appendingPathComponent(personalizedModelFileName)
    /// The temporary location of the updated Model model.
    var tempUpdatedModelURL: URL = appDirectory.appendingPathComponent(tempModelFileName)
    /// The permanent location of the updated Target Model model.
    var updatedTargetModelURL: URL = appDirectory.appendingPathComponent(personalizedTargetModelFileName)
    
    /// Initialize every variables
    required public init(env: Env, parameters: Dictionary<ModelParameters, Any>) {
        environment = env
        
        self.buffer = ExperienceReplayBuffer()
        self.epsilon = parameters.keys.contains(.epsilon) ? (parameters[.epsilon] as? Double)! : self.epsilon
        self.gamma = parameters.keys.contains(.gamma) ? (parameters[.gamma] as? Double)! : self.gamma
        self.epochs = parameters.keys.contains(.epochs) ? (parameters[.epochs] as? Int)! : self.epochs
        self.trainingCounter = self.defaults.integer(forKey: "trainingCounter")
        
        do {
            try self.learningRate = [(parameters[.learning_rate] as? Double)!]
            self.learningRateDecayMode = false
        } catch {
            self.learningRate = (parameters[.learning_rate] as? [Double])!
            self.learningRateDecayMode = true
        }
        
        self.timeIntervalTrainingBackgroundMode = 2*60*60 // 2 ore
        if parameters.keys.contains(.timeIntervalBackgroundMode) {
            self.timeIntervalBackgroundMode = parameters[.timeIntervalBackgroundMode] as! Int
        } else {
            self.timeIntervalBackgroundMode = 10*60 // 10 minuti
        }
        defaultLogger.log("DQN Initialized")
        loadUpdatedModel()
            
    }
    
    open func getDeafultModelURL() -> URL {
        return defaultModelURL
    }
    
    open func getModelURL() -> URL {
        return updatedModelURL
    }
    
    /// Create and store SarsaTuple into the buffer
    open func store(state: MLMultiArray, action: Int, reward: Double, nextState: MLMultiArray) {
        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
        buffer.addData(tuple)
    }
    
    /// Create and store SarsaTuple into the buffer and delete from database
//    open func storeAndDelete(id: Int, state: MLMultiArray, action: Int, reward: Double, nextState: MLMultiArray) {
//        let tuple = SarsaTuple(state: state, action: action, reward: reward, nextState: nextState)
//        buffer.addData(tuple)
////        deleteFromDataset(id: id, path: databasePath)
//    }
    
    /// open function to make a choice about what action do
    open func act(state: MLMultiArray, greedy: Bool = false) -> Int {
        return epsilonGreedy(state: state)
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
    
    open func observe(_ mode: ObserveMode, repeat: Bool = true) {
        if mode == ObserveMode.timer {
            self.startListen(interval: self.timeIntervalBackgroundMode)
            self.startTrain(interval: self.timeIntervalTrainingBackgroundMode)
        } else if mode == ObserveMode.background {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            self.scheduleBackgroundSensorFetch()
            self.scheduleBackgroundTrainingFetch()
        } else if mode == ObserveMode.both {
            self.startListen(interval: self.timeIntervalBackgroundMode)
            self.startTrain(interval: self.timeIntervalTrainingBackgroundMode)
            BGTaskScheduler.shared.cancelAllTaskRequests()
            self.scheduleBackgroundSensorFetch()
            self.scheduleBackgroundTrainingFetch()
        } else {
            print("Observe Mode Wrong")
            return
        }

        print("Observe Started")
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
