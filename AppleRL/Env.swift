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

    
]

public class Env {
    var timerListen : Timer? = nil {
            willSet {
                timerListen?.invalidate()
            }
        }
    
    // save the sensors to read, defined by the user
    var sensors: [Sensor] = []
    init(s: [String]) {
        // TODO check the sensors with a list of selected/usable sensors
        for st in s {
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
                sensors.append(Orientation())
            default:
                print("Sensor not valid: " + String(st))
            }
            
        }
    }
    
    // expose a read function over all the sensors
    func read() -> [Int] {
        var data: [Int] = []
        
        for s in sensors {
            data.append(s.read())
        }
        
        return data
    }
    
    func reward(fun: @escaping () -> Int) -> Int{
        return fun()
    }
    
    func act(fun: @escaping () -> Void) {
        fun()
    }
    
    @objc func store(storeFun: @escaping () -> Void) {
        
    }
    
    
    func startListen(interval: Int) {
        stopListen()
        guard self.timerListen == nil else { return }
        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.store), userInfo: nil, repeats: true)
    }

    func stopListen() {
        guard timerListen != nil else { return }
        timerListen?.invalidate()
        timerListen = nil
    }
    
}
