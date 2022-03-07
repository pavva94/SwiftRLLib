//
//  AppRewards.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 22/02/22.
//

import Foundation
import AppleRL


open class RandomIntegerReward: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0

        //        let lat = state[0]
        //        let long = state[1]
        let battery = state[0]
        let hourRL = state[1]
        let minuteRL = state[2]
        let brightness = state[3]

        // check some state-action that cannot be done
        let watchingNetflix = Double.random(in: 0...1)
        //        let usingBluetooth = Double.random(in: 0...1)


        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
            print("i'm watching netflix: -10")
            reward += -10
        }
        
        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
        reward += nextState[0] - battery

        print("Final reward: \(reward)")

        return reward.customRound(.toNearestOrAwayFromZero)
    }
}


open class Reward3: Reward {

    public var id: Int = 0

    public init() {}

    public var description: String = "Random Integer Reward"

    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0

        let battery = state[0]
        let nextBattery = nextState[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]

        if nextBattery == 0.0 {
            reward += 0 // Double(environment2.simulator.getSimStep())
        } else if nextBattery > battery {
            reward += 0 // Double(environment2.simulator.getSimStep())
        } else {
            reward += 1.0
        }
        print("Final reward: \(reward)")

        return reward.customRound(.toNearestOrAwayFromZero)
    }
}



open class Reward5: Reward {

    public var id: Int = 0

    public init() {}

    public var description: String = "Random Integer Reward"
    var lastConsumption: Double = 0.0

    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0

        let battery = state[0]
        let nextBattery = nextState[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]
        
        var actualConsumption = 0.0
        if nextBattery > battery {
            actualConsumption += nextBattery - 100.0
        } else {
            actualConsumption += nextBattery - battery
        }
                
        if actualConsumption < self.lastConsumption {
            reward += +1
//        } else if actualConsumption == lastConsumption {
//            reward += 0
//        } else if actualConsumption > lastConsumption {
//            reward += -1
        } else {
            reward += 0
        }
        
        self.lastConsumption = actualConsumption
        
        print("Final reward: \(reward)")
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}
