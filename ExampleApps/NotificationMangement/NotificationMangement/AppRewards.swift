//
//  AppRewards.swift
//  NotificationMangement
//
//  Created by Alessandro Pavesi on 22/02/22.
//

import Foundation
import SwiftRL


open class ReadSendRatioNew: Reward {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "ReadSendRatioNew"
    
    var dailyReward = 0.0

    
    public func exec(state: RLStateType, action: RLActionType, nextState: RLStateType) -> RLRewardType {
        var reward: Double = 0.0
        
        // ["locked", "battery", "clock", "lowPowerMode", "readNotification"]
//        let lat = state[1]
//        let long = state[2]
//        let locked = state[0]
//        let battery = state[3]
        let hourRL = state[2]
        let minuteRL = state[3]
//        let lowPowerMode = state[6]
//        let readNotification = state[7]
//
//
//        let nextReadNotification = nextState[7]
        
        
//        reward = nextReadNotification > readNotification ? +1 : 0
       
        // if the agent send the notification, reward him with +1 if the user read the notification or -1 otherwise
        if action == 0 {
            reward = newSensorStack.readReadCounter(clock: [hourRL, minuteRL]) > newSensorStack.readLastReadCounter(clock: [hourRL, minuteRL]) ? +1 : -1
        }
        
        print("Final reward: \(reward)")
//        countReward(rew: reward)
        
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}
