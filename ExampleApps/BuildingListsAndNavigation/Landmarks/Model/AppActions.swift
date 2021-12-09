//
//  AppActions.swift
//  Landmarks
//
//  Created by Alessandro Pavesi on 09/12/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import AppleRL


open class Decrese: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Decrese Brightness is good"
    
    public func exec() {
        defaultLogger.log("Action1")
    }
}

open class LeaveIt: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Leave it as it is"
    
    public func exec() {
        defaultLogger.log("Action2")
    }
}

open class Increase: Action {
    public var id: Int = 2
    
    public init() {}
    
    public var description: String = "Increase Brightness is good"
    
    public func exec() {
        defaultLogger.log("Action3")
    }
}
