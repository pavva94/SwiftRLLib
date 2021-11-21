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
    // not implemented yet
    "proximity",
    "light",
    "gyroscope",
    "barometer",
    "brightness"
]

public class Env<S, A, R> {
    
    private var sensors: [Sensor<S>]
    private var action_size: Int
    private var state_size: Int
    
    init(sens: [String], action_size: Int, state_size: Int) {
        
        self.action_size = action_size
        self.state_size = state_size
        self.sensors = []
        
        // TODO check the sensors with a list of selected/usable sensors
        for st in sens {
            if !admittedSensors.contains(st) {
                print("Sensor not allowed: \(st)")
                continue
            }
            switch st {
            case "battery":
                assert(UIDevice.current.isBatteryMonitoringEnabled)
                // UIDevice.current.batteryLevel * 100
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
            default:
                print("Sensor not valid: " + String(st))
            }
            
        }
    }
    
    func get_action_size() -> Int {
        return self.action_size
    }
    
    func get_state_size() -> Int {
        return self.state_size
    }
    
    func addSensor(s: Sensor<S>) {
        sensors.append(s)
    }
    
    func read() -> [S] {
        var data: [S] = []
        
        for s in sensors {
            data.append(s.read())
        }
        
        return data
    }
    
    func act(s: [S], a: A) -> ([S], R) { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to se an id to each action
        fatalError("act() has not been implemented")
    }
    
    func reward(s: [S], a: A) -> R {
        fatalError("reward() has not been implemented")
    }
    
    
}
