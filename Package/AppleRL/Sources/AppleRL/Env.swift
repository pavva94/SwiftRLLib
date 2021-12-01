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
        "ambientLight",
        // not implemented yet
        "proximity",
        "gyroscope",
        "barometer",
        
    ]
    
    let defaults = UserDefaults.standard
    var idCounter: Int
    
    private var sensors: [Sensor]
    private var actions: [Action]
    private var actionSize: Int
    private var stateSize: Int
    
    
    public init(sensors: [String], actions: [Action], actionSize: Int, stateSize: Int) {
        
        self.actionSize = actionSize
        self.stateSize = stateSize
        self.sensors = []
        self.actions = actions
        self.idCounter = self.defaults.integer(forKey: "idCounter")
        
        // TODO check the sensors with a list of selected/usable sensors
        for st in sensors {
            if !self.admittedSensors.contains(st) {
                print("Sensor not allowed: \(st)")
                continue
            }
            switch st {
            case "battery":
                UIDevice.current.isBatteryMonitoringEnabled = true
                self.sensors.append(Battery())
            case "volume":
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print("Error on Volume")
                }
                // AVAudioSession.sharedInstance().outputVolume
            case "orientation":
                self.sensors.append(Orientation())
            case "brightness":
                self.sensors.append(Brightness())
            case "ambientLight":
                self.sensors.append(AmbientLight())
            default:
                print("Sensor not valid: " + String(st))
            }
            
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
    }
    
    open func read() -> [Double] {
        var data: [Double] = []
        
        for s in self.sensors {
            data.append(s.read())
        }
        
        return data
    }
    
    open func act(state: [Double], action: Int) -> Void { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to se an id to each action
        // search action based on Id
        
        var actionFound = false
        for savedAction in self.actions {
            if savedAction.id == action{
                savedAction.exec()
                actionFound = true
                break
            }
        }
        
        if !actionFound {
            print("Action not found")
        } else {
            let data: DatabaseData = DatabaseData(id: idCounter, state: state, action: action, reward: 0.0)
            manageDatabase(data, path: databasePath)
            self.idCounter += 1
            self.defaults.set(idCounter, forKey: "idCounter")
            print("database saved, idCounter \(self.idCounter)")
        }
    }
    
    open func reward(state: [Double], action: Int) -> Double {
        fatalError("reward() has not been implemented")
    }

    
}
