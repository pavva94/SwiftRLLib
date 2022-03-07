//
//  AppActions.swift
//  Environment2D
//
//  Created by Alessandro Pavesi on 02/03/22.
//

import Foundation
import AppleRL


//open class ActionLeft: Action {
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Left"
//    
//    public func exec() {
//        newSensor.moveLeft()
//    }
//}
//
//open class ActionRight: Action {
//    public var id: Int = 1
//    
//    public init() {}
//    
//    public var description: String = "Right"
//    
//    public func exec() {
//        newSensor.moveRight()
//    }
//}



open class ActionLeft2: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Left2"
    
    public func exec() {
        newSensor2.moveLeft()
    }
}

open class ActionRight2: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Right2"
    
    public func exec() {
        newSensor2.moveRight()
    }
}


open class ActionLeft3: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Left3"
    
    public func exec() {
        newSensor3.moveLeft()
    }
}

open class ActionRight3: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Right3"
    
    public func exec() {
        newSensor3.moveRight()
    }
}



open class ActionLeft4: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Left4"
    
    public func exec() {
        newSensor4.moveLeft()
    }
}

open class ActionRight4: Action {
    public var id: Int = 1
    
    public init() {}
    
    public var description: String = "Right4"
    
    public func exec() {
        newSensor4.moveRight()
    }
}
