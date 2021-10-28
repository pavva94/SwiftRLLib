//
//  OrientationEnv.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 26/10/21.
//

import Foundation

public class OrientationEnv: Env {
    
    override  func act(s: Any, a: Any) -> Int { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to se an id to each action
        print(s)
        return self.reward(s: s, a: a)
    }
    
    override func reward(s: Any, a: Any) -> Int {
        var r: Int = 0
        if a as! Int == 1 {
            r = 0
        } else if a as! Int == s as! Int {
            r = 1
        } else {
            r = -1
        }
        
        return r
    }
}
