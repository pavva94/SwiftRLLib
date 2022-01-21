//
//  DQN+Background.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation
import BackgroundTasks

extension DeepQNetwork {
    open func handleAppRefreshTask(task: BGAppRefreshTask) {
        defaultLogger.log("Handling Listen ask")
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        self.listen()
        task.setTaskCompleted(success: true)
      
        scheduleBackgroundFetch()
    }

    public func scheduleBackgroundFetch() {
        defaultLogger.log("Background fetch activate")
        let fetchTask = BGAppRefreshTaskRequest(identifier: backgroundListenURL)
        fetchTask.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(self.timeIntervalBackgroundMode)) // launch at least every x minutes
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
        
        self.update()
        task.setTaskCompleted(success: true)
      
      
        scheduleBackgroundTraining()
    }

    public func scheduleBackgroundTraining() {
        defaultLogger.log("backgroundmode training activation")
        
        let request = BGProcessingTaskRequest(identifier: backgroundTrainURL)
//        request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
        request.requiresExternalPower = false // Need to true if your task requires a device connected to power source. Defaults to false.

        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(self.timeIntervalTrainingBackgroundMode)) // Process after x minutes.

        do {
            try BGTaskScheduler.shared.submit(request)
            defaultLogger.log("training task scheduled")
        } catch {
            defaultLogger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
}
