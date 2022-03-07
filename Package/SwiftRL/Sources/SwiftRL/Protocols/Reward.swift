//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 15/01/22.
//

import Foundation

/// Protocol for the Reward
public protocol Reward {

    var id: Int { get }
    var description: String { get }

    func exec(state: [Double], action: Int, nextState: [Double]) -> Double
}

/// Example Random Integer reward
open class RandomIntegerReward: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        return Double.random(in: 0...1)
    }
}
