//
//  SarsaTuple.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import CoreML
import CoreImage

/// Convenience structure that stores a drawing's `CGImage`
/// along with the `CGRect` in which it was drawn on the `PKCanvasView`
/// - Tag: Drawing
struct SarsaTupleGeneric<S, A, R> {
    private var state: MLMultiArray
    private var action: A
    private var reward: R
    private var next_state: MLMultiArray
//    var featureValue: MLFeatureValue
    
    init(state: MLMultiArray, action: A, reward: R, nextState: MLMultiArray) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = nextState
//        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state as Any, action as Any, reward as Any, nextState as Any]))
    }
    
    init(state: MLMultiArray, action: A, reward: R) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = state //?? { fatalError("SarsaTuple cannot be created")}
//        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, 0]))
    }
    
    func getState() -> MLMultiArray {
        return self.state
    }
    
    func getAction() -> A {
        return self.action
    }
    
    func getReward() -> R {
        return self.reward
    }
    
    func getNextState() -> MLMultiArray {
        return self.next_state
    }
}

