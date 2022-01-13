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
    
    var readedCounter: Double = 0
    var sendedCounter: Double = 0
    
    init() {
        super.init(name: "readNotification", stateSize: 1)
    }
    
    open override func read() -> [Double] {
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
        print("ADD READ")
        return self.readedCounter
    }
    
    public func readSendCounter() -> Double {
        print("ADD SEND")
        return self.sendedCounter
    }
    
    public func addRead() {
        self.readedCounter += 1
    }
    
    public func addSend() {
        self.sendedCounter += 1
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
        content.title = "Feed the cat"
        content.subtitle = "It looks hungry"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
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
