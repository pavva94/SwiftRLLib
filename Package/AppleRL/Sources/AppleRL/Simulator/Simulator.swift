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
    
    private var screenValuesPer30Minutes: [Double]
    private var brightnessValuesPer30Minutes: [Double]
    
    init() {
        screenValuesPer30Minutes = [currentBattery]
        brightnessValuesPer30Minutes = [Double.random(in: 0...1)]
//        screenValuesPer30Minutes = []
//        for i in 0...48 {
//            screenValuesPer30Minutes.append(Double(100-Int(baseConsumption)*i))
//        }
    }
    
    func simulateBattery(battery: Double, params: Dictionary<String, Double>) -> Double {
        var accessoriesConsumption = 0.0
        print("screenValuesPer30Minutes: \(screenValuesPer30Minutes)")
        print("brightnessValuesPer30Minutes: \(brightnessValuesPer30Minutes)")
        for (key, value) in params {
            if paramsModificators.keys.contains(key) {
                print("\(key): \(paramsModificators[key]! * value)")
                accessoriesConsumption += paramsModificators[key]! * value
            }
            
        }
        currentBattery = screenValuesPer30Minutes[self.simStep]
        print("accessoriesConsumption \(accessoriesConsumption)")
        let newBatteryValue = Double(currentBattery) - (baseConsumption + accessoriesConsumption)
        screenValuesPer30Minutes.append(newBatteryValue)
        
        if self.currentBattery <= 0.0 || newBatteryValue <= 0.0 {
            reset()
            return 0.0
        }
        
        self.simStep += 1
        
        
        
        return newBatteryValue
    }
    
    open func actOverBrightness(value: Double) {
        brightnessValuesPer30Minutes.append(brightnessValuesPer30Minutes.last! - value)
    }
    
    func simulateBrightness() -> Double {
        return brightnessValuesPer30Minutes.last!
    }
    
    func reset() {
        self.simStep = 0
        self.currentBattery = 100
        print("Final battery log: \(screenValuesPer30Minutes)")
        screenValuesPer30Minutes = [100]
    }
}

public let BatterySimulator = Simulator()
