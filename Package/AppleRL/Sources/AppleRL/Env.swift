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
    var admittedSensors = [
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
//        "proximity",
        "gyroscope",
        "barometer",
        
    ]
    
    let defaults = UserDefaults.standard
    var idCounter: Int
    
    private var sensors: [Sensor]
    private var actions: [Action]
    private var actionSize: Int
    private var stateSize: Int
    
    
    public init(sensors: [String], actions: [Action], actionSize: Int) {
        
        self.actionSize = actionSize
        self.stateSize = 0
        self.sensors = []
        self.actions = actions
        self.idCounter = self.defaults.integer(forKey: "idCounter")
        
        var sensorsList: [String] = []
        
        if !sensors.isEmpty && sensors[0] == "all" {
            sensorsList = admittedSensors
        } else {
            sensorsList = sensors
        }
        
        // TODO check the sensors with a list of selected/usable sensors
        for st in sensorsList {
            if !self.admittedSensors.contains(st) {
                defaultLogger.log("Sensor not allowed: \(st)")
                continue
            }
            var sens: Sensor
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
               
            default:
                defaultLogger.log("Sensor not valid: \(st)")
                continue
            }
            
            self.sensors.append(sens)
            self.stateSize += sens.stateSize
            
        }
    }
    
    open func getActionSize() -> Int {
        return self.actionSize
    }
    
    open func getStateSize() -> Int {
        return self.stateSize
    }
    
    open func addSensor(s: Sensor) {
        self.admittedSensors.append(s.name)
        self.sensors.append(s)
        self.stateSize += s.stateSize
    }
    
    open func read() -> [Double] {
        var data: [Double] = []
        
        var params: Dictionary<String, Double> = [:]
        
        for s in self.sensors {
            params[s.name] = s.read()[0]
        }
        
        for s in self.sensors {
            print(s)
            if s.name == "battery" {
                data.append(BatterySimulator.simulateBattery(battery: 0.0, params: params))
                continue
            }
            if s.name == "brightness" {
                data.append(BatterySimulator.simulateBrightness())
                continue
            }
            let sensorData = s.read()
            for sd in sensorData {
                data.append(sd)
            }
        }
        
        return data
    }
    
open func act(state: [Double], action: Int) -> Void { // return the reward that is always int?
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
//            let data: DatabaseData = DatabaseData(id: idCounter, state: state, action: action, reward: 0.0)
//            addDataToDatabase(data, databasePath)
//            self.idCounter += 1
//            self.defaults.set(idCounter, forKey: "idCounter")
//            defaultLogger.log("database saved, idCounter \(self.idCounter)")
            defaultLogger.log("Action found: \(action)")
        }
    }
    
    open func reward(state: [Double], action: Int, nextState: [Double]) -> Double {
        defaultLogger.error("reward() has not been implemented")
        return 0.0
    }

    
}
