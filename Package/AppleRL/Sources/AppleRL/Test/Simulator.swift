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
    
    private var clockHoursValues: [Double]
    private var clockMinutesValues: [Double]
    private var batteryValuesPer30Minutes: [Double]
    private var brightnessValuesPer30Minutes: [Double]
    
    init() {
        clockHoursValues = [1.00, 1.00, 2.00, 2.00, 3.00, 3.00, 4.00, 4.00, 5.00, 5.00, 6.00, 6.00, 7.00, 7.00, 8.00, 8.00, 9.00, 9.00, 10.00, 10.00, 11.00, 11.00, 12.00, 12.00, 13.00, 13.00, 14.00, 14.00, 15.00, 15.00, 16.00, 16.00, 17.00, 17.00, 18.00, 18.00, 19.00, 19.00, 20.00, 20.00, 21.00, 21.00, 22.00, 22.00, 23.00, 23.00]
        clockMinutesValues = [0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00, 0.00, 30.00]
        batteryValuesPer30Minutes = [currentBattery]
        brightnessValuesPer30Minutes = [Double.random(in: 0...1).customRound(.toNearestOrAwayFromZero)]
    }
    
    public func getSimStep() -> Int {
        return self.simStep
    }
    
    func simulateBattery(params: Dictionary<String, Double>) -> Double {
        print(params)
        var accessoriesConsumption = 0.0
        print("Clock: \(clockHoursValues[self.simStep]): \(clockMinutesValues[self.simStep])")
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
        print("new battery value \(newBatteryValue)")
        batteryValuesPer30Minutes.append(newBatteryValue)
        
        if self.currentBattery <= 0.0 || newBatteryValue <= 0.0 || self.simStep >= clockHoursValues.count {
            reset()
            return 0.0
        }
        
        self.simStep += 1
        
        return newBatteryValue
    }
    
    public func simulateClock() -> [Double] {
        if self.simStep >= self.clockHoursValues.count {
            self.reset()
        }
        return [clockHoursValues[self.simStep], clockMinutesValues[self.simStep]]
    }
    
    open func actOverBrightness(value: Double) {
        let newValue = (brightnessValuesPer30Minutes.last! + value).customRound(.toNearestOrAwayFromZero)
        if newValue > 1.0 {
            brightnessValuesPer30Minutes.append(1.0)
        } else if newValue < 0.0 {
            brightnessValuesPer30Minutes.append(0.0)
        } else {
            brightnessValuesPer30Minutes.append(newValue)
        }
        
    }
    
    func simulateBrightness() -> Double {
        var value = brightnessValuesPer30Minutes.last!
        // if the last brighness is zero, there is a probability that changes autonomously
        if value == 0.0 && Double.random(in: 0...1) < 0.4 {
            value = Double.random(in: 0...1).customRound(.toNearestOrAwayFromZero)
            brightnessValuesPer30Minutes.append(value)
        }
        
        return value
    }
    
    func reset() {
        self.simStep = 0
        self.currentBattery = 100
        print("Final battery log: \(batteryValuesPer30Minutes)")
        batteryValuesPer30Minutes = [100]
        brightnessValuesPer30Minutes = [Double.random(in: 0...1).customRound(.toNearestOrAwayFromZero)]
    }
}

//public let BatterySimulator = Simulator()
