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

// Iphone 8
let actionsArray: [Action] = [BrightnessDecrese0(), BrightnessLeaveIt(), BrightnessIncrese0()]
let reward: [Reward] = [Reward2()]
var environment0: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray, rewards: reward, actionSize: 3)
let params: Dictionary<ModelParameters, Any> = [.agentID: 0, .batchSize: 64, .learning_rate: Double(0.0001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 5*60]
let qnet: DeepQNetwork = DeepQNetwork(env: environment0, policy: EpsilonGreedy3(), parameters: params)


// iphone 11
//let actionsArray: [Action] = [BrightnessDecrese0(), BrightnessLeaveIt(), BrightnessIncrese0()]
//let reward: [Reward] = [Reward4()]
//var environment0: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray, rewards: reward, actionSize: 3)
//let params: Dictionary<ModelParameters, Any> = [.agentID: 0, .batchSize: 64, .learning_rate: Double(0.0001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 5*60]
//let qnet: DeepQNetwork = DeepQNetwork(env: environment0, policy: EpsilonGreedy3(), parameters: params)


//let actionsArray: [Action] = [BrightnessDecrese0(), BrightnessLeaveIt(), BrightnessIncrese0()]
//let reward: [Reward] = [Reward2()]
//var environment0: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray, rewards: reward, actionSize: 3)
//let params: Dictionary<ModelParameters, Any> = [.agentID: 0, .batchSize: 64, .learning_rate: Double(0.00001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 5*60]
//let qnet: DeepQNetwork = DeepQNetwork(env: environment0, policy: EpsilonGreedy3(), parameters: params)


// iphone 13pro
let actionsArray1: [Action] = [BrightnessIncrese1(), BrightnessDecrese1()]
let reward1: [Reward] = [Reward3()]
var environment1: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray1, rewards: reward1, actionSize: 2)
let params1: Dictionary<ModelParameters, Any> = [.agentID: 10, .learning_rate: Double(0.00001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 150]
let qnet1: DeepQNetwork = DeepQNetwork(env: environment1, policy: EpsilonGreedy(id: 1), parameters: params1)
////
////
let actionsArray2: [Action] = [BrightnessIncrese2(), BrightnessDecrese2()]
let reward2: [Reward] = [Reward5()]
var environment2: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray2, rewards: reward2, actionSize: 2)
let params2: Dictionary<ModelParameters, Any> = [.agentID: 20, .learning_rate: Double(0.000001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 1*60, .batchSize: 64]
let qnet2: DeepQNetwork = DeepQNetwork(env: environment2, policy: EpsilonGreedy(id: 2), parameters: params2)

 
let actionsArray3: [Action] = [BrightnessIncrese3(), BrightnessDecrese3()]
let reward3: [Reward] = [Reward3()]
var environment3: Env = Env(observableData: ["battery", "clock", "brightness"], actions: actionsArray3, rewards: reward3, actionSize: 2)
let params3: Dictionary<ModelParameters, Any> = [.agentID: 30, .batchSize: 64, .learning_rate: Double(0.000001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 3*60]
let qnet3: DeepQNetwork = DeepQNetwork(env: environment3, policy: RandomPolicy(), parameters: params3)


//let actionsArrayQL: [Action] = [BrightnessIncreseQL(), BrightnessDecreseQL()]
//let rewardQL: [Reward] = [Reward5()]
//var environmentQL: Env = Env(observableData: ["battery", "brightness"], actions: actionsArrayQL, rewards: rewardQL, actionSize: 2)
//let paramsQL: Dictionary<ModelParameters, Any> = [.agentID: 40, .batchSize: 64, .learning_rate: Double(0.000001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 3*60]
//let qnetQL: QLearning = QLearning(env: environmentQL, policy: EpsilonGreedy(id: 3), parameters: paramsQL)


var firstOpen = true


@main
struct BatteryManagementApp: App {
    
    init(){
//        resetDatabase(path: "database.json")
//        resetDatabase(path: "buffer.json")
//        environment0.addObservableData(s: ConsumptionSensor())
//        environment1.addObservableData(s: ConsumptionSensor())
//        environment2.addObservableData(s: ConsumptionSensor())
//        environment3.addObservableData(s: ConsumptionSensorZero())
        print("Background tasks registered")
        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: backgroundListenURL,
          using: nil) { (task) in
            print("Listen Task handler")
//              qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(
          forTaskWithIdentifier: backgroundTrainURL,
          using: nil) { (task) in
            print("Background Task handler")
//              qnet.handleTrainisngTask(task: task as! BGProcessingTask)
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(databaseDataApp: [], qnet: qnet, actionsArray: actionsArray).onAppear(perform: initializeRL)
        }
    }
    
    func initializeRL() {
        if firstOpen {
//            qnet.observe(.timer)
            qnet1.observe(.timer, .inference)
//            qnet2.observe(.timer, .training)
            qnet3.observe(.timer, .inference)
//            qnet4.observe(.timer, .inference)
//            qnetQL.observe(.timer, .training)
        
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
