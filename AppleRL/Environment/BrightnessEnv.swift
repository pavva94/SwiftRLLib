//
//  BrightnessEnv.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 04/11/21.
//

import Foundation
import UIKit


public class BrightnessEnv: Env<Float, Int, Int> {
    
    override func act(s: [Float], a: Int) -> ([Float], Int) { // return the reward that is always int?
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
        return (s, self.reward(s: s, a: a))
    }
    
    override func reward(s: [Float], a: Int) -> Int {
        var r: Int = 0
        let st = s[0]
        let at = a
        if st <= 0.3 && at >= 3 {
            r = 1
        } else if st >= 0.3 && at >= 3 {
            r = -1
        } else if st <= 0.6 && at >= 3 {
            r = -1
        } else if st >= 0.6 && at <= 3 {
            r = 1
        }
        
        return r
    }
    
}
