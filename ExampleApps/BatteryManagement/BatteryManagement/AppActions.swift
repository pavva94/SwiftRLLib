//
//  AppActions.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import Foundation
import AppleRL


open class Activate: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Decrese Brightness is good"
    
    public func exec() {
        print("Action1")
    }
}

open class LeaveIt: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Leave it as it is"
    
    public func exec() {
        print("Action2")
    }
}

open class Deactivate: Action {
    public var id: Int = 2
    
    public init() {}
    
    public var description: String = "Increase Brightness is good"
    
    public func exec() {
        print("Action3")
    }
}
