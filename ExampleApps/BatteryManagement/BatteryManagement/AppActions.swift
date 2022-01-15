//
//  AppActions.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import Foundation
import AppleRL
import UIKit


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

open class BrightnessIncrese: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Increase Brightness +0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness + 0.2
        } else {
            BatterySimulator.actOverBrightness(value: +0.2)
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
    public var id: Int = 2
    
    public init() {}
    
    public var description: String = "Decrese the Brightness -0.2"
    
    public func exec() {
        print(description)
        if !useSimulator {
            UIScreen.main.brightness = UIScreen.main.brightness - 0.2
        } else {
            BatterySimulator.actOverBrightness(value: -0.2)
        }
    }
}
