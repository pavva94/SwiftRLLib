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
let newSensor = ReadNotificationSensor()
let newSensor2 = ReadNotificationSensor()
let newSensor3 = ReadNotificationSensor()
let newSensor4 = ReadNotificationSensor()
let newSensor5 = ReadNotificationSensor()
let newSensor6 = ReadNotificationSensor()
let newSensor7 = ReadNotificationSensor()
let newSensorStack = ReadNotificationSensorStack()
let newSensorQL = ReadNotificationSensor()

// FIRST Trial: BASE
let actionsArray: [Action] = [Action1(), NotSend()]
let rewardsArray: [Reward] = [ReadSendRatio()]
var environment: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params: Dictionary<ModelParameters, Any> = [
    .agentID: 0,
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 5,
    .secondsTrainProcess: 10*60
]

let qnet: DeepQNetwork = DeepQNetwork(env: environment, policy: EpsilonGreedy(), parameters: params)

// Second Trial: Smaller LR
let actionsArray2: [Action] = [Action2(), NotSend()]
let rewardsArray2: [Reward] = [ReadSendRatio2()]
var environment2: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray2, rewards: rewardsArray2, actionSize: 2)
let params2: Dictionary<ModelParameters, Any> = [
    .agentID: 1,
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.00001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 8,
    .secondsTrainProcess: 10*60
]
let qnet2: DeepQNetwork = DeepQNetwork(env: environment2, policy: EpsilonGreedy(), parameters: params2)


// Third Trial: Bigger LR
let actionsArray3: [Action] = [Action3(), NotSend()]
let rewardsArray3: [Reward] = [ReadSendRatio3()]
var environment3: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray3, rewards: rewardsArray3, actionSize: 2)
let params3: Dictionary<ModelParameters, Any> = [
    .agentID: 2,
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 6,
    .secondsTrainProcess: 10*60
]
let qnet3: DeepQNetwork = DeepQNetwork(env: environment3, policy: EpsilonGreedy(), parameters: params3)

// Forth Trial: Bigger batch size
let actionsArray4: [Action] = [Action4(), NotSend()]
let rewardsArray4: [Reward] = [ReadSendRatio4()]
var environment4: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray4, rewards: rewardsArray4, actionSize: 2)
let params4: Dictionary<ModelParameters, Any> = [
    .agentID: 3,
    .epsilon: Double(0.6),
    .batchSize: 64,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 4,
    .secondsTrainProcess: 10*60
]
let qnet4: DeepQNetwork = DeepQNetwork(env: environment4, policy: EpsilonGreedy(), parameters: params4)

// Fifth Trial: More bigger batch size, though bigger training size
let actionsArray5: [Action] = [Action5(), NotSend()]
let rewardsArray5: [Reward] = [ReadSendRatio5()]
var environment5: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray5, rewards: rewardsArray5, actionSize: 2)
let params5: Dictionary<ModelParameters, Any> = [
    .agentID: 4,
    .epsilon: Double(0.6),
    .batchSize: 128,
    .trainingSetSize: 128*4,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 2,
    .secondsTrainProcess: 10*60
]
let qnet5: DeepQNetwork = DeepQNetwork(env: environment5, policy: EpsilonGreedy(), parameters: params5)

// Sixth Trial: Smaller batch size
let actionsArray6: [Action] = [Action6(), NotSend()]
let rewardsArray6: [Reward] = [ReadSendRatio6()]
var environment6: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray6, rewards: rewardsArray6, actionSize: 2)
let params6: Dictionary<ModelParameters, Any> = [
    .agentID: 5,
    .epsilon: Double(0.6),
    .batchSize: 16,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 7,
    .secondsTrainProcess: 10*60
]
let qnet6: DeepQNetwork = DeepQNetwork(env: environment6, policy: EpsilonGreedy(), parameters: params6)


// Seventh Trial: Even Smaller batch size
let actionsArray7: [Action] = [Action7(), NotSend()]
let rewardsArray7: [Reward] = [ReadSendRatio7()]
var environment7: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray7, rewards: rewardsArray7, actionSize: 2)
let params7: Dictionary<ModelParameters, Any> = [
    .agentID: 6,
    .epsilon: Double(0.6),
    .batchSize: 16,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 1,
    .secondsTrainProcess: 10*60
]
let qnet7: DeepQNetwork = DeepQNetwork(env: environment7, policy: EpsilonGreedy(), parameters: params7)




// NEW Trial: NEW SENSOR -> STACK
let actionsArrayNew: [Action] = [ActionStack(), NotSend()]
let rewardsArrayNew: [Reward] = [ReadSendRatioNew()]
var environmentNew: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArrayNew, rewards: rewardsArrayNew, actionSize: 2)
let paramsNew: Dictionary<ModelParameters, Any> = [
    .agentID: 7,
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 3,
    .secondsTrainProcess: 10*60
]

let qnetNew: DeepQNetwork = DeepQNetwork(env: environmentNew, policy: EpsilonGreedy(), parameters: paramsNew)


// QLearning Trial
let actionsArrayQL: [Action] = [ActionQL(), NotSend()]
let rewardsArrayQL: [Reward] = [ReadSendRatioQL()]
var environmentQL: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArrayQL, rewards: rewardsArrayQL, actionSize: 2)
let paramsQL: Dictionary<ModelParameters, Any> = [
    .agentID: 8,
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.01),
    .gamma: Double(0.9),
    .secondsObserveProcess: 5,
    .secondsTrainProcess: 5*60
]

let QL: QLearning = QLearning(env: environmentQL, policy: EpsilonGreedy(), parameters: paramsQL)


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

        environment.addObservableData(s: newSensor)
        environment2.addObservableData(s: newSensor2)
        environment3.addObservableData(s: newSensor3)
        environment4.addObservableData(s: newSensor4)
        environment5.addObservableData(s: newSensor5)

        environment6.addObservableData(s: newSensor6)
        environment7.addObservableData(s: newSensor7)

        environmentQL.addObservableData(s: newSensorQL)
//
        environmentNew.addObservableData(s: newSensorStack)
        
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
                ContentView(qnet: qnet, sensor: newSensorStack, database: dataManager.loadDatabase("database.json")).onAppear(perform: initializeRL)
            }
        }
        
        func initializeRL() {
            print("App opened")
            qnet.observe(.timer)
            qnet2.observe(.timer)
            qnet3.observe(.timer)
            qnet4.observe(.timer)
            qnet5.observe(.timer)
            qnet6.observe(.timer)
            qnet7.observe(.timer)
            
            qnetNew.observe(.timer)
            
            QL.observe(.timer)
            
            let metricManager = MXMetricManager.shared
            metricManager.add(appleRLMetrics)
            
        }
}




