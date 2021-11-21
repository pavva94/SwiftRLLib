//
//  OrientationEnv.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 26/10/21.
//

import Foundation

public class OrientationEnv: Env<Int, Int, Int> {
    
    override  func act(s: [Int], a: Int) -> ([Int], Int) { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to set an id to each action
        print(s) // action
        return (s, self.reward(s: s, a: a))
    }
    
    override func reward(s: [Int], a: Int) -> Int {
        var r: Int = 0
        let sa = s[0]
        if a == 1 {
            r = 0
        } else if a == sa {
            r = 1
        } else {
            r = -1
        }
        
        return r
    }
}
