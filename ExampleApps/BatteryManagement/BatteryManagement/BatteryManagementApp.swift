//
//  BatteryManagementApp.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL
import BackgroundTasks


let actionsArray: [Action] = [BrightnessDecrese0(), BrightnessIncrese0()]
let reward: [Reward] = [Reward3()]
var environment: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray, rewards: reward, actionSize: 3)
let params: Dictionary<ModelParameters, Any> = [.agentID: 0, .batchSize: 64, .learning_rate: Double(0.0001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 5*60]
let qnet: DeepQNetwork = DeepQNetwork(env: environment, policy: EpsilonGreedy(id: 0), parameters: params)


var firstOpen = true


@main
struct BatteryManagementApp: App {
    
    init(){
        print("Background tasks registered")
        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: backgroundListenURL,
          using: nil) { (task) in
            print("Listen Task handler")
              qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: backgroundTrainURL,
          using: nil) { (task) in
            print("Background Task handler")
              qnet.handleTrainingTask(task: task as! BGProcessingTask)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(databaseDataApp: [], qnet: qnet, actionsArray: actionsArray).onAppear(perform: initializeRL)
        }
    }
    
    func initializeRL() {
        if firstOpen {
            qnet.start(.timer, .training)
            }
        firstOpen = false
        
    }
}
