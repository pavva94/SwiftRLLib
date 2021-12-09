//
//  SarsaTuple.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import CoreML


struct SarsaTupleGeneric {
    private var state: MLMultiArray
    private var action: Int
    private var reward: Double
    private var next_state: MLMultiArray
//    var featureValue: MLFeatureValue
    
    init(state: MLMultiArray, action: Int, reward: Double, nextState: MLMultiArray) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = nextState
//        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state as Any, action as Any, reward as Any, nextState as Any]))
    }
    
    init(state: MLMultiArray, action: Int, reward: Double) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = state //?? { fatalError("SarsaTuple cannot be created")}
//        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, 0]))
    }
    
    func getState() -> MLMultiArray {
        return self.state
    }
    
    func getAction() -> Int {
        return self.action
    }
    
    func getReward() -> Double {
        return self.reward
    }
    
    func getNextState() -> MLMultiArray {
        return self.next_state
    }
}

