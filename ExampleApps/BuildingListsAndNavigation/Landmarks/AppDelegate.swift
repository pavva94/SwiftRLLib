//
//  AppDelegate.swift
//  Landmarks
//
//  Created by Alessandro Pavesi on 25/11/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import SwiftUI
import BackgroundTasks
import AppleRL
import CoreML

var actionsArray: [Action] = [Decrese(), LeaveIt(), Increase()]
var environment: Env = Env(sensors: ["brightness", "battery", "clock"], actions: actionsArray, actionSize: 3)
let params: Dictionary<String, Any> = ["epsilon": Double(0.7), "learning_rate": Double(0.15), "gamma": Double(0.5)]
let qnet: DeepQNetwork = DeepQNetwork(env: environment, parameters: params)

let backgroundMode = true


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        defaultLogger.log("Your code here")
        
        if backgroundMode {
            print("Background tasks registered")
            BGTaskScheduler.shared.register(
              forTaskWithIdentifier: "com.pavesialessandro.applerl.backgroundListen",
              using: nil) { (task) in
                defaultLogger.log("Listen Task handler")
                  qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            }

            BGTaskScheduler.shared.register(
              forTaskWithIdentifier: "com.pavesialessandro.applerl.backgroundTrain",
              using: nil) { (task) in
                defaultLogger.log("Background Task handler")
                  qnet.handleTrainingTask(task: task as! BGProcessingTask)
            }
            
            BGTaskScheduler.shared.cancelAllTaskRequests()
            qnet.scheduleBackgroundTrainingFetch()
            qnet.scheduleBackgroundSensorFetch()
            
        } else {
            qnet.startListen(interval: 10)
            qnet.startTrain(interval: 50)
        }
        return true
    }
}
