/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The top-level definition of the Landmarks app.
*/

import SwiftUI
import AppleRL
import os

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
                    qnet.scheduleBackgroundSensorFetch()
                    qnet.scheduleBackgroundTrainingFetch()
                }
        }
    }
}
