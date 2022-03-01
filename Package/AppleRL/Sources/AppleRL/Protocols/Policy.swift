//
//  Policy.swift
//  
//
//  Created by Alessandro Pavesi on 17/02/22.
//

import Foundation
import CoreML

public protocol Policy {

    var id: Int { get }
    var description: String { get }
    
    // Implement also the Init(), mark it public

    func exec(model: MLModel, state: MLMultiArray) -> Int
}

public class EpsilonGreedy: Policy {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "EpsilonGreedy"
    
    let greedy: Bool = false
    var step: Int = 0 // save this value?
    
    private func defineEpsilon() -> Double {
        if self.step < 5500 {
            return 0.7
        } else if self.step < 10500 {
            return 0.5
        } else {
            return 0.3
        }
    }
    
    public func exec(model: MLModel, state: MLMultiArray) -> Int {
        defaultLogger.log("\(self.description)")
        let currentEpsilon = defineEpsilon()
        self.step += 1
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
            let stateTarget = model.predictForAppleRL(stateValue) // try? model.prediction(from: ) //
            print(stateTarget)
            
//            defaultLogger.log("Model Choice \(convertToArray(from: stateTarget!.actions).argmax()!)")
//            defaultLogger.log("Model List \(convertToArray(from: stateTarget!.actions))")
            return convertToArray(from: stateTarget!.actions).argmax()!
        }
    }
}

public class RandomPolicy: Policy {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "Random"
    
    public func exec(model: MLModel, state: MLMultiArray) -> Int {
        defaultLogger.log("\(self.description)")
        return Int.random(in: 0...3)
    }
}

public class EpsilonGreedy3: Policy { // TODO Roba non accessibile perchè  internal: .actions
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "EpsilonGreedy"
    
    let greedy: Bool = false
    var step: Int = 0 // save this value?
    
    private func defineEpsilon() -> Double {
        if self.step < 15000 {
            return 0.7
        } else if self.step < 50000 {
            return 0.5
        } else {
            return 0.3
        }
    }
    
    public func exec(model: MLModel, state: MLMultiArray) -> Int {
        print("\(self.description)")
        let currentEpsilon = defineEpsilon()
        self.step += 1
        if !greedy && Double.random(in: 0..<1) < currentEpsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<3)
            print("Epsilon Choice \(choice)")
            return choice
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value from model
            print("State Value \(convertToArray(from: state))")
            let stateTarget = model.predictForAppleRL(stateValue) // try? model.prediction(from: ) //
            print(stateTarget)
            
//            defaultLogger.log("Model Choice \(convertToArray(from: stateTarget!.actions).argmax()!)")
//            defaultLogger.log("Model List \(convertToArray(from: stateTarget!.actions))")
            return convertToArray(from: stateTarget!.actions).argmax()!
        }
    }
}
