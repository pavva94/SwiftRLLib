//
//  AppActions.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import Foundation
import AppleRL
import UserNotifications


open class ReadNotificationSensor: ObservableData {
    
    let defaults = UserDefaults.standard
    var lastReadedCounter: [Double] = [0]
    var readedCounter: [Double] = [0]
    let sendedCounter: Double = 5
    
    
    init() {
        super.init(name: "readNotification", stateSize: 1)
    }
    
    open override func read() -> [Double] {
        
        print("readNotification \(self.readedCounter), \(self.sendedCounter)")
        if sendedCounter == 0.0 {
            return preprocessing(value: 0.0)
        } else {
            return preprocessing(value: self.readedCounter.reduce(0, +)/self.sendedCounter)
        }
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
        
    }
    
    public func readReadCounter() -> Double {
        return self.readedCounter.reduce(0, +)
    }
    
    public func readLastReadCounter() -> Double {
        return self.lastReadedCounter.reduce(0, +)
    }
    
    public func readSendCounter() -> Double {
        return self.sendedCounter
    }
    
    public func addRead() {
        print("ADD READ")
        self.lastReadedCounter = self.readedCounter
        if self.readedCounter.count < 5 {
            self.readedCounter.append(1)
        } else {
            self.readedCounter.remove(at: 0)
            self.readedCounter.append(1)
        }
    }
    public func addNotRead() {
        print("ADD READ")
        self.lastReadedCounter = self.readedCounter
        if self.readedCounter.count < 5 {
            self.readedCounter.append(0)
        } else {
            self.readedCounter.remove(at: 0)
            self.readedCounter.append(0)
        }
    }
}

let newSensor = ReadNotificationSensor()

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
            if [7.0, 8.0, 12.0, 13.0, 18.0, 19.0, 20.0].contains(state[2])  {
                if Double.random(in: 0...1) < 0.95 {
                    print("READED")
                    newSensor.addRead()
                } else {
                    newSensor.addNotRead()
                }
            } else if Double.random(in: 0...1) < 0.25{
                newSensor.addRead()
            } else {
                newSensor.addNotRead()
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


open class ReadSendRatio: Reward {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "ReadSendRatio"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        // ["locked", "localization", "battery", "clock", "lowPowerMode", "readNotification"]
//        let lat = state[1]
//        let long = state[2]
//        let locked = state[0]
//        let battery = state[3]
//        let hourRL = state[4]
//        let minuteRL = state[5]
//        let lowPowerMode = state[6]
//        let readNotification = state[7]
//
//
//        let nextReadNotification = nextState[7]
        
        
//        reward = nextReadNotification > readNotification ? +1 : 0
       
        // if the agent send the notification, reward him with +1 if the user read the notification or -1 otherwise
        if action == 0 {
            reward = newSensor.readReadCounter() > newSensor.readLastReadCounter() ? +1 : -1
        }
        
        print("Final reward: \(reward)")
        
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}
