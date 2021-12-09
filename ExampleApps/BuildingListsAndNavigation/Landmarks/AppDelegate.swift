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

var actionsArray: [Action] = [Increase(), LeaveIt(), Increase()]
var e: Env = Env(sensors: ["brightness", "battery", "clock"], actions: actionsArray, actionSize: 3, stateSize: 3)
let params: Dictionary<String, Any> = ["epsilon": Double(0.7), "learning_rate": Double(0.15), "gamma": Double(0.5)]
let qnet: DeepQNetwork = DeepQNetwork(env: e, parameters: params)

let backgroundMode = false


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        defaultLogger.log("Your code here")
        
        if backgroundMode {
            BGTaskScheduler.shared.cancelAllTaskRequests()

            BGTaskScheduler.shared.register(
              forTaskWithIdentifier: "com.AppleRL.backgroundListen",
              using: nil) { (task) in
                defaultLogger.log("Task handler")
                  qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
            }

            BGTaskScheduler.shared.register(
              forTaskWithIdentifier: "com.AppleRL.backgroundTrain",
              using: nil) { (task) in
                defaultLogger.log("Task handler")
                  qnet.handleTrainingTask(task: task as! BGProcessingTask)
            }
        } else {
            qnet.startListen(interval: 10)
            qnet.startTrain(interval: 50)
        }
        return true
    }
}
