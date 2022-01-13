//
//  ContentView.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import SwiftUI
import UserNotifications
import AppleRL
import BackgroundTasks

struct ContentView: View {
    var qnet: DeepQNetwork
    var sensor: Sensor
    var database: [DatabaseData]
    var body: some View {
        VStack {
            Button("Request Permission") {
                // first
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                BGTaskScheduler.shared.cancelAllTaskRequests()
                qnet.scheduleBackgroundSensorFetch()
                qnet.scheduleBackgroundTrainingFetch()
                
            }
            
            NavigationView {
                List(database) { data in
                    NavigationLink {
                        Detail(data: data, qnet: qnet, actionsArray: actionsArray)
                    } label: {
                        Row(data: data)
                    }
                }
                .navigationTitle("Agent's Actions Preview")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
