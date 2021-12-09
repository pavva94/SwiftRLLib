/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The top-level definition of the Landmarks app.
*/

import SwiftUI
import AppleRL
import os
import BackgroundTasks

var databaseDataApp: [DatabaseData] = loadDatabase("database.json")
let defaultLogger = Logger()

@main
struct LandmarksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("INITIAL?")
//                    qnet.scheduleBackgroundSensorFetch()
//                    qnet.scheduleBackgroundTrainingFetch()
                    
                    
                    if backgroundMode {
                        BGTaskScheduler.shared.cancelAllTaskRequests()

                        BGTaskScheduler.shared.register(
                          forTaskWithIdentifier: "com.AppleRL.backgroundListen",
                          using: nil) { (task) in
                            defaultLogger.log("Task handler")
                              qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
                        }

                        BGTaskScheduler.shared.register(
                          forTaskWithIdentifier: "com.AppleRL.backgroundTrain",
                          using: nil) { (task) in
                            defaultLogger.log("Task handler")
                              qnet.handleTrainingTask(task: task as! BGProcessingTask)
                        }
                    } else {
                        qnet.startListen(interval: 10)
                        qnet.startTrain(interval: 50)
                    }
                }
        }
    }
}
