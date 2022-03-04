//
//  AppActions.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import Foundation
import AppleRL
import UserNotifications


//open class Send: Action {
//    public var id: Int = 0
//
//    public init() {}
//
//    public var description: String = "SendNotification"
//
//    public func exec() {
//        print("SENDIT")
//        if !useSimulator {
//            let content = UNMutableNotificationContent()
//            content.title = "Do you want a notification?"
//            content.subtitle = "I know you want me"
//            content.sound = UNNotificationSound.default
//            content.categoryIdentifier = "Notification.Category.Read"
//
//            // Define the custom actions.
//            let acceptAction = UNNotificationAction(identifier: "Read",
//                  title: "Read",
//                  options: [])
//    //        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
//    //              title: "Decline",
//    //              options: [])
//            // Define the notification type
//            let notificationInviteCategory =
//                  UNNotificationCategory(identifier: "Notification.Category.Read",
//                  actions: [acceptAction, ],
//                  intentIdentifiers: [],
//                  options: .customDismissAction
//            )
//
//            print("1")
//            // Register the notification type.
//            UNUserNotificationCenter.current().setNotificationCategories([notificationInviteCategory])
//
//            // show this notification five seconds from now
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//            // choose a random identifier
//            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//            // add our notification request
//            // Register the notification type.
//            UNUserNotificationCenter.current().add(request) { (error) in
//                if let error = error {
//                    print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
//                }
//            }
//        } else {
//            print("Sara readed??")
//            let state = environment.read()
//            let hourRL = state[2]
//            let minuteRL = state[3]
//            let clock = [hourRL, minuteRL]
//
//            if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//                if Double.random(in: 0...1) < 0.95 {
//                    print("READED")
//                    newSensor.addRead(clock: clock)
//                } else {
//                    newSensor.addNotRead(clock: clock)
//                }
//            } else if Double.random(in: 0...1) < 0.15 {
//                newSensor.addRead(clock: clock)
//                print("FORTUNE READ")
//            } else {
//                newSensor.addNotRead(clock: clock)
//            }
//        }
//    }
//}


open class NotSend: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "NOTSendNotification"
    
    public func exec() {
       print("Do not send the notification")
    }
}



open class ActionStack: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "ActionStack"
    
    public func exec() {
        print("Sara readed??")
        let state = environmentNew.read(fromAction: true)
        let hourRL = state[2]
        let minuteRL = state[3]
        let clock = [hourRL, minuteRL]
        
        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
            if Double.random(in: 0...1) < 0.99 {
                print("READED")
                newSensorStack.addRead(clock: clock)
            } else {
                newSensorStack.addNotRead(clock: clock)
            }
        } else if Double.random(in: 0...1) < 0.05 {
            newSensorStack.addRead(clock: clock)
            print("FORTUNE READ")
        } else {
            newSensorStack.addNotRead(clock: clock)
        }
    }
}

open class ActionStack2: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "ActionStack"
    
    public func exec() {
        print("Sara readed??")
        let state = environmentNew2.read(fromAction: true)
        let hourRL = state[2]
        let minuteRL = state[3]
        let clock = [hourRL, minuteRL]
        
        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
            if Double.random(in: 0...1) < 0.99 {
                print("READED")
                newSensorStack2.addRead(clock: clock)
            } else {
                newSensorStack2.addNotRead(clock: clock)
            }
        } else if Double.random(in: 0...1) < 0.05 {
            newSensorStack2.addRead(clock: clock)
            print("FORTUNE READ")
        } else {
            newSensorStack2.addNotRead(clock: clock)
        }
    }
}

//open class Action1: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action1"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensor.addRead(clock: clock)
//            } else {
//                newSensor.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensor.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensor.addNotRead(clock: clock)
//        }
//    }
//}
//
//open class Action2: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action2"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment2.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensorStack2.addRead(clock: clock)
//            } else {
//                newSensorStack2.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensorStack2.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensorStack2.addNotRead(clock: clock)
//        }
//    }
//}
//
//open class Action3: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action3"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment3.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensorStack3.addRead(clock: clock)
//            } else {
//                newSensorStack3.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensorStack3.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensorStack3.addNotRead(clock: clock)
//        }
//    }
//}
//
//open class Action4: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action4"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment4.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensorStack4.addRead(clock: clock)
//            } else {
//                newSensorStack4.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensorStack4.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensorStack4.addNotRead(clock: clock)
//        }
//    }
//}
//
//open class Action5: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action5"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment5.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensorStack5.addRead(clock: clock)
//            } else {
//                newSensorStack5.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensorStack5.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensorStack5.addNotRead(clock: clock)
//        }
//    }
//}
////
//open class Action6: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action6"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment6.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensorStack6.addRead(clock: clock)
//            } else {
//                newSensorStack6.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensorStack6.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensorStack6.addNotRead(clock: clock)
//        }
//    }
//}
//
//open class Action7: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Action7"
//    
//    public func exec() {
//        print("Sara readed??")
//        let state = environment7.read(fromAction: true)
//        let hourRL = state[2]
//        let minuteRL = state[3]
//        let clock = [hourRL, minuteRL]
//        
//        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
//            if Double.random(in: 0...1) < 0.95 {
//                print("READED")
//                newSensorStack7.addRead(clock: clock)
//            } else {
//                newSensorStack7.addNotRead(clock: clock)
//            }
//        } else if Double.random(in: 0...1) < 0.15 {
//            newSensorStack7.addRead(clock: clock)
//            print("FORTUNE READ")
//        } else {
//            newSensorStack7.addNotRead(clock: clock)
//        }
//    }
//}
////
////open class ActionQL: Action {
////    public var id: Int = 0
////    
////    public init() {}
////    
////    public var description: String = "ActionQL"
////    
////    public func exec() {
////        print("Sara readed??")
////        let state = environmentQL.read(fromAction: true)
////        let hourRL = state[2]
////        let minuteRL = state[3]
////        let clock = [hourRL, minuteRL]
////        
////        if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(hourRL)  {
////            if Double.random(in: 0...1) < 0.95 {
////                print("READED")
////                newSensorQL.addRead(clock: clock)
////            } else {
////                newSensorQL.addNotRead(clock: clock)
////            }
////        } else if Double.random(in: 0...1) < 0.15 {
////            newSensorQL.addRead(clock: clock)
////            print("FORTUNE READ")
////        } else {
////            newSensorQL.addNotRead(clock: clock)
////        }
////    }
////}
