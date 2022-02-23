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
        // reward +1 when:
        // is night (>23.30) and the agent want to activate or leave if it is already active the LPM
        // the battery is under 25% and activate
        // i'm at home and activate
        // it's morning and the battery is over 50%

        // reward -1 when:
        // deactivate at night
        // activate outside with high battery (>60%)
        // deactivate with low battery (<25%)

        //        print(state)


//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(BatterySimulator.getSimStep())")
//            return Double(BatterySimulator.getSimStep()) * 10
//        }

        //        let lat = state[0]
        //        let long = state[1]
        let battery = state[0]
        let hourRL = state[1]
        let minuteRL = state[2]
        let brightness = state[3]


        //        if hourRL > 23 && ( (lowPowerMode == 1.0 && action == 1) || (lowPowerMode == 0.0 && action == 2)) {
        //            reward = 1.0
        //        } else if battery <= 25.0 && action == 2 {
        //            reward = 1.0
        //        } else if hourRL > 7 && battery >= 50 && ( (lowPowerMode == 1.0 && action == 0) || (lowPowerMode == 0.0 && action == 1)) {
        //            reward = 1.0
        //        } else if hourRL > 23 && (lowPowerMode == 1.0 && action == 2) {
        //            reward = -1.0
        //        } else if battery > 60.0 && action == 2 {
        //            reward = -1.0
        //        } else if battery <= 25 && ( (lowPowerMode == 1.0 && action == 0) || (lowPowerMode == 0.0 && action == 1)) {
        //            reward = -1.0
        //        }

        // check some state-action that cannot be done
        let watchingNetflix = Double.random(in: 0...1)
        //        let usingBluetooth = Double.random(in: 0...1)


        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
            print("i'm watching netflix: -10")
            reward += -10
        //        }
        //        // Case 2: if the battery is under 20% and the agent want to deactivate LPM, NOT permitted -10
        //        else if battery < 0.2 && action == 2 {
        //            print("the battery is under 20% and the agent want to deactivate: -10")
        //            reward += -10
        }

        //        if brightness < 0.1 && action != 1 {
        //            print("Do not modify the brightness when closed: -20")
        //            reward += -20
        //        }


        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
        reward += nextState[0] - battery

        print("Final reward: \(reward)")

        return reward.customRound(.toNearestOrAwayFromZero)
    }
}


open class Reward0: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(environment0.simulator.getSimStep())")
            return Double(environment0.simulator.getSimStep()) * 10
        }

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



open class Reward1: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(environment1.simulator.getSimStep())")
            return Double(environment1.simulator.getSimStep()) * 10
        }

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



open class Reward2: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(environment2.simulator.getSimStep())")
            return Double(environment2.simulator.getSimStep()) * 10
        }

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
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(environment3.simulator.getSimStep())")
            return Double(environment3.simulator.getSimStep()) * 10
        }

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



open class RewardQL: Reward {
    
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random Integer Reward"
    
    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        
        if nextState == [] {
            print("the battery is dead: reward based on simstep: \(environmentQL.simulator.getSimStep())")
            return Double(environmentQL.simulator.getSimStep()) * 10
        }

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


