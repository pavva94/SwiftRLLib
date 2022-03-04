//
//  AppActions.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import Foundation
import AppleRL
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

open class ConsumptionSensorZero: ObservableData {
    var lastBatteryValue: Double = 100.0
    
    init() {
        super.init(name: "consumption", stateSize: 1)
    }
    
    open override func read(_ state: [Double] = []) -> [Double]
    {
//        if state == [] {
        return [0.0]
//        }
//        print("COSNMPTION \(self.lastBatteryValue), \(state[0])")
//        if state[0] > lastBatteryValue {
//            self.lastBatteryValue = state[0]
//            return [100.0 - state[0]]
//        }
//        let futureValue = lastBatteryValue - state[0]
//        self.lastBatteryValue = state[0]
//        return preprocessing(value: futureValue)
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
        return [Double(environment3.simulator.getSimStep())]
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
    }
}


open class LPMActivate: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Activate the LowPowerMode!"
    
    public func exec() {
        print(description)
    }
}

open class LPMLeaveIt: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Leave LowPowerMode it as it is"
    
    public func exec() {
        print(description)
    }
}

open class LPMDeactivate: Action {
    public var id: Int = 2
    
    public init() {}
    
    public var description: String = "Deactivate the LowPowerMode!"
    
    public func exec() {
        print(description)
    }
}

open class BTActivate: Action {
    public var id: Int = 3
    
    public init() {}
    
    public var description: String = "Activate the BT!"
    
    public func exec() {
        print(description)
    }
}

open class BTLeaveIt: Action {
    public var id: Int = 4
    
    public init() {}
    
    public var description: String = "Leave BT it as it is"
    
    public func exec() {
        print(description)
    }
}

open class BTDeactivate: Action {
    public var id: Int = 5
    
    public init() {}
    
    public var description: String = "Deactivate the BT!"
    
    public func exec() {
        print(description)
    }
}

open class WFActivate: Action {
    public var id: Int = 6
    
    public init() {}
    
    public var description: String = "Activate the WF!"
    
    public func exec() {
        print(description)
    }
}

open class WFLeaveIt: Action {
    public var id: Int = 7
    
    public init() {}
    
    public var description: String = "Leave WF it as it is"
    
    public func exec() {
        print(description)
    }
}

open class WFDeactivate: Action {
    public var id: Int = 8
    
    public init() {}
    
    public var description: String = "Deactivate the WF!"
    
    public func exec() {
        print(description)
    }
}

open class BrightnessIncrese0: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Increase Brightness +0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.4
        } else {
            environment0.simulator.actOverBrightness(value: +0.4)
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

open class BrightnessDecrese0: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Decrese the Brightness -0.2"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.4
        } else {
            environment0.simulator.actOverBrightness(value: -0.4)
        }
    }
}


// ---------------------------
open class BrightnessIncrese1: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Increase Brightness +0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.4
        } else {
            environment1.simulator.actOverBrightness(value: +0.4)
        }
    }
}
open class BrightnessDecrese1: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Decrese the Brightness -0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.4
        } else {
            environment1.simulator.actOverBrightness(value: -0.4)
        }
    }
}
//
//// ---------------------------
open class BrightnessIncrese2: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Increase Brightness +0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.4
        } else {
            environment2.simulator.actOverBrightness(value: +0.4)
        }
    }
}
open class BrightnessDecrese2: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Decrese the Brightness -0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.4
        } else {
            environment2.simulator.actOverBrightness(value: -0.4)
        }
    }
}
//// --------------------------- NEW ACTIONS!!!!!!!!!!!
open class BrightnessShut3: Action {
    public var id: Int = 0

    public init() {}

    public var description: String = "Shut down screen"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = 0.0
        } else {
            environment3.simulator.setBrightnessTo(value: +0.0)
        }
    }
}
open class BrightnessLeave3: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Leave brightness"

    public func exec() {
//        print(description)
//        if !useSimulator {
//            UIScreen.main.brightness = UIScreen.main.brightness 
//        } else {
//            environment3.simulator.actOverBrightness(value: -0.2)
//        }
    }
}

open class BrightnessShut2: Action {
    public var id: Int = 0

    public init() {}

    public var description: String = "Shut down screen"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = 0.0
        } else {
            environment2.simulator.setBrightnessTo(value: +0.0)
        }
    }
}
open class BrightnessLeave2: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Leave brightness"

    public func exec() {
//        print(description)
//        if !useSimulator {
//            UIScreen.main.brightness = UIScreen.main.brightness
//        } else {
//            environment3.simulator.actOverBrightness(value: -0.2)
//        }
    }
}

open class BrightnessShut1: Action {
    public var id: Int = 0

    public init() {}

    public var description: String = "Shut down screen"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = 0.0
        } else {
            environment1.simulator.setBrightnessTo(value: +0.0)
        }
    }
}
open class BrightnessLeave1: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Leave brightness"

    public func exec() {
//        print(description)
//        if !useSimulator {
//            UIScreen.main.brightness = UIScreen.main.brightness
//        } else {
//            environment3.simulator.actOverBrightness(value: -0.2)
//        }
    }
}
//// ---------------------------
open class BrightnessIncrese3: Action {
    public var id: Int = 0

    public init() {}

    public var description: String = "Increase Brightness +0.2"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.5
        } else {
            environment3.simulator.actOverBrightness(value: +0.5)
        }
    }
}
open class BrightnessDecrese3: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Decrese the Brightness -0.2"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.5
        } else {
            environment3.simulator.actOverBrightness(value: -0.5)
        }
    }
}


//// ---------------------------
open class BrightnessIncreseQL: Action {
    public var id: Int = 0

    public init() {}

    public var description: String = "Increase Brightness +0.5"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.4
        } else {
            environment3.simulator.actOverBrightness(value: +0.4)
        }
    }
}
open class BrightnessDecreseQL: Action {
    public var id: Int = 1

    public init() {}

    public var description: String = "Decrese the Brightness -0.5"

    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.4
        } else {
            environment3.simulator.actOverBrightness(value: -0.4)
        }
    }
}
