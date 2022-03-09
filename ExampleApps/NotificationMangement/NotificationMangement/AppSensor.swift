//
//  AppSensor.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 20/02/22.
//

import Foundation
import SwiftRL
import UserNotifications


open class ReadNotificationSensor: ObservableData {
    
    let defaults = UserDefaults.standard
    var lastReadedCounter: [Double] = [0]
    var readedCounter: [Double] = [0]
    let sendedCounter: Double = 5
    
    
    init() {
        super.init(name: "readNotification", stateSize: 1)
    }
    
    open override func read(_ state: [Double] = []) -> [Double] {
        
        print("readNotification \(self.readedCounter), \(self.sendedCounter)")
        if sendedCounter == 0.0 {
            return [0.0]
        } else {
            return [self.readedCounter.reduce(0, +)/self.sendedCounter]
        }
    }
    
    public func readReadCounter(clock: [Double]) -> Double {
        return self.readedCounter.reduce(0, +)
    }
    
    public func readLastReadCounter(clock: [Double]) -> Double {
        return self.lastReadedCounter.reduce(0, +)
    }
    
    public func readSendCounter(clock: [Double]) -> Double {
        return self.sendedCounter
    }
    
    public func addRead(clock: [Double]) {
        print("ADD READ")
        self.lastReadedCounter = self.readedCounter
        if self.readedCounter.count < 5 {
            self.readedCounter.append(1)
        } else {
            self.readedCounter.remove(at: 0)
            self.readedCounter.append(1)
        }
    }
    public func addNotRead(clock: [Double]) {
        print("ADD NOT READ")
        self.lastReadedCounter = self.readedCounter
        if self.readedCounter.count < 5 {
            self.readedCounter.append(0)
        } else {
            self.readedCounter.remove(at: 0)
            self.readedCounter.append(0)
        }
    }
}

//let newSensor = ReadNotificationSensor()


open class ReadNotificationSensorStack: ObservableData {
    
    let defaults = UserDefaults.standard
    var lastReadedCounter: Dictionary<String, [Double]> = [:]
    var readedCounter: Dictionary<String, [Double]> = [:]
    var sendedCounter: Dictionary<String, [Double]> = [:]
    
    
    init() {
        super.init(name: "readNotification", stateSize: 1)
    }
    
    func manageReaded(clock: [Double]) -> String {
        let hourRL = clock[0]
        let minuteRL = clock[1]
        let clockIndex = String(Int(hourRL)) + String(Int(minuteRL))
        print("clockIndex \(clockIndex)")
        
        if !readedCounter.keys.contains(clockIndex) {
            self.readedCounter[clockIndex] = [0]
            self.lastReadedCounter[clockIndex] = [0]
            self.sendedCounter[clockIndex] = [1]
        }
        
        return clockIndex
            
    }
    
    open override func read(_ state: RLStateType = []) -> RLStateType {
        if state == [] {
            return [0]
        }
        
        let hourRL = state[2]
        var minuteRL = state[3]
        
        // restrict the range of minutes to 0 and  30
        if minuteRL>30.0 {
            minuteRL = 30.0
        } else {
            minuteRL = 0.0
        }
        
        let clockIndex = manageReaded(clock: [hourRL, minuteRL])
        print("readNotification \(self.readedCounter[clockIndex]), \(self.sendedCounter[clockIndex])")
        if sendedCounter[clockIndex]!.reduce(0, +) == 0.0 {
            return [0.0]
        } else {
            return [self.readedCounter[clockIndex]!.reduce(0, +)/5] // To simplify assume that 5 for each half hour was sent, or self.sendedCounter[clockIndex]!.reduce(0, +))
        }
    }
    
    public func readReadCounter(clock: [Double]) -> Double {
        let clockIndex = manageReaded(clock: clock)
        return self.readedCounter[clockIndex]!.reduce(0, +)
    }
    
    public func readLastReadCounter(clock: [Double]) -> Double {
        let clockIndex = manageReaded(clock: clock)
        return self.lastReadedCounter[clockIndex]!.reduce(0, +)
    }
    
    public func readSendCounter(clock: [Double]) -> Double {
        let clockIndex = manageReaded(clock: clock)
        return self.sendedCounter[clockIndex]!.reduce(0, +)
    }
    
    public func addSend(clock: [Double]) {
        let clockIndex = manageReaded(clock: clock)
        self.sendedCounter[clockIndex]!.append(1)
        
        print("ADD SEND STACK \(clock)")
        
        if self.sendedCounter[clockIndex]!.count < 5 {
            self.sendedCounter[clockIndex]!.append(1)
        } else {
            self.sendedCounter[clockIndex]!.remove(at: 0)
            self.sendedCounter[clockIndex]!.append(1)
        }
    }
    
    public func addRead(clock: [Double]) {
        print("ADD READ STACK \(clock)")
        let clockIndex = manageReaded(clock: clock)
        
        self.lastReadedCounter[clockIndex] = self.readedCounter[clockIndex]
        if self.readedCounter[clockIndex]!.count < 5 {
            self.readedCounter[clockIndex]!.append(1)
        } else {
            self.readedCounter[clockIndex]!.remove(at: 0)
            self.readedCounter[clockIndex]!.append(1)
        }
    }
    public func addNotRead(clock: [Double]) {
        print("ADD NOT READ STACK")
        let clockIndex = manageReaded(clock: clock)
        self.lastReadedCounter[clockIndex] = self.readedCounter[clockIndex]
        if self.readedCounter[clockIndex]!.count < 5 {
            self.readedCounter[clockIndex]!.append(0)
        } else {
            self.readedCounter[clockIndex]!.remove(at: 0)
            self.readedCounter[clockIndex]!.append(0)
        }
    }
}

//let newSensorStack = ReadNotificationSensorStack()
