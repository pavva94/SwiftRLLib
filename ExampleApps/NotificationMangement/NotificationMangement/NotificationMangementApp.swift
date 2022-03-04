//
//  NotificationMangementApp.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import SwiftUI
import BackgroundTasks
import AppleRL
import MetricKit
import CoreML

//class Test1: Testing {
//    override func checkCorrectPrediction(environment: Env, urlModel: URL) {
//        do {
////             [8.0, 12.0, 13.0, 18.0, 19.0, 20.0]
////            let newModel = try AppleRLModel(contentsOf: urlModel)
////            print("Same State: [0.0, 38.0, 20.0, 30.0, 0.0, 0.0], Correct action: 0 -> SENDIT")
////            var stateFixed = MLFeatureValue(multiArray:convertToMLMultiArrayFloat(from: [0.0, 38.0, 20.0, 30.0, 0.0, 0.0]))
////            print("Optimal Reward: \(environment.reward(state: [0.0, 38.0, 20.0, 30.0, 0.0, 0.0], action: 0, nextState: [0.0, 38.0, 20.0, 30.0, 0.0, 0.1]))")
////            var actionChoosen = newModel.predictLabelFor(stateFixed)
////            print("Action choosen: \(String(describing: actionChoosen))")
////            var actionListChoosen = newModel.predictFor(stateFixed)
////            print("Action List choosen: \(String(describing: actionListChoosen!.actions))")
////
////            let newModel = try AppleRLModel(contentsOf: urlModel)
////            print("Same State: [14.0, 11.0, 0.0, 0.6], Correct action: 2") //20% battery -> Decrese = 2, nextState [14.0, 11.0, 0.0, 0.4] = battery -2 - 0.4*10
////            var stateFixed = MLFeatureValue(multiArray:convertToMLMultiArrayFloat(from: [14.0, 11.0, 0.0, 0.6]))
////            print("Optimal Reward: \(environment.reward(state: [14.0, 11.0, 0.0, 0.6], action: 2, nextState: [14.0, 11.0, 0.0, 0.4]))")
////            var actionChoosen = newModel.predictLabelFor(stateFixed)
////            print("Action choosen: \(String(describing: actionChoosen))")
////            var actionListChoosen = newModel.predictFor(stateFixed)
////            print("Action List choosen: \(String(describing: actionListChoosen!.actions))")
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//}
//let newSensor = ReadNotificationSensor()
//let newSensor2 = ReadNotificationSensor()
//let newSensor3 = ReadNotificationSensor()
//let newSensor4 = ReadNotificationSensor()
//let newSensor5 = ReadNotificationSensor()
//let newSensor6 = ReadNotificationSensor()
//let newSensor7 = ReadNotificationSensor()
let newSensorStack = ReadNotificationSensorStack()
let newSensorStack2 = ReadNotificationSensorStack()
//let newSensorQL = ReadNotificationSensor()

// FIRST Trial: BASE
//let actionsArray: [Action] = [Action1(), NotSend()]
//let rewardsArray: [Reward] = [ReadSendRatio()]
//var environment: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
//let params: Dictionary<ModelParameters, Any> = [
//    .agentID: 0,
//    .epsilon: Double(0.6),
//    .batchSize: 32,
//    .learning_rate: Double(0.0001),
//    .gamma: Double(0.9),
//    .secondsObserveProcess: 5,
//    .secondsTrainProcess: 10*60
//]
//
//let qnet: DeepQNetwork = DeepQNetwork(env: environment, policy: EpsilonGreedy(), parameters: params)

// NEW Trial: NEW SENSOR -> STACK IPHONE 13
//let actionsArrayNew: [Action] = [ActionStack(), NotSend()]
//let rewardsArrayNew: [Reward] = [ReadSendRatioNew()]
//var environmentNew: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArrayNew, rewards: rewardsArrayNew, actionSize: 2)
//let paramsNew: Dictionary<ModelParameters, Any> = [
//    .agentID: 10,
////    .epsilon: Double(0.6),
//    .batchSize: 64,
//    .learning_rate: Double(0.001),
//    .gamma: Double(0.999),
//    .secondsObserveProcess: 1,
//    .secondsTrainProcess: 5*60
//]

//let qnetNew: DeepQNetwork = DeepQNetwork(env: environmentNew, policy: EpsilonGreedy(), parameters: paramsNew)

//// NEW Trial: NEW SENSOR -> STACK IPHONE 13pro4444444
let actionsArrayNew2: [Action] = [ActionStack2(), NotSend()]
let rewardsArrayNew2: [Reward] = [ReadSendRatioNew2()]
var environmentNew2: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArrayNew2, rewards: rewardsArrayNew2, actionSize: 2)
let paramsNew2: Dictionary<ModelParameters, Any> = [
    .agentID: 10,
//    .epsilon: Double(0.6),
    .batchSize: 64,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.999),
    .secondsObserveProcess: 1,
    .secondsTrainProcess: 6*60
]

let qnetNew2: DeepQNetwork = DeepQNetwork(env: environmentNew2, policy: EpsilonGreedy(id: 0), parameters: paramsNew2)

