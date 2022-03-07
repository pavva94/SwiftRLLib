//
//  AppActions.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import Foundation
import SwiftRL
import UIKit


open class ConsumptionSensor: ObservableData {
    var lastBatteryValue: Double = 100.0
    
    init() {
        super.init(name: "consumption", stateSize: 1)
    }
    
    open override func read(_ state: [Double] = []) -> [Double]
    {
        if state == [] {
            return [0.0]
        }
        print("COSNMPTION \(self.lastBatteryValue), \(state[0])")
        if state[0] > lastBatteryValue {
            self.lastBatteryValue = state[0]
            return [100.0 - state[0]]
        }
        let futureValue = lastBatteryValue - state[0]
        self.lastBatteryValue = state[0]
        return preprocessing(value: futureValue.customRound(.toNearestOrAwayFromZero))
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
    }
}


open class DailyStepSensor: ObservableData {
    
    init() {
        super.init(name: "dailyStep", stateSize: 1)
    }
    
    open override func read(_ state: [Double] = []) -> [Double]
    {
        return [Double(environment.simulator.getSimStep())]
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
    }
}


open class BrightnessIncrese: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Increase Brightness +0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.4
        } else {
            environment.simulator.actOverBrightness(value: +0.4)
        }
    }
}

open class BrightnessLeaveIt: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Leave Brightness as it is"
    
    public func exec() {
        print(description)
    }
}

open class BrightnessDecrese: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Decrese the Brightness -0.2"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.4
        } else {
            environment.simulator.actOverBrightness(value: -0.4)
        }
    }
}
