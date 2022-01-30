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


var environment: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params: Dictionary<ModelParameters, Any> = [
    .epsilon: Double(0.6),
    .batchSize: 32,
    .learning_rate: Double(0.00001),
    .gamma: Double(0.9),
    .timeIntervalBackgroundMode: 30,
    .timeIntervalTrainingBackgroundMode: 20*60
]

let qnet: DeepQNetwork = DeepQNetwork(env: environment, parameters: params)
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
        // Perform the task associated with the action.
       switch response.actionIdentifier {
       case "Read":
           print("Read Clicked")
           newSensor.addRead()
           break
       case "com.apple.UNNotificationDismissActionIdentifier":
           print("AppleWatch read")
           newSensor.addRead()
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
            // simulate behaviour
            let state = environment.read()
            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state[2]) && Double.random(in: 0...1) < 0.9 {
                newSensor.addRead()
            }
        }
        completionHandler(.sound)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        environment.addObservableData(s: newSensor)
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
        
        dataManager.copyFilesFromBundleToDocumentsFolderWith(fileExtension: ".json")
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
            qnet.observe(.both)
            let metricManager = MXMetricManager.shared
            metricManager.add(appleRLMetrics)
            
        }
}




