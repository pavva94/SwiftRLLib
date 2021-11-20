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
struct SarsaTuple {
    private var state: Int
    private var action: Int
    private var reward: Int
    private var next_state: Int
    var featureValue: MLFeatureValue
    
    init(state:Int, action:Int, reward:Int, nextState: Int) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = nextState
        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, next_state]))
    }
    
    init(state:Int, action:Int, reward:Int) {
        self.state = state
        self.action = action
        self.reward = reward
        self.next_state = 0
        self.featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, next_state]))
    }
    
    func getState() -> Int {
        return self.state
    }
    
    func getAction() -> Int {
        return self.action
    }
    
    func getReward() -> Int {
        return self.reward
    }
    
    func getNextState() -> Int {
        return self.next_state
    }
}

