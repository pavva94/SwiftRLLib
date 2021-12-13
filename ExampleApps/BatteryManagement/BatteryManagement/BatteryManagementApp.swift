//
//  BatteryManagementApp.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL
import BackgroundTasks
import CoreLocation

let actionsArray: [Action] = [Deactivate(), LeaveIt(), Activate()]
var environment: Env = Env(sensors: ["localization", "battery", "clock", "lowPowerMode"], actions: actionsArray, actionSize: 3)
let params: Dictionary<String, Any> = ["epsilon": Double(0.7), "learning_rate": Double(0.15), "gamma": Double(0.5)]
let qnet: DeepQNetwork = DeepQNetwork(env: environment, parameters: params)
var firstOpen = true
let locationManager = CLLocationManager()

@main
struct BatteryManagementApp: App {
    
    init(){
        print("Background tasks registered")
        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: "com.pavesialessandro.applerl.backgroundListen",
          using: nil) { (task) in
            print("Listen Task handler")
              qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: "com.pavesialessandro.applerl.backgroundTrain",
          using: nil) { (task) in
            print("Background Task handler")
              qnet.handleTrainingTask(task: task as! BGProcessingTask)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(databaseDataApp: loadDatabase("database.json"), qnet: qnet, actionsArray: actionsArray).onAppear(perform: initializeRL)
        }
    }
    
    func initializeRL() {
        if firstOpen {
            
            BGTaskScheduler.shared.cancelAllTaskRequests()
            qnet.scheduleBackgroundSensorFetch()
            qnet.scheduleBackgroundTrainingFetch()
            }
        firstOpen = false
        
    }
}
