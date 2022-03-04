//
//  Agent.swift
//  
//
//  Created by Alessandro Pavesi on 21/02/22.
//

import Foundation
import BackgroundTasks


open class Agent {
    /// Identify the Agent with an ID
    var modelID: Int = 0
    
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
    var timerObserve : Timer? = nil {
            willSet {
                timerObserve?.invalidate()
            }
        }
    
    /// Timer for the Train process
    var timerTrain : Timer? = nil {
            willSet {
                timerTrain?.invalidate()
            }
        }
    
    /// Start the Observe process with Timer
    open func startObserve(interval: Int) {
        stopObserve()
        guard self.timerObserve == nil else { return }
        self.timerObserve = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }

    /// Stop the Observe process with Timer
    open func stopObserve() {
        guard timerObserve != nil else { return }
        timerObserve?.invalidate()
        timerObserve = nil
    }

    /// Start the Train process with Timer
    open func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }

    /// Stop the Train process with Timer
    open func stopTrain() {
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
    public func scheduleBackgroundObserve() {
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
    public func scheduleBackgroundTraining() {
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
