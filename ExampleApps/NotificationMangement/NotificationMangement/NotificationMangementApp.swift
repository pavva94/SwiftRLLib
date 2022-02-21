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

let actionsArray: [Action] = [Send(), NotSend()]
let rewardsArray: [Reward] = [ReadSendRatio()]

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


// FIRST Trial: BASE
var environment: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 5,
    .secondsTrainProcess: 10*60
]

let qnet: DeepQNetwork = DeepQNetwork(env: environment, policy: EpsilonGreedy(), parameters: params)

// Second Trial: Smaller LR
var environment2: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params2: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.00001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 7,
    .secondsTrainProcess: 10*60
]
let qnet2: DeepQNetwork = DeepQNetwork(env: environment2, policy: EpsilonGreedy(), parameters: params2)


// Third Trial: Bigger LR
var environment3: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params3: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 9,
    .secondsTrainProcess: 10*60
]
let qnet3: DeepQNetwork = DeepQNetwork(env: environment3, policy: EpsilonGreedy(), parameters: params3)

// Forth Trial: Bigger batch size
var environment4: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params4: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 64,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 11,
    .secondsTrainProcess: 10*60
]
let qnet4: DeepQNetwork = DeepQNetwork(env: environment4, policy: EpsilonGreedy(), parameters: params4)

// Fifth Trial: More bigger batch size, though bigger training size
var environment5: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params5: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 128,
    .trainingSetSize: 128*4,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 13,
    .secondsTrainProcess: 10*60
]
let qnet5: DeepQNetwork = DeepQNetwork(env: environment5, policy: EpsilonGreedy(), parameters: params5)

// Sixth Trial: Smaller batch size
var environment6: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params6: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 16,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 17,
    .secondsTrainProcess: 10*60
]
let qnet6: DeepQNetwork = DeepQNetwork(env: environment6, policy: EpsilonGreedy(), parameters: params6)


// Seventh Trial: Even Smaller batch size
var environment7: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params7: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 16,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 20,
    .secondsTrainProcess: 10*60
]
let qnet7: DeepQNetwork = DeepQNetwork(env: environment7, policy: EpsilonGreedy(), parameters: params7)




// NEW Trial: NEW SENSOR -> STACK
var environmentNew: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let paramsNew: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 3,
    .secondsTrainProcess: 10*60
]

let qnetNew: DeepQNetwork = DeepQNetwork(env: environmentNew, policy: EpsilonGreedy(), parameters: paramsNew)


// NEW Trial: NEW SENSOR -> STACK
var environmentQL: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let paramsQL: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.0001),
    .gamma: Double(0.9),
    .secondsObserveProcess: 30,
    .secondsTrainProcess: 10*60
]

let QL: QLearning = QLearning(env: environmentNew, policy: EpsilonGreedy(), parameters: paramsQL)


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
        
        let clockSens = ClockSensor()
        let clock = clockSens.read()
        
        // Perform the task associated with the action.
       switch response.actionIdentifier {
       case "Read":
           print("Read Clicked")
           newSensor.addRead(clock: clock)
           break
       case "com.apple.UNNotificationDismissActionIdentifier":
           print("AppleWatch read")
           newSensor.addRead(clock: clock)
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

    func userNotificationCenter(_ center: UNUserNotificationCenter,
             willPresent notification: UNNotification,
             withCompletionHandler completionHandler:
                @escaping (UNNotificationPresentationOptions) -> Void) {

        print("Notification Foreground Handler")
        // Play a sound to let the user know about the invitation.
        if useSimulator {
            // simulate behaviour: only in defined hours the users read the notification
            let state = environment.read()
            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state[2]) && Double.random(in: 0...1) < 0.9 {
                newSensor.addRead(clock: [state[2],state[3]])
            }
        }
        completionHandler(.sound)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        environment.addObservableData(s: newSensor)
        environment2.addObservableData(s: newSensor)
        environment3.addObservableData(s: newSensor)
        environment4.addObservableData(s: newSensor)
        environment5.addObservableData(s: newSensor)

        environment6.addObservableData(s: newSensor)
        environment7.addObservableData(s: newSensor)
        
        environmentQL.addObservableData(s: newSensor)
        
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
                ContentView(qnet: qnet, sensor: newSensor, database: dataManager.loadDatabase("database.json")).onAppear(perform: initializeRL)
            }
        }
        
        func initializeRL() {
            print("App opened")
//            qnet.observe(.timer)
//            qnetNew.observe(.timer)
            
            QL.observe(.timer)
            
            let metricManager = MXMetricManager.shared
            metricManager.add(appleRLMetrics)
            
        }
}




