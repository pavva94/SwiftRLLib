//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 27/11/21.
//

import Foundation

public protocol Action {
    
    var id: Int { get }
    var description: String { get }
    
    func exec()
}


open class Action1: Action {
    public var id: Int = 0
    
    public var description: String = "Action1"
    
    public func exec() {
        print("Action1")
    }
}

open class Action2: Action {
    public var id: Int = 1
    
    public var description: String = "Action2"
    
    public func exec() {
        print("Action2")
    }
}

open class Action3: Action {
    public var id: Int = 2
    
    public var description: String = "Action3"
    
    public func exec() {
        print("Action3")
    }
}

open class Action4: Action {
    public var id: Int = 3
    
    public var description: String = "Action4"
    
    public func exec() {
        print("Action4")
    }
}

open class Action5: Action {
    public var id: Int = 4
    
    public var description: String = "Action5"
    
    public func exec() {
        print("Action5")
    }
}
