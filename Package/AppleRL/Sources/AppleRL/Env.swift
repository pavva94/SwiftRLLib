//
//  Env.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit
import AVKit

let admittedSensors = [
    "battery",
    "volume",
    "orientation",
    "brightness",
    "ambientLight",
    // not implemented yet
    "proximity",
    "light",
    "gyroscope",
    "barometer",
    
]

open class Env<S, A, R> {
    
    private var sensors: [Sensor<S>]
    private var actionSize: Int
    private var stateSize: Int
    
    public init(sens: [String], actionSize: Int, stateSize: Int) {
        
        self.actionSize = actionSize
        self.stateSize = stateSize
        self.sensors = []
        
        // TODO check the sensors with a list of selected/usable sensors
        for st in sens {
            if !admittedSensors.contains(st) {
                print("Sensor not allowed: \(st)")
                continue
            }
            switch st {
            case "battery":
                UIDevice.current.isBatteryMonitoringEnabled = true
                sensors.append(Battery<S>())
            case "volume":
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print("Error on Volume")
                }
                // AVAudioSession.sharedInstance().outputVolume
            case "orientation":
                sensors.append(Orientation<S>())
            case "brightness":
                sensors.append(Brightness<S>())
            case "ambientLight":
                sensors.append(AmbientLight<S>())
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
    
    open func addSensor(s: Sensor<S>) {
        sensors.append(s)
    }
    
    open func read() -> [S] {
        var data: [S] = []
        
        for s in sensors {
            data.append(s.read())
        }
        
        return data
    }
    
    open func act(state: [S], action: A) -> ([S], R) { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to se an id to each action
        fatalError("act() has not been implemented")
    }
    
    open func reward(state: [S], action: A) -> R {
        fatalError("reward() has not been implemented")
    }
    
    
}
