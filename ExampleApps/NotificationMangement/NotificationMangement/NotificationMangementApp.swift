//
//  NotificationMangementApp.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import SwiftUI
import BackgroundTasks
import AppleRL


class Env1: Env {
    override func reward(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(BatterySimulator.getSimStep())")
            return Double(BatterySimulator.getSimStep()) * 10
        }
        
        // ["locked", "localization", "battery", "clock", "lowPowerMode", "readNotification"]
//        let lat = state[1]
//        let long = state[2]
//        let locked = state[0]
//        let battery = state[3]
//        let hourRL = state[4]
//        let minuteRL = state[5]
//        let lowPowerMode = state[6]
        let readNotification = state[7]
        
        
        let nextReadNotification = nextState[7]
        
        
        reward = nextReadNotification > readNotification ? +1 : 0
        
        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
//        reward += nextState[0] - battery
        
        print("Final reward: \(reward)")
        
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}

//let newSensor = ReadNotificationSensor()
let actionsArray: [Action] = [Send(), NotSend()]
var environment: Env = Env1(sensors: ["locked", "location", "battery", "clock", "lowPowerMode"], actions: actionsArray, actionSize: 2)
let params: Dictionary<ModelParameters, Any> = [.epsilon: Double(0.4), .learning_rate: Double(0.0001), .gamma: Double(0.9), .timeIntervalBackgroundMode: Double(1*60)]
let qnet: DeepQNetwork = DeepQNetwork(env: environment, parameters: params)
var firstOpen = true

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        environment.addSensor(s: newSensor)
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
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
            // If you are receiving a notification message while your app is in the background,
            // this callback will not be fired till the user taps on the notification launching the application.
            // TODO: Handle data of notification
            
            // With swizzling disabled you must let Messaging know about the message, for Analytics
            // Messaging.messaging().appDidReceiveMessage(userInfo)
            
            // Print message ID.
//            if let messageID = userInfo[gcmMessageIDKey] {
//                print("Message ID: \(messageID)")
//            }
            
            // Print full message.
            print(userInfo)
            newSensor.addRead()
        }
    }

@main
struct NotificationMangementApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
        
    init(){
        
        
    }
    
    var body: some Scene {
            WindowGroup {
                ContentView(qnet: qnet, sensor: newSensor, database: loadDatabase("database.json")).onAppear(perform: initializeRL)
            }
        }
        
        func initializeRL() {
            print("App opened")
            if firstOpen {
                qnet.startListen(interval: 30)
                qnet.startTrain(interval: 10*60)
                BGTaskScheduler.shared.cancelAllTaskRequests()
                qnet.scheduleBackgroundSensorFetch()
                qnet.scheduleBackgroundTrainingFetch()
//                print("------------- \(qnet.getDeafultModelURL())")
//                Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getDeafultModelURL())
//                print("------------- \(qnet.getModelURL())")
//                Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
//                print("-------------")
                }
            firstOpen = false
            
        }
}
