/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The top-level definition of the Landmarks app.
*/

import SwiftUI
import AppleRL

let databasePath: String = "database.json"
var databaseData: [DatabaseData] = loadDatabase(databasePath)

@main
struct LandmarksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("CACCA")
                    qnet.scheduleBackgroundSensorFetch()
                }
        }
    }
}
