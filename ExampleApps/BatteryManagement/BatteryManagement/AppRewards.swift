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


//open class Reward0: Reward {
//
//    public var id: Int = 0
//
//    public init() {}
//
//    public var description: String = "Random Integer Reward"
//
//    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
//        var reward: Double = 0.0
//
//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(environment0.simulator.getSimStep())")
//            return Double(environment0.simulator.getSimStep()) * 10
//        }
//
//        let battery = state[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]
//
//        // check some state-action that cannot be done
//        let watchingNetflix = Double.random(in: 0...1)
//        //        let usingBluetooth = Double.random(in: 0...1)
//
//
//        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
//        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
//            print("i'm watching netflix: -10")
//            reward += -10
//
//        }
//
//        // Final reward based on what the agent need to maximise
//        // here the difference between the current battery value and the battery value of previous state
//        reward += nextState[0] - battery
//
//        print("Final reward: \(reward)")
//
//        return reward.customRound(.toNearestOrAwayFromZero)
//    }
//}



open class Reward1: Reward {

    public var id: Int = 0

    public init() {}
    
    private var lastConsumption: Double = 12

    public var description: String = "Random Integer Reward"

    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0

//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(environment1.simulator.getLastSimStep())")
//            return Double(environment1.simulator.getLastSimStep())
//        }

        let battery = state[0]
        let nextBattery = nextState[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]

        // check some state-action that cannot be done
//        let watchingNetflix = Double.random(in: 0...1)
//        //        let usingBluetooth = Double.random(in: 0...1)
//
//
//        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
//        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
//            print("i'm watching netflix: -10")
//            reward += -10
//
//        }

        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
        
        // the same as Reward3 without the added sensor
        var actualConsumption = 0.0
        if nextBattery > battery {
            actualConsumption += nextBattery - 100.0
        } else {
            actualConsumption += nextBattery - battery
        }
                
//        if actualConsumption < lastConsumption {
//            reward += +1
////        } else if actualConsumption == lastConsumption {
////            reward += 0
////        } else if actualConsumption > lastConsumption {
////            reward += -1
//        } else {
//            reward += 0
//            print("MEGAERRROR REWARD")
//        }
                
        reward = actualConsumption

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

//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(environment2.simulator.getSimStep())")
//            return Double(environment2.simulator.getSimStep())
//        }

        let battery = state[0]
        let nextBattery = nextState[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]
//
//        // check some state-action that cannot be done
//        let watchingNetflix = Double.random(in: 0...1)
//        //        let usingBluetooth = Double.random(in: 0...1)
//
//
//        // Case 1: if i'm watching ntflix (80% of the time) and the agent want to decrese brightness, NOT permitted -10
//        if watchingNetflix < 0.8  && brightness > 0.5 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
//            print("i'm watching netflix: -10")
//            reward += -10
//
//        }

        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
//        if nextBattery > battery {
//            reward += 100 - nextBattery
//        } else {
//            reward += battery - nextBattery
//        }

        // for each step != da battery = 0 => +1, a 0 => -10
        // cosi per ogni step ha un reward e cerca di massimizzare gli step
        if nextBattery == 0.0 {
            reward += Double(environment2.simulator.getSimStep())-45
        } else {
            reward += 0.0
        }

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

//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(environment1.simulator.getLastSimStep())")
//            return Double(environment1.simulator.getLastSimStep())
//        }

        let battery = state[0]
        let nextBattery = nextState[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]

        // check some state-action that cannot be done
//        let watchingNetflix = Double.random(in: 0...1)
//        //        let usingBluetooth = Double.random(in: 0...1)
//
//
//        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
//        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
//            print("i'm watching netflix: -10")
//            reward += -10
//
//        }

        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
        
        // the same as Reward3 without the added sensor
//        var actualConsumption = 0.0
//        if nextBattery > battery {
//            actualConsumption += nextBattery - 100.0
//        } else {
//            actualConsumption += nextBattery - battery
//        }
//
//        reward += actualConsumption
                
//        if actualConsumption < lastConsumption {
//            reward += +1
////        } else if actualConsumption == lastConsumption {
////            reward += 0
////        } else if actualConsumption > lastConsumption {
////            reward += -1
//        } else {
//            reward += 0
//            print("MEGAERRROR REWARD")
//        }
//
//        self.lastConsumption = actualConsumption
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

//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(environment1.simulator.getLastSimStep())")
//            return Double(environment1.simulator.getLastSimStep())
//        }

        let battery = state[0]
        let nextBattery = nextState[0]
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]

        // check some state-action that cannot be done
