//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation
import CoreML


extension DeepQNetwork {
    /// Epsilon Greedy policy based on class parameters
    func epsilonGreedy(state: MLMultiArray, greedy: Bool = false) -> Int {
        if !greedy && Double.random(in: 0..<1) < epsilon {
            // epsilon choice
            let choice = Int.random(in: 0..<self.environment.getActionSize())
            defaultLogger.log("Epsilon Choice \(choice)")
            return choice
        }
        else {
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value from model
            defaultLogger.log("State Value \(convertToArray(from: state))")
            let stateTarget = updatedModel!.predictFor(stateValue)
            
            defaultLogger.log("Model Choice \(convertToArray(from: stateTarget!.actions).argmax()!)")
            defaultLogger.log("Model List \(convertToArray(from: stateTarget!.actions))")
            return convertToArray(from: stateTarget!.actions).argmax()!
        }
    }
}
