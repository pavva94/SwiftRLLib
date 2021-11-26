//
//  AppEnv.swift
//  Landmarks
//
//  Created by Alessandro Pavesi on 24/11/21.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import AppleRL



public class AppEnv: Env<Double, Int, Double> {
    let defaults = UserDefaults.standard
    var idCounter: Int = 0
    
    public override  func act(state: [Double], action: Int) -> ([Double], Double) {
        // here define the action, selected by the id number
        // Be sure to set an id to each action
        // Here we have to notify the user with the action the agent wants to do
        // in this app we write into the userdefault the state and the action and then the user will see
        // the "notification" in the app and can give a mark
        idCounter = self.defaults.integer(forKey: "idCounter") // set into user prefs
        
        let data: DatabaseData = DatabaseData(id: idCounter, state: state, action: action, reward: 0.0)
//        fileManager.addData(newData: data)
        manageDatabase(data)
        idCounter += 1
        defaults.set(idCounter, forKey: "idCounter")
        

        a.exec()
        
        return (state, 0)
    }

    public override func reward(state: [Double], action: Int) -> Double {
        var r: Double = 0
        let sa = state[0]
        
        
        return r
    }
}
