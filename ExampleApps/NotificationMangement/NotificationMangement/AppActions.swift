//
//  AppActions.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 12/01/22.
//

import Foundation
import AppleRL
import UserNotifications


open class ReadNotificationSensor: Sensor {
    
    let defaults = UserDefaults.standard
    var readedCounter: Double = 0
    var sendedCounter: Double = 0
    
    
    init() {
        super.init(name: "readNotification", stateSize: 1)
        readedCounter = self.defaults.double(forKey: "readedCounter")
        sendedCounter = self.defaults.double(forKey: "sendedCounter")
    }
    
    open override func read() -> [Double] {
        
        print("readNotification \(self.readedCounter), \(self.sendedCounter)")
        if sendedCounter == 0.0 {
            return preprocessing(value: 0.0)
        } else {
            return preprocessing(value: self.readedCounter/self.sendedCounter)
        }
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
        
    }
    
    public func readReadCounter() -> Double {
        
        return self.readedCounter
    }
    
    public func readSendCounter() -> Double {
        return self.sendedCounter
    }
    
    public func addRead() {
        print("ADD READ")
        self.readedCounter += 1
        self.defaults.set(self.readedCounter, forKey: "readedCounter")
    }
    
    public func addSend() {
        print("ADD SEND")
        self.sendedCounter += 1
        self.defaults.set(self.sendedCounter, forKey: "sendedCounter")
    }
}

let newSensor = ReadNotificationSensor()

open class Send: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "SendNotification"
    
    public func exec() {
        print("SENDIT")
        let content = UNMutableNotificationContent()
        content.title = "Do you want a notification?"
        content.subtitle = "I know you want me"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "Notification.Category.Read"
        
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "Read",
              title: "Read",
              options: [.foreground])
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
        
        newSensor.addSend()
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
    
    public var description: String = "NOTSendNotification"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(BatterySimulator.getSimStep())")
            return Double(BatterySimulator.getSimStep()) * 10
        }
        
        // ["locked", "localization", "battery", "clock", "lowPowerMode", "readNotification"]
//        let lat = state[1]
//        let long = state[2]
//        let locked = state[0]
//        let battery = state[3]
//        let hourRL = state[4]
//        let minuteRL = state[5]
//        let lowPowerMode = state[6]
        let readNotification = state[7]
        
        
        let nextReadNotification = nextState[7]
        
        
        reward = nextReadNotification > readNotification ? +1 : 0
        
        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
//        reward += nextState[0] - battery
        
        print("Final reward: \(reward)")
        
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}
