//
//  Policy.swift
//  
//
//  Created by Alessandro Pavesi on 17/02/22.
//

import Foundation
import CoreML

/// Protocol for the Policy class
public protocol Policy {
    /// Policy ID
    var id: Int { get }
    /// Policy description
    var description: String { get }
    
    // Implement also the Init(), mark it public
    
    /// Policy execution function
    func exec(model: MLModel, state: MLMultiArray) -> Int
}

/// Epsilon Greedy policy
public class EpsilonGreedy: Policy {
    public var id: Int = 0
    let defaults = UserDefaults.standard
    
    public init(id: Int) {
        self.id = id
        self.step = self.defaults.integer(forKey: "stepEpsilonGreedy" + String(self.id))
        
    }

    public var description: String = "EpsilonGreedy 2 actions"
    
    let greedy: Bool = false
    var step: Int = 0 // save this value?
    
    private func defineEpsilon() -> Double {
        if self.step < 2500 {
            return 0.7
        } else if self.step < 5500 {
            return 0.5
        } else {
            return 0.3
        }
    }
    
    public func exec(model: MLModel, state: MLMultiArray) -> RLActionType {
        defaultLogger.log("\(self.description)")
        let currentEpsilon = defineEpsilon()
        self.step += 1
        self.defaults.set(self.step, forKey: "stepEpsilonGreedy" + String(self.id))
        if !greedy && Double.random(in: 0..<1) < currentEpsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<2)
            defaultLogger.log("Epsilon Choice \(choice)")
            return choice
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value from model
            defaultLogger.log("State Value \(convertToArray(from: state))")
            let stateTarget = model.predictForRL(stateValue) // try? model.prediction(from: ) //
            print(stateTarget)
            
//            defaultLogger.log("Model Choice \(convertToArray(from: stateTarget!.actions).argmax()!)")
//            defaultLogger.log("Model List \(convertToArray(from: stateTarget!.actions))")
            return convertToArray(from: stateTarget!).argmax()!
        }
    }
}

/// Random policy
public class RandomPolicy: Policy {
    public var id: Int = 0
    private var actions: Int = 2
    
    public init(_ actions: RLActionType = 2) {
        self.actions = actions
    }
    
    public var description: String = "Random Policy"
    
    public func exec(model: MLModel, state: MLMultiArray) -> Int {
        defaultLogger.log("\(self.description)")
        return Int.random(in: 0...self.actions)
    }
}
