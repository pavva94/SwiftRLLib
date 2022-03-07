//
//  Env.swift
//  SwiftRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit
import AVKit

/// Customizable Environment
open class Env {
    /// Observable data allowed by default
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
    
    /// User default
    let defaults = UserDefaults.standard
    /// Instance of the simulator
    public let simulator: Simulator
    /// List of active observable data
    private var observableData: [ObservableData]
    /// List of active actions
    private var actions: [Action]
    /// LIst of active rewards
    private var rewards: [Reward]
    /// Action size
    private var actionSize: Int
    /// State size
    private var stateSize: Int
    
    /// Initialize the Env with given ObsevrableData, Actions and Rewards
    /// Passing "All" into the observableData parameter will select all ObservableData implemented
    public init(observableData: [String], actions: [Action], rewards: [Reward], actionSize: Int) {
        
        self.actionSize = actionSize
        self.stateSize = 0
        self.observableData = []
        self.actions = actions
        self.rewards = rewards
        self.simulator = Simulator()
        
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
               
//            case "ambientLight":
//                sens = AmbientLightSensor()
//               
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
    
    /// Get the action size of the Environment, set by user
    open func getActionSize() -> Int {
        return self.actionSize
    }
    
    /// Get the state size of the environment
    open func getStateSize() -> Int {
        return self.stateSize
    }
    
    /// Add an ObservableData to the list, in the last position
    open func addObservableData(s: ObservableData) {
        self.admittedObservableData.append(s.name)
        self.observableData.append(s)
        self.stateSize += s.stateSize
    }
    
    private var oldBattery = 0.0
    
    /// Call the read() func for each ObsevrableData given
    open func read(fromAction: Bool = false) -> [Double] {
        var data: [Double] = []
        if useSimulator {
            // data for the simulator
            var params: Dictionary<String, Double> = [:]
            // data for the sensors
            var dataTemp: [Double] = []
            
            // save as dictionary the observed values for the simulator
            for s in self.observableData {
                let obsVal = s.read([])
                
                if obsVal == [] {
                    dataTemp.append(0.0)
                    continue
                }
                
                if s.name == "brightness" {
                    let val = self.simulator.simulateBrightness()
                    params[s.name] = val
                    continue
                }
                
                if s.name == "clock" {
                    let val = self.simulator.simulateClock()
                    params[s.name] = val[0]
                    dataTemp.append(val[0])
                    dataTemp.append(val[1])
                    continue
                }
                for sd in obsVal {
                    dataTemp.append(sd.customRound(.toNearestOrAwayFromZero))
                }
                params[s.name] = obsVal[0]
            }
            
            // simulate some values
            let clockValue = self.simulator.simulateClock()
            var batteryValue = 0.0
            if !fromAction {
                batteryValue = self.simulator.simulateBattery(params: params)
                oldBattery = batteryValue
            } else {
                batteryValue = oldBattery
            }
            let brightnessValue = self.simulator.simulateBrightness()
            
            // override battery value TODO MODIFY IMMIDIATELY AFTER TEST
            dataTemp[0] = batteryValue
            
            for s in self.observableData {
//                print(s)
                // use simulated data
                if s.name == "battery" {
                    // if battery is under zero then it is the final state, set the battery value to zero
                    if batteryValue <= 0.0 {
                        batteryValue = 0.0
                    }
                    data.append(batteryValue)
                    continue
                }
                if s.name == "clock" {
                    data.append(clockValue[0])
                    data.append(clockValue[1])
                    continue
                }
                if s.name == "brightness" {
                    data.append(brightnessValue)
                    continue
                }
                let readedData = s.read(dataTemp)
                for sd in readedData {
                    data.append(sd.customRound(.toNearestOrAwayFromZero))
                }
            }
            
            print("params \(params)")
            print("data \(data)")
        } else {
            // data for the sensors
            var dataTemp: [Double] = []
            for s in self.observableData {
//                print(s)
                let readedData = s.read([]) 
                for sd in readedData {
                    dataTemp.append(sd.customRound(.toNearestOrAwayFromZero))
                }
            }
            
            for s in self.observableData {
                print(s)
                let readedData = s.read(dataTemp)
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
