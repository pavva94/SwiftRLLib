//
//  Env.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit
import AVKit

open class Env {
    var admittedObservableData = [
        "battery",
        "volume",
        "orientation",
        "brightness",
//        "ambientLight",
        "clock",
        "date",
        "lowPowerMode",
        "location",
        "hour",
        "minute",
        "second",
        "altitude",
        "speed",
        "city",
        "country",
        "locked",
//        "proximity",
        "gyroscope",
        "barometer",
        
    ]
    
    let defaults = UserDefaults.standard

    private var observableData: [ObservableData]
    private var actions: [Action]
    private var rewards: [Reward]
    private var actionSize: Int
    private var stateSize: Int
    
    /// Initialize the Env with given ObsevrableData, Actions and Rewards
    /// Passing "All" into the observableData parameter will select all ObservableData implemented
    public init(observableData: [String], actions: [Action], rewards: [Reward], actionSize: Int) {
        
        self.actionSize = actionSize
        self.stateSize = 0
        self.observableData = []
        self.actions = actions
        self.rewards = rewards
        
        var observableDataList: [String] = []
        
        if !observableData.isEmpty && observableData[0] == "all" {
            observableDataList = admittedObservableData
        } else {
            observableDataList = observableData
        }
        
        for st in observableDataList {
            if !self.admittedObservableData.contains(st) {
                defaultLogger.log("ObservableData not allowed: \(st)")
                continue
            }
            var sens: ObservableData
            switch st {
            case "battery":
                UIDevice.current.isBatteryMonitoringEnabled = true
                sens = BatterySensor()
               
            case "volume":
                sens = VolumeSensor()
               
            case "orientation":
                sens = OrientationSensor()
               
            case "brightness":
                sens = BrightnessSensor()
               
            case "ambientLight":
                sens = AmbientLightSensor()
               
            case "clock":
                sens = ClockSensor()
                
            case "hour":
                sens = HourSensor()
                
            case "minute":
                sens = MinuteSensor()
                
            case "second":
                sens = SecondSensor()
               
            case "date":
                sens = DateSensor()
               
            case "lowPowerMode":
                sens = LowPowerModeSensor()
                
            case "location":
                sens = LocationSensor()
            
            case "speed":
                sens = SpeedSensor()
                
            case "altitude":
                sens = AltitudeSensor()
                
            case "locked":
                sens = LockedSensor()
               
            default:
                defaultLogger.log("Sensor not valid: \(st)")
                continue
            }
            
            self.observableData.append(sens)
            self.stateSize += sens.stateSize
            
        }
    }
    
    // Get the action size of the Environment, set by user
    open func getActionSize() -> Int {
        return self.actionSize
    }
    
    // Get the state size of the environment
    open func getStateSize() -> Int {
        return self.stateSize
    }
    
    // Add an ObservableData to the list, in the last position
    open func addObservableData(s: ObservableData) {
        self.admittedObservableData.append(s.name)
        self.observableData.append(s)
        self.stateSize += s.stateSize
    }
    
    // Call the read() func for each ObsevrableData given
    open func read() -> [Double] {
        var data: [Double] = []
        if useSimulator {
            var params: Dictionary<String, Double> = [:]
            
            for s in self.observableData {
                params[s.name] = s.read()[0]
                if s.name == "brightness" {
                    let val = BatterySimulator.simulateBrightness()
                    params[s.name] = val
                    continue
                }
            }
            
            // if battery is under zero then it is the final state
            let batteryValue = BatterySimulator.simulateBattery(params: params)
            if batteryValue <= 0.0 {
                return []
            }
            
            for s in self.observableData {
                print(s)
                if s.name == "battery" {
                    data.append(batteryValue)
                    continue
                }
                let readedData = s.read()
                for sd in readedData {
                    data.append(sd.customRound(.toNearestOrAwayFromZero))
                }
            }
            
            print("params \(params)")
        } else {
            for s in self.observableData {
                print(s)
                let readedData = s.read()
                for sd in readedData {
                    data.append(sd.customRound(.toNearestOrAwayFromZero))
                }
            }
            print("Env Listen: \(data)")
        }
        return data
    }
    
    /// Function that execute the exec() func of the action choose
    open func act(state: [Double], action: Int) -> Void {
        // here define the action, selected by the id number
        // Be sure to set an id to each action
        // search action based on Id
        
        var actionFound = false
        for savedAction in self.actions {
            if savedAction.id == action {
                savedAction.exec()
                actionFound = true
                break
            }
        }
        
        if !actionFound {
            defaultLogger.log("Action not found: \(action)")
        } else {
            defaultLogger.log("Action found: \(action)")
        }
    }
    
    /// Function that execute the exec() func of the reward
    open func reward(state: [Double], action: Int, nextState: [Double]) -> Double {
        
        var totalReward: Double = 0
        for savedReward in self.rewards {
            totalReward += savedReward.exec(state: state, action: action, nextState: nextState)
        }
        
        return totalReward.customRound(.toNearestOrAwayFromZero)
    }

    
}
