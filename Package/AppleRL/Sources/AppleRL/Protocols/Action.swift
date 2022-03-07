//
//  Action.swift
//  
//
//  Created by Alessandro Pavesi on 27/11/21.
//

import Foundation

/// Representation of an Action
public protocol Action {
    /// The Action ID
    var id: Int { get }
    /// The Action description
    var description: String { get }
    
    // Implement also the Init(), mark it public
    
    /// The Action execution function
    func exec()
}

/// Example action
open class Action1: Action {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Action1"
    
    public func exec() {
        defaultLogger.log("Action1")
    }
}