// IPHONE 13Pro3333
let actionsArrayNew: [Action] = [ActionStack(), NotSend()]
let rewardsArrayNew: [Reward] = [ReadSendRatioNew()]
var environmentNew: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArrayNew, rewards: rewardsArrayNew, actionSize: 2)
let paramsNew: Dictionary<ModelParameters, Any> = [
    .agentID: 9,
//    .epsilon: Double(0.6),
    .batchSize: 16,
    .learning_rate: Double(0.00001),
    .gamma: Double(0.999),
    .secondsObserveProcess: 1,
    .secondsTrainProcess: 6*60
]

let qnetNew: DeepQNetwork = DeepQNetwork(env: environmentNew, policy: EpsilonGreedy(id: 1), parameters: paramsNew)


// QLearning Trial
//let actionsArrayQL: [Action] = [ActionQL(), NotSend()]
//let rewardsArrayQL: [Reward] = [ReadSendRatioQL()]
//var environmentQL: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArrayQL, rewards: rewardsArrayQL, actionSize: 2)
//let paramsQL: Dictionary<ModelParameters, Any> = [
//    .agentID: 8,
//    .epsilon: Double(0.6),
//    .batchSize: 32,
//    .learning_rate: Double(0.01),
//    .gamma: Double(0.9),
//    .secondsObserveProcess: 5,
//    .secondsTrainProcess: 5*60
//]
//
//let QL: QLearning = QLearning(env: environmentQL, policy: EpsilonGreedy(), parameters: paramsQL)


var firstOpen = true

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse,
           withCompletionHandler completionHandler:
             @escaping () -> Void) {
           
       print("Notification Handler")
        
//        let clockSens = ClockSensor()
//        let clock = clockSens.read()
        
        let clock = environmentNew.simulator.simulateClock()
        
        // Perform the task associated with the action.
       switch response.actionIdentifier {
       case "Read":
           print("Read Clicked")
           newSensorStack.addRead(clock: clock)
           break
       case "com.apple.UNNotificationDismissActionIdentifier":
           print("AppleWatch read")
           newSensorStack.addRead(clock: clock)
           break
        default:
           print("Unknown Action Identifier")
//           newSensor.addNotRead()
           print("\(response.actionIdentifier)")
           break
       }
        
       // Always call the completion handler when done.
       completionHandler()
    }

//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//             willPresent notification: UNNotification,
//             withCompletionHandler completionHandler:
//                @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        print("Notification Foreground Handler")
//        // Play a sound to let the user know about the invitation.
//        if useSimulator {
//            // simulate behaviour: only in defined hours the users read the notification
//            let state = environmentNew.read()
//            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state[2]) && Double.random(in: 0...1) < 0.9 {
//                newSensorStack.addRead(clock: [state[2],state[3]])
//            }
////            let state2 = environment2.read()
////            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state2[2]) && Double.random(in: 0...1) < 0.9 {
////                newSensor2.addRead(clock: [state2[2],state2[3]])
////            }
////            let state3 = environment3.read()
////            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state3[2]) && Double.random(in: 0...1) < 0.9 {
////                newSensor3.addRead(clock: [state3[2],state3[3]])
////            }
////            let state4 = environment4.read()
////            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state4[2]) && Double.random(in: 0...1) < 0.9 {
////                newSensor4.addRead(clock: [state4[2],state4[3]])
////            }
////            let state5 = environment2.read()
////            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state5[2]) && Double.random(in: 0...1) < 0.9 {
////                newSensor5.addRead(clock: [state5[2],state5[3]])
////            }
////            let state6 = environment2.read()
////            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state6[2]) && Double.random(in: 0...1) < 0.9 {
////                newSensor6.addRead(clock: [state6[2],state6[3]])
////            }
////            let state7 = environment2.read()
////            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state7[2]) && Double.random(in: 0...1) < 0.9 {
////                newSensor7.addRead(clock: [state7[2],state7[3]])
////            }
//        }
//        completionHandler(.sound)
//    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        environmentNew.addObservableData(s: newSensorStack)
        environmentNew2.addObservableData(s: newSensorStack2)
        
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
//              qnet.handleTrainingTask(task: task as! BGProcessingTask)
        }
        print("Background tasks registered")
        return true
    }
    
}

@main
struct NotificationMangementApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
        
    init(){
        
//        dataManager.copyFilesFromBundleToDocumentsFolderWith(fileExtension: ".json")
//        copyFilesFromBundleToDocumentsFolderWith(fileExtension: ".mlmodelc")
        
    }
    @StateObject var delegate = NotificationDelegate()
    
    var body: some Scene {
            WindowGroup {
                ContentView(qnet: qnetNew, sensor: newSensorStack, database: dataManager.loadDatabase("database.json")).onAppear(perform: initializeRL)
            }
        }
        
        func initializeRL() {
            print("App opened")
            qnetNew.observe(.timer, .training)
//            qnetNew2.observe(.timer)
            
//            QL.observe(.timer)
            
            let metricManager = MXMetricManager.shared
            metricManager.add(appleRLMetrics)
            
        }
}




