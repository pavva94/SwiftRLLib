//
//  AppActions.swift
//  Environment2D
//
//  Created by Alessandro Pavesi on 02/03/22.
//

import Foundation
import SwiftRL


open class ActionLeft: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Left2"
    
    public func exec() {
        newSensor.moveLeft()
    }
}

open class ActionRight: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Right2"
    
    public func exec() {
        newSensor.moveRight()
    }
}
