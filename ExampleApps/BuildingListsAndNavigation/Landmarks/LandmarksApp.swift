/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The top-level definition of the Landmarks app.
*/

import SwiftUI
import AppleRL
import os
import BackgroundTasks
import CoreML

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
                    
                    BGTaskScheduler.shared.cancelAllTaskRequests()
                    
                    func onlythistime() {
                        do {
                            var i = 0
                        for d in databaseDataApp {
                            defaultLogger.debug("data \(i) : \(d.state), \(d.action)")
                            // se lo screen è spento allora solo leaveasitis
                            if d.state[0] <= 0.1 {
                                if d.action == 1 {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: 1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("+1")
                                } else {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: -1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("-1")
                                }
                            } else if d.state[1] <= 0.2 && d.state[0] >= 0.3 { // se la batteria è scarica e la luminosità è sopra i 0.3 solo descrese
                                if d.action == 0 {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: 1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("+1")
                                } else {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: -1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("-1")
                                }
                            } else if d.state[0] >= 0.3 && d.state[2] >= 22  && d.state[3] >= 30 { // se è notte (>22.30) e la luminosità è sopra i 0.3 solo descrese
                                if d.action == 0 {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: 1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("+1")
                                } else {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: -1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("-1")
                                }
                            }  else if d.state[0] <= 0.3 && d.state[2] >= 11  && d.state[3] >= 30  && d.state[2] <= 17  && d.state[3] >= 30 { // se è giorno (>12.30, <17.30) e la luminosità è sotto i 0.3 solo increase
                                if d.action == 2 {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: 1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("+1")
                                } else {
                                    qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: -1.0, nextState: try MLMultiArray(d.state))
                                    defaultLogger.debug("-1")
                                }
                            } else {
                                qnet.storeAndDelete(id: d.id, state: try MLMultiArray(d.state), action: d.action, reward: 0.0, nextState: try MLMultiArray(d.state))
                                defaultLogger.debug("0")
                            }
                            i += 1
                        }
                        } catch {
                            print("only this time failed \(error.localizedDescription)")
                        }
                    }
                    
                    
                    if backgroundMode {
//                        onlythistime()
//                        qnet.scheduleBackgroundSensorFetch()
//                        qnet.scheduleBackgroundTrainingFetch()

                    } //else {
//                        qnet.startListen(interval: 10)
//                        qnet.startTrain(interval: 50)
//                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        print("Moving back to the foreground!")
                        databaseDataApp = loadDatabase("database.json")
                    
                    }
        }
    }
}
