//
//  SarsaTuple.swift
//  SwiftRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import CoreML

// The alias for the datatype used by the observableData
public typealias RLStateType = [Double]
// The alias for the datatype used by the action
public typealias RLActionType = Int
// The alias for the datatype used by the reward
public typealias RLRewardType = Double

/// Basic data for the package, implements the SARSA tuple
struct SarsaTupleGeneric {

    private var state: MLMultiArray
    private var action: RLActionType
    private var reward: RLRewardType
    private var next_state: MLMultiArray
//    var featureValue: MLFeatureValue
    
    init(state: MLMultiArray, action: RLActionType, reward: RLRewardType, nextState: MLMultiArray) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = nextState
//        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state as Any, action as Any, reward as Any, nextState as Any]))
    }
    
    init(state: MLMultiArray, action: RLActionType, reward: RLRewardType) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = state //?? { fatalError("SarsaTuple cannot be created")}
//        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, 0]))
    }
    
    /// Get the state
    func getState() -> MLMultiArray {
        return self.state
    }
    
    // Get the action
    func getAction() -> RLActionType {
        return self.action
    }
    
    // Get the Reward
    func getReward() -> RLRewardType {
        return self.reward
    }
    
    // Get the next state
    func getNextState() -> MLMultiArray {
        return self.next_state
    }
}

