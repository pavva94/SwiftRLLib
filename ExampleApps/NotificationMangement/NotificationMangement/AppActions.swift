//
//  AppActions.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import Foundation
import SwiftRL
import UserNotifications


open class Send: Action {
    public var id: Int = 0

    public init() {}

    public var description: String = "SendNotification"

    public func exec() {
        print("SENDIT")
        if !useSimulator {
            let content = UNMutableNotificationContent()
            content.title = "Do you want a notification?"
            content.subtitle = "I know you want me"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "Notification.Category.Read"

            // Define the custom actions.
            let acceptAction = UNNotificationAction(identifier: "Read",
                  title: "Read",
                  options: [])
    //        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
    //              title: "Decline",
    //              options: [])
            // Define the notification type
            let notificationInviteCategory =
                  UNNotificationCategory(identifier: "Notification.Category.Read",
                  actions: [acceptAction, ],
                  intentIdentifiers: [],
                  options: .customDismissAction
            )

            print("1")
            // Register the notification type.
            UNUserNotificationCenter.current().setNotificationCategories([notificationInviteCategory])

            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // add our notification request
            // Register the notification type.
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                }
            }
        } else {
            print("Sara readed??")
            let state = environment.read()
            let hourRL = state[2]
            let minuteRL = state[3]
            let clock = [hourRL, minuteRL]

            if [6.0, 7.0, 8.0, 12.0, 13.0, 14.0, 18.0, 19.0, 20.0].contains(hourRL)  {
                if Double.random(in: 0...1) < 0.99 {
                    print("READED")
                    newSensorStack.addRead(clock: clock)
                } else {
                    newSensorStack.addNotRead(clock: clock)
                }
            } else if Double.random(in: 0...1) < 0.35 {
                newSensorStack.addRead(clock: clock)
                print("FORTUNE READ")
            } else {
                newSensorStack.addNotRead(clock: clock)
            }
        }
    }
}


open class NotSend: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "NOTSendNotification"
    
    public func exec() {
       print("Do not send the notification")
    }
}