//        let watchingNetflix = Double.random(in: 0...1)
//        //        let usingBluetooth = Double.random(in: 0...1)
//
//
//        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
//        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
//            print("i'm watching netflix: -10")
//            reward += -10
//
//        }

        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state
        
        // the same as Reward3 without the added sensor
        var actualConsumption = 0.0
        if nextBattery > battery {
            actualConsumption += nextBattery - 100.0
        } else {
            actualConsumption += nextBattery - battery
        }

//        reward += actualConsumption
                
        if actualConsumption < self.lastConsumption {
            reward += +1
//        } else if actualConsumption == lastConsumption {
//            reward += 0
//        } else if actualConsumption > lastConsumption {
//            reward += -1
        } else {
            reward += 0
            print("MEGAERRROR REWARD")
        }
        self.lastConsumption = actualConsumption
        
        print("Final reward: \(reward)")
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}



open class Reward4: Reward {

    public var id: Int = 0

    public init() {}
    
//    private var lastConsumption: Double = 100

    public var description: String = "Random Integer Reward"

    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0

//        if nextState == [] {
//            print("the battery is dead: reward based on simstep: \(environment3.simulator.getLastSimStep())")
//            return Double(environment3.simulator.getLastSimStep())
//        }

        let battery = state[0]
        let nextBattery = nextState[0]
        
        // +1 se il consumo è minore dello step successivo
        // -1 al contrrario, 0 se uguale
        // cerca di massimizzare i +1 quindi di diminuire il consumo
//        let actualConsumption = state[state.count-1]
//
//        if actualConsumption < lastConsumption {
//            reward += +1
//        } else if actualConsumption == lastConsumption {
//            reward += 0
//        } else if actualConsumption > lastConsumption {
//            reward += -1
//        } else {
//            print("MEGAERRROR REWARD")
//        }
//
//        self.lastConsumption = actualConsumption
//
//        let hourRL = state[1]
//        let minuteRL = state[2]
//        let brightness = state[3]
//
//        // check some state-action that cannot be done
//        let watchingNetflix = Double.random(in: 0...1)
//        //        let usingBluetooth = Double.random(in: 0...1)
//
//
//        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
//        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
//            print("i'm watching netflix: -10")
//            reward += -10
//
//        }
//
//        // Final reward based on what the agent need to maximise
//        // here the difference between the current battery value and the battery value of previous state
//        reward += nextState[0] - battery
//
//        print("Final reward: \(reward)")
//
//        return reward.customRound(.toNearestOrAwayFromZero)

//        if nextBattery == 0.0 {
//            reward += Double(environment3.simulator.getSimStep())
//        } else {
//            reward += 0.0
//        }
        
        if nextBattery == 0.0 {
            reward += -1 // Double(environment2.simulator.getSimStep())
        } else if nextBattery > battery {
            reward += -1 // Double(environment2.simulator.getSimStep())
        } else {
            reward += 0.0
        }

        return reward.customRound(.toNearestOrAwayFromZero)
    }
}



//open class RewardQL: Reward {
//    
//    public var id: Int = 0
//    
//    public init() {}
//    
//    public var description: String = "Random Integer Reward"
//    
//    public func exec(state: [Double], action: Int, nextState: [Double]) -> Double {
//        var reward: Double = 0.0
//        
////        if nextState == [] {
////            print("the battery is dead: reward based on simstep: \(environmentQL.simulator.getSimStep())")
////            return Double(environmentQL.simulator.getSimStep())
////        }
//
//        let battery = state[0]
//        let nextBattery = nextState[0]
//        let hourRL = state[1]
////        let minuteRL = state[2]
////        let brightness = state[3]
////
////        // check some state-action that cannot be done
////        let watchingNetflix = Double.random(in: 0...1)
////        //        let usingBluetooth = Double.random(in: 0...1)
////
////
////        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
////        if watchingNetflix < 0.2 && action == 2 && [18.0, 18.30, 19.0].contains(hourRL){
////            print("i'm watching netflix: -10")
////            reward += -10
////
////        }
////
////        // Final reward based on what the agent need to maximise
////        // here the difference between the current battery value and the battery value of previous state
////        reward += nextState[0] - battery
////
////        print("Final reward: \(reward)")
////
////        return reward.customRound(.toNearestOrAwayFromZero)
//        
//        if nextBattery == 0.0 {
//            reward += Double(environmentQL.simulator.getSimStep())
//        } else {
//            reward += 0.0
//        }
//        return reward.customRound(.toNearestOrAwayFromZero)
//    }
//}
//
//
