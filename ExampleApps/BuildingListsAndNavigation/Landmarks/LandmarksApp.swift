/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The top-level definition of the Landmarks app.
*/

import SwiftUI

@main
struct LandmarksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
