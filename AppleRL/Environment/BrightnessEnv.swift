//
//  BrightnessEnv.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 04/11/21.
//

import Foundation
import UIKit

public class BrightnessEnv: Env {
    
    override  func act(s: Any, a: Any) -> Int { // return the reward that is always int?
        // here define the action, selected by the id number
        // Be sure to set an id to each action
        let action = a as! Int
        let actualBrightness = UIScreen.main.brightness //as! Float
        print("actualBrightness")
        print(actualBrightness)
        if action == 0 {
            // decrese brightness by a lot
            UIScreen.main.brightness = actualBrightness-CGFloat(0.3)
        } else if action == 1 {
            // decrese brightness slightly
            UIScreen.main.brightness = actualBrightness-CGFloat(0.1)
        } else if action == 2 {
            // do nothing
        } else if action == 3 {
            // increase brightness slightly
            UIScreen.main.brightness = actualBrightness+CGFloat(0.1)
        } else if action == 4 {
            // decrese brightness slightly
            UIScreen.main.brightness = actualBrightness+CGFloat(0.3)
        }
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
