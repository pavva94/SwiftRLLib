//
//  AppReward.swift
//  Environment2D
//
//  Created by Alessandro Pavesi on 02/03/22.
//

import Foundation
import AppleRL

open class Reward2D: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        if (nextState.firstIndex(of: 1.0) == 9) {
            print("Agent arrived at the end +10")
            return +10
        } else if (nextState.firstIndex(of: 1.0) == 5) {
            print("Agent arrived at the obstacle")
            return -1
        }
        
        return 0
    }
}
