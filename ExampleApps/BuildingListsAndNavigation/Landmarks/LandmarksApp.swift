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
                    print("App Closed, background mode: \(backgroundMode)")
//                    qnet.scheduleBackgroundSensorFetch()
//                    qnet.scheduleBackgroundTrainingFetch()
                    
                    
                    if backgroundMode {
                        qnet.scheduleBackgroundSensorFetch()
                        qnet.scheduleBackgroundTrainingFetch()
                    } //else {
//                        qnet.startListen(interval: 10)
//                        qnet.startTrain(interval: 50)
//                    }
                }
        }
    }
}
