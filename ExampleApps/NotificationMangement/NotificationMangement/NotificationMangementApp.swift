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

let actionsArray: [Action] = [Send(), NotSend()]
let rewardsArray: [Reward] = [ReadSendRatio()]


var environment: Env = Env(observableData: ["locked", "battery", "clock", "lowPowerMode"], actions: actionsArray, rewards: rewardsArray, actionSize: 2)
let params: Dictionary<ModelParameters, Any> = [.epsilon: Double(0.4), .learning_rate: Double(0.0001), .gamma: Double(0.9), .timeIntervalBackgroundMode: 1*60]

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
            if [8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state[4]) && Double.random(in: 0...1) < 0.8 {
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
        
        
    }
    @StateObject var delegate = NotificationDelegate()
    
    var body: some Scene {
            WindowGroup {
                ContentView(qnet: qnet, sensor: newSensor, database: loadDatabase("database.json")).onAppear(perform: initializeRL)
            }
        }
        
        func initializeRL() {
            print("App opened")
            qnet.observe(.both)
            let metricManager = MXMetricManager.shared
            metricManager.add(appleRLMetrics)
            
        }
}




