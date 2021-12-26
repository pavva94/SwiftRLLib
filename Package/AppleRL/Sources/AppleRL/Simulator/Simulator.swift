//
//  Simulator.swift
//  
//
//  Created by Alessandro Pavesi on 15/12/21.
//

import Foundation

open class Simulator {
    
    private var simStep: Int = 0
    private let maxSimStep: Int = 24*2 // one day, divided by 30 minute
    public var maxBattery: Double = 100.0
    public var baseConsumption: Double = 2
    private var currentBattery: Double = 100.0
    private let paramsModificators: Dictionary<String, Double> = [
        "wifi": 3.0,
        "bluetooth": 2.0,
        "brightness": 10.0,
        "lowPowerMode": -5.0,
        
    ]
    
    private var batteryValuesPer30Minutes: [Double]
    private var brightnessValuesPer30Minutes: [Double]
    
    init() {
        batteryValuesPer30Minutes = [currentBattery]
        brightnessValuesPer30Minutes = [Double.random(in: 0...1).customRound(.toNearestOrAwayFromZero)]
    }
    
    func simulateBattery(params: Dictionary<String, Double>) -> Double {
        print(params)
        var accessoriesConsumption = 0.0
        print("batteryValuesPer30Minutes: \(batteryValuesPer30Minutes)")
        print("brightnessValuesPer30Minutes: \(brightnessValuesPer30Minutes)")
        for (key, value) in params {
            if paramsModificators.keys.contains(key) {
                print("\(key): \(paramsModificators[key]! * value)")
                accessoriesConsumption += paramsModificators[key]! * value
            }
            
        }
        currentBattery = batteryValuesPer30Minutes[self.simStep]
        print("accessoriesConsumption \(accessoriesConsumption)")
        let newBatteryValue = (Double(currentBattery) - (baseConsumption + accessoriesConsumption)).customRound(.toNearestOrAwayFromZero)
        batteryValuesPer30Minutes.append(newBatteryValue)
        
        if self.currentBattery <= 0.0 || newBatteryValue <= 0.0 {
            reset()
            return 0.0
        }
        
        self.simStep += 1
        
        
        
        return newBatteryValue
    }
    
    open func actOverBrightness(value: Double) {
        let newValue = (brightnessValuesPer30Minutes.last! - value).customRound(.toNearestOrAwayFromZero)
        if newValue > 1.0 {
            brightnessValuesPer30Minutes.append(1.0)
        } else if newValue < 0.0 {
            brightnessValuesPer30Minutes.append(0.0)
        } else {
            brightnessValuesPer30Minutes.append(newValue)
        }
        
    }
    
    func simulateBrightness() -> Double {
        return brightnessValuesPer30Minutes.last!
    }
    
    func reset() {
        self.simStep = 0
        self.currentBattery = 100
        print("Final battery log: \(batteryValuesPer30Minutes)")
        batteryValuesPer30Minutes = [100]
        brightnessValuesPer30Minutes = [Double.random(in: 0...1).customRound(.toNearestOrAwayFromZero)]
    }
}

public let BatterySimulator = Simulator()
