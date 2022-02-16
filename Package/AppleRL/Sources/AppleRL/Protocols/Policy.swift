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

open class EpsilonGreedy: Policy {
    public var id: Int = 0
    
    public init() {}
    
    public var description: String = "EpsilonGreedy"
    
    let epsilon: Double = 0.3
    let greedy: Bool = false
    
    public func exec(model: MLModel, state: MLMultiArray) -> Int {
        
        if !greedy && Double.random(in: 0..<1) < self.epsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<3)
            defaultLogger.log("Epsilon Choice \(choice)")
            return choice
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value from model
            defaultLogger.log("State Value \(convertToArray(from: state))")
            let stateTarget = try? model.prediction(from: stateValue as! MLFeatureProvider) // model.predictFor(stateValue)
            print(stateTarget)
            
//            defaultLogger.log("Model Choice \(convertToArray(from: stateTarget!.actions).argmax()!)")
//            defaultLogger.log("Model List \(convertToArray(from: stateTarget!.actions))")
            return 0 //convertToArray(from: stateTarget!.actions).argmax()!
        }
    }
}
