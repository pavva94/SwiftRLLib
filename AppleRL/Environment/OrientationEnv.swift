//
//  OrientationEnv.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 26/10/21.
//

import Foundation

public class OrientationEnv: Env<Int, Int, Int> {
    
    override  func act(state: [Int], action: Int) -> ([Int], Int) { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to set an id to each action
        print(state) // action
        return (state, self.reward(state: state, action: action))
    }
    
    override func reward(state: [Int], action: Int) -> Int {
        var r: Int = 0
        let sa = state[0]
        if action == 1 {
            r = 0
        } else if action == sa {
            r = 1
        } else {
            r = -1
        }
        
        return r
    }
}
