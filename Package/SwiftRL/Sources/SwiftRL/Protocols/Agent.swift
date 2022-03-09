//
//  Agent.swift
//  
//
//  Created by Alessandro Pavesi on 21/02/22.
//

import Foundation
import BackgroundTasks

/// Superclass for the Agents
open class Agent {
    /// Set a typealias for the agent internal type
    typealias SarsaTuple = SarsaTupleGeneric
    
    /// Identify the Agent with an ID
    var modelID: Int = 0
    
    /// The environment with which the agent interact
    var environment: Environment
    /// The policy the agent uses
    var policy: Policy
    
    /// Define the buffer
    open var buffer: ExperienceReplayBuffer = ExperienceReplayBuffer()
    
    /// Training parameters
    var learningRate: [Double] = [0.0001]
    /// The variable for the learning rate decay
    var learningRateDecayMode: Bool = false
    var trainingCounter: Int = 0
//    var secondsObserveProcess: Int
//    var secondsTrainProcess: Int
    /// The default number  of epochs
    var epochs: Int = 10
    /// The defaultgamma
    var gamma: Double = 0.9
    /// The default mini batch size
    var miniBatchSize: Int = 32
    /// The default training set size
    var trainingSetSize: Int = 256
    
    /// Variables for saving the buffer data
    var bufferPath = defaultBufferPath
    /// Variables for saving the buffer data
    var databasePath = defaultDatabasePath
    
    /// File manager
    let fileManager = FileManager.default
    /// User default
    let defaults = UserDefaults.standard
    
    /// Seconds between two call of the observe process
    var secondsObserveProcess: Int = 0
    /// Seconds between two call of the train process
    var secondsTrainProcess: Int = 0
    
    /// Function to define the end of the episode
    var episodeEnd: ((_ state: RLStateData) -> Bool) = { state in return false }
    
    /// Initialize every variables
    required public init(env: Environment, policy: Policy, parameters: Dictionary<ModelParameter, Any>) {
        self.environment = env
        self.policy = policy
    
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
        self.episodeEnd = parameters.keys.contains(.episodeEnd) ? (parameters[.episodeEnd] as? ((_ state: RLStateData) -> Bool))! : episodeEndFalse

        // allows the possibility to use a variable learning rate
        if type(of: parameters[.learning_rate]) == Double.self {
            self.learningRate = [(parameters[.learning_rate] as? Double)!]
            self.learningRateDecayMode = false
        } else if type(of: parameters[.learning_rate]) == [Double].self {
            self.learningRate = (parameters[.learning_rate] as? [Double])!
            self.learningRateDecayMode = true
        }
        
    }
    
    /// Start processes based on parameters
    open func start(_ mode: WorkMode, _ type: AgentMode) {
        if mode == WorkMode.timer {
            if type == AgentMode.training {
                self.startObserve(interval: self.secondsObserveProcess)
                self.startTrain(interval: self.secondsTrainProcess)
            } else if type == AgentMode.inference {
                self.startObserve(interval: self.secondsObserveProcess)
            }
        } else if mode == WorkMode.background {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            if type == AgentMode.training {
                self.scheduleBackgroundObserve()
                self.scheduleBackgroundTraining()
            } else if type == AgentMode.inference {
                self.scheduleBackgroundObserve()
            }
        } else if mode == WorkMode.both {
            if type == AgentMode.training {
                self.startObserve(interval: self.secondsObserveProcess)
                self.startTrain(interval: self.secondsTrainProcess)
                BGTaskScheduler.shared.cancelAllTaskRequests()
                self.scheduleBackgroundObserve()
                self.scheduleBackgroundTraining()
            } else if type == AgentMode.inference {
                self.startObserve(interval: self.secondsObserveProcess)
                BGTaskScheduler.shared.cancelAllTaskRequests()
                self.scheduleBackgroundObserve()
            }
            
        } else {
            print("Observe Mode Wrong")
            return
        }

        print("Observe Started")
    }
    
    open func save() {
        fatalError("Not Implemented")
    }
    
    open func load() {
        fatalError("Not Implemented")
    }
    
    @objc open func listen() {
        fatalError("Not Implemented")
    }
    
    @objc open func update() {
        fatalError("Not Implemented")
    }
    
    /// Timer for the Observe process
    private var timerObserve : Timer? = nil {
            willSet {
                timerObserve?.invalidate()
            }
        }
    
    /// Timer for the Train process
    private var timerTrain : Timer? = nil {
            willSet {
                timerTrain?.invalidate()
            }
        }
    
    /// Start the Observe process with Timer
    private func startObserve(interval: Int) {
        stopObserve()
        guard self.timerObserve == nil else { return }
        self.timerObserve = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }

    /// Stop the Observe process with Timer
    private func stopObserve() {
        guard timerObserve != nil else { return }
        timerObserve?.invalidate()
        timerObserve = nil
    }

    /// Start the Train process with Timer
    private func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }

    /// Stop the Train process with Timer
    private func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
    
    /// Handler for the Observe process
    open func handleAppRefreshTask(task: BGAppRefreshTask) {
        defaultLogger.log("Handling Listen ask")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Listen the environment
        self.listen()
        task.setTaskCompleted(success: true)
      
        scheduleBackgroundObserve()
    }
    
    /// Scheduler for the Observe process in Background
    private func scheduleBackgroundObserve() {
        defaultLogger.log("Background fetch activate")
        let fetchTask = BGAppRefreshTaskRequest(identifier: backgroundListenURL)
        fetchTask.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(self.secondsObserveProcess)) // launch at least every x minutes
        do {
            try BGTaskScheduler.shared.submit(fetchTask)
            defaultLogger.log("task scheduled")
        } catch {
            defaultLogger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    /// Handler for the Train process
    open func handleTrainingTask(task: BGProcessingTask) {
        defaultLogger.log("Handling Training task")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Update the network
        self.update()
        task.setTaskCompleted(success: true)
      
      
        scheduleBackgroundTraining()
    }

    /// Scheduler for the Train process in Background
    private func scheduleBackgroundTraining() {
        defaultLogger.log("backgroundmode training activation")
        
        let request = BGProcessingTaskRequest(identifier: backgroundTrainURL)
//        request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
        request.requiresExternalPower = false // Need to true if your task requires a device connected to power source. Defaults to false.

        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(self.secondsTrainProcess)) // Process after x minutes.

        do {
            try BGTaskScheduler.shared.submit(request)
            defaultLogger.log("training task scheduled")
        } catch {
            defaultLogger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
}
