//
//  BatteryManagementApp.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL
import BackgroundTasks
//import CoreLocation

let actionsArray: [Action] = [BrightnessDecrese0(), BrightnessLeaveIt(), BrightnessIncrese0()]
let reward: [Reward] = [Reward0()]
var environment0: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray, rewards: reward, actionSize: 3)
let params: Dictionary<ModelParameters, Any> = [.agentID: 0, .epsilon: Double(0.6), .learning_rate: Double(0.001), .gamma: Double(0.9), .secondsObserveProcess: 3, .secondsTrainProcess: 10*60]
let qnet: DeepQNetwork = DeepQNetwork(env: environment0, policy: EpsilonGreedy(), parameters: params)

let actionsArray1: [Action] = [BrightnessDecrese1(), BrightnessLeaveIt(), BrightnessIncrese1()]
let reward1: [Reward] = [Reward1()]
var environment1: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray1, rewards: reward1, actionSize: 3)
let params1: Dictionary<ModelParameters, Any> = [.agentID: 1, .epsilon: Double(0.6), .learning_rate: Double(0.0001), .gamma: Double(0.9), .secondsObserveProcess: 3, .secondsTrainProcess: 10*60]
let qnet1: DeepQNetwork = DeepQNetwork(env: environment1, policy: EpsilonGreedy(), parameters: params1)


let actionsArray2: [Action] = [BrightnessDecrese2(), BrightnessLeaveIt(), BrightnessIncrese2()]
let reward2: [Reward] = [Reward2()]
var environment2: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray2, rewards: reward1, actionSize: 3)
let params2: Dictionary<ModelParameters, Any> = [.agentID: 2, .epsilon: Double(0.6), .learning_rate: Double(0.00001), .gamma: Double(0.9), .secondsObserveProcess: 3, .secondsTrainProcess: 10*60]
let qnet2: DeepQNetwork = DeepQNetwork(env: environment2, policy: EpsilonGreedy(), parameters: params2)

let actionsArray3: [Action] = [BrightnessDecrese3(), BrightnessLeaveIt(), BrightnessIncrese3()]
let reward3: [Reward] = [Reward3()]
var environment3: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray3, rewards: reward3, actionSize: 3)
let params3: Dictionary<ModelParameters, Any> = [.agentID: 3, .epsilon: Double(0.6), .learning_rate: Double(0.0001), .gamma: Double(0.9), .secondsObserveProcess: 3, .secondsTrainProcess: 10*60, .batchSize: 128]
let qnet3: DeepQNetwork = DeepQNetwork(env: environment3, policy: EpsilonGreedy(), parameters: params3)


let actionsArrayQL: [Action] = [BrightnessDecreseQL(), BrightnessLeaveIt(), BrightnessIncreseQL()]
let rewardQL: [Reward] = [RewardQL()]
var environmentQL: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArrayQL, rewards: rewardQL, actionSize: 3)
let paramsQL: Dictionary<ModelParameters, Any> = [.agentID: 4, .epsilon: Double(0.6), .learning_rate: Double(0.0001), .gamma: Double(0.9), .secondsObserveProcess: 3, .secondsTrainProcess: 10*60]
let qnetQL: QLearning = QLearning(env: environmentQL, policy: EpsilonGreedy(), parameters: paramsQL)





var firstOpen = true


@main
struct BatteryManagementApp: App {
    
    init(){
//        resetDatabase(path: "database.json")
//        resetDatabase(path: "buffer.json")
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
            qnet.observe(.timer)
            qnet1.observe(.timer)
            qnet2.observe(.timer)
            qnet3.observe(.timer)
            qnetQL.observe(.timer)
        
//            BGTaskScheduler.shared.cancelAllTaskRequests()
//            qnet.scheduleBackgroundSensorFetch()
//            qnet.scheduleBackgroundTrainingFetch()
//            print("------------- \(qnet.getDeafultModelURL())")
//            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getDeafultModelURL())
//            print("------------- \(qnet.getModelURL())")
//            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
            print("-------------")
            }
        firstOpen = false
        
    }
}
