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
    
    /// Variables for saving the data
    var bufferPath = defaultBufferPath
    var databasePath = defaultDatabasePath
    
    /// File manager and defaults
    let fileManager = FileManager.default
    let defaults = UserDefaults.standard
    
    var secondsObserveProcess: Int = 0
    var secondsTrainProcess: Int = 0
    
    open func observe(_ mode: ObserveMode, repeat: Bool = true) {
        if mode == ObserveMode.timer {
            self.startListen(interval: self.secondsObserveProcess)
            self.startTrain(interval: self.secondsTrainProcess)
        } else if mode == ObserveMode.background {
            BGTaskScheduler.shared.cancelAllTaskRequests()
            self.scheduleBackgroundFetch()
            self.scheduleBackgroundTraining()
        } else if mode == ObserveMode.both {
            self.startListen(interval: self.secondsObserveProcess)
            self.startTrain(interval: self.secondsTrainProcess)
            BGTaskScheduler.shared.cancelAllTaskRequests()
            self.scheduleBackgroundFetch()
            self.scheduleBackgroundTraining()
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
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }

    open func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
    
    open func handleAppRefreshTask(task: BGAppRefreshTask) {
        defaultLogger.log("Handling Listen ask")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // Listen the environment
        self.listen()
        task.setTaskCompleted(success: true)
      
        scheduleBackgroundFetch()
    }

    public func scheduleBackgroundFetch() {
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
