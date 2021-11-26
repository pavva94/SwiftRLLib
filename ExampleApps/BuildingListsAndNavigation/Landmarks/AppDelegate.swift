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


let e: Env = AppEnv(sens: ["brightness", "battery", "ambientLight"], actionSize: 3, stateSize: 3)
let params: Dictionary<String, Any> = ["epsilon": Double(0.6), "learning_rate": Double(0.1), "gamma": Double(0.8)]

let qnet: DeepQNetwork = DeepQNetwork(env: e, parameters: params)


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        
        initializeEnv()
        
        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: "com.example.apple-samplecode.LandmarksD3GRRL6TZ6.backgroundListen",
          using: nil) { (task) in
            print("Task handler")
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
        return true
    }


    func handleAppRefreshTask(task: BGAppRefreshTask) {
        print("Handling task")
        task.expirationHandler = {
          task.setTaskCompleted(success: false)
          
        }
      
      
//    NotificationCenter.default.post(name: .newPokemonFetched,
//                                    object: self,
//                                    userInfo: ["pokemon": pokemon])
        qnet.listen()
        task.setTaskCompleted(success: true)
      
      
        scheduleBackgroundSensorFetch()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as! AppDelegate).scheduleBackgroundSensorFetch()
    }

    func scheduleBackgroundSensorFetch() {
      let sensorFetchTask = BGAppRefreshTaskRequest(identifier: "com.example.apple-samplecode.LandmarksD3GRRL6TZ6.backgroundListen")
        sensorFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: 60)
      do {
        try BGTaskScheduler.shared.submit(sensorFetchTask)
        print("task scheduled")
      } catch {
        print("Unable to submit task: \(error.localizedDescription)")
      }
    }
}


func backgroundListen() {
    
}

public func initializeEnv() {
//    resetDatabase()
//        DeepQNetwork<[Float], Int, Double>(env: nil, parameters: params)
    print("DQN created")
//        var a = qnet.act(state: 2.0)
//        print("ActDone")
//        print(a)
//    qnet.startListen(interval: 10)
    qnet.startTrain(interval: 50)
}
