//
//  NotificationMangementApp.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import SwiftUI
import BackgroundTasks
import SwiftRL
import MetricKit
import CoreML

let newSensorStack = ReadNotificationSensorStack()

let actionsArray: [Action] = [Send(), NotSend()]
let rewardsArray: [Reward] = [ReadSendRatioNew()]
var environment: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params: Dictionary<ModelParameters, Any> = [
    .agentID: 9,
    .batchSize: 16,
    .learning_rate: Double(0.00001),
    .gamma: Double(0.999),
    .secondsObserveProcess: 1,
    .secondsTrainProcess: 6*60
]

let qnet: DeepQNetwork = DeepQNetwork(env: environment, policy: EpsilonGreedy(id: 1), parameters: params)

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
        
        let clock = environment.simulator.simulateClock()
        
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
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        environment.addObservableData(s: newSensorStack)
        
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
            qnet.start(.timer, .training)
            
            let metricManager = MXMetricManager.shared
            metricManager.add(RLMetrics)
            
        }
}




