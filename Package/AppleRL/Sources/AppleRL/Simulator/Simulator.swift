//
//  Simulator.swift
//  
//
//  Created by Alessandro Pavesi on 15/12/21.
//

import Foundation

public class Simulator {
    
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
    
    private var valuesPer30Minutes: [Double]
    
    init() {
        valuesPer30Minutes = [currentBattery]
//        valuesPer30Minutes = []
//        for i in 0...48 {
//            valuesPer30Minutes.append(Double(100-Int(baseConsumption)*i))
//        }
    }
    
    func simulateBattery(battery: Double, params: Dictionary<String, Double>) -> Double {
        var accessoriesConsumption = 0.0
        print("valuesPer30Minutes: \(valuesPer30Minutes)")
        for (key, value) in params {
            if paramsModificators.keys.contains(key) {
                print("\(key): \(paramsModificators[key]! * value)")
                accessoriesConsumption += paramsModificators[key]! * value
            }
            
        }
        currentBattery = valuesPer30Minutes[self.simStep]
        print("accessoriesConsumption \(accessoriesConsumption)")
        let newBatteryValue = Double(currentBattery) - (baseConsumption + accessoriesConsumption)
        valuesPer30Minutes.append(newBatteryValue)
        
        if self.currentBattery <= 0.0 {
            reset()
            return 0.0
        }
        
        self.simStep += 1
        
        
        
        return newBatteryValue
    }
    
    func reset() {
        self.simStep = 0
        self.currentBattery = 100
        print("Final battery log: \(valuesPer30Minutes)")
        valuesPer30Minutes = [100]
    }
}

public let BatterySimulator = Simulator()
