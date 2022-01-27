//
//  Testing.swift
//  
//
//  Created by Alessandro Pavesi on 22/12/21.
//

import Foundation
import CoreML


open class Testing {
    
    /// Check performance between two models and a target model.
    /// MSE First-Target and Second-Target
    public func checkPerformance(environment: Env, firstModel: MLModel, secondModel: MLModel, targetModel: MLModel) {
        //
        print("MSE: check")
        let state = environment.read()
        print(state)
        let MLState = convertToMLMultiArrayFloat(from:state)
        // Create a MLFeatureValue as input for the model
        let stateValue = MLFeatureValue(multiArray: MLState)
        // predict value
        let newFirstModel = AppleRLModel(model: firstModel)
        let oldPredictions = newFirstModel.predictFor(stateValue)!.actions
        
        // predict value
        let newSecondModel = AppleRLModel(model: secondModel)
        let newPredictions = newSecondModel.predictFor(stateValue)!.actions
        
        // take value from the target net as the target
        let newTargetModel = AppleRLModel(model: targetModel)
        let targetPredictions = newTargetModel.predictFor(stateValue)!.actions
        
        var errorOld = 0.0
        var errorNew = 0.0
        for i in 0..<oldPredictions.count {
            let tempOld = oldPredictions[i] as! Double - Double(truncating: targetPredictions[i])
            errorOld += tempOld*tempOld
            
            let tempNew = newPredictions[i] as! Double - Double(truncating: targetPredictions[i])
            errorNew += tempNew*tempNew
        }
        errorOld /= Double(oldPredictions.count)
        errorNew /= Double(oldPredictions.count)
        
        print("MSE error Old-Target: \(errorOld), Error New-Target: \(errorNew)")
    }
    
    /// Check prediction with some defined state
    open func checkCorrectPrediction(environment: Env, urlModel: URL) {
        // checkCorrectPrediction
        defaultLogger.log("-----checkCorrectPrediction-----")
        do {
            let newModel = try AppleRLModel(contentsOf: urlModel)
            print("Same State: [14.0, 11.0, 0.0, 0.6], Correct action: 2") //20% battery -> Decrese = 2, nextState [14.0, 11.0, 0.0, 0.4] = battery -2 - 0.4*10
            var stateFixed = MLFeatureValue(multiArray:convertToMLMultiArrayFloat(from: [14.0, 11.0, 0.0, 0.6]))
            print("Optimal Reward: \(environment.reward(state: [14.0, 11.0, 0.0, 0.6], action: 2, nextState: [14.0, 11.0, 0.0, 0.4]))")
            var actionChoosen = newModel.predictLabelFor(stateFixed)
            print("Action choosen: \(String(describing: actionChoosen))")
            var actionListChoosen = newModel.predictFor(stateFixed)
            print("Action List choosen: \(String(describing: actionListChoosen!.actions))")
            
            print("Same State: [45.0, 18.0, 0.0, 0.6], Correct action: 0 o 1") // 45% battery, 18: netflix -> Increase = 0 o Leave 1 nextState [45.0, 18.0, 0.0, 0.6] o [45.0, 18.0, 0.0, 0.8] = battery -2 - 0.6o0.8 *10
            stateFixed = MLFeatureValue(multiArray:convertToMLMultiArrayFloat(from: [45.0, 18.0, 0.0, 0.6]))
            print("Reward, action 0: \(environment.reward(state:[45.0, 18.0, 0.0, 0.6], action: 0, nextState: [45.0, 18.0, 0.0, 0.6]))")
            print("Reward, action 1: \(environment.reward(state:[45.0, 18.0, 0.0, 0.6], action: 1, nextState: [45.0, 18.0, 0.0, 0.8]))")
                                                                                     
            actionChoosen = newModel.predictLabelFor(stateFixed)
            actionListChoosen = newModel.predictFor(stateFixed)
            print("Action List choosen: \(String(describing: actionListChoosen!.actions))")
            print("Action choosen: \(String(describing: actionChoosen))")
        } catch {
            defaultLogger.error("Error during test: \(error.localizedDescription)")
            return
        }
        
       
    }
    
    
    public func readWeights(currentModel: MLModel, names: [String] = ["dense_1", "dense_2", "dense_3"]) {
        
//        defaultLogger.log("parameters: \(context.parameters)")
        defaultLogger.log("parameters: \(currentModel.modelDescription)")
        do {
            for name in names {
                let weights: MLMultiArray = try currentModel.parameterValue(for: MLParameterKey.weights.scoped(to: name)) as! MLMultiArray
                defaultLogger.log("weights \(name): \(convertToArray(from: weights))")
    //            weights = try context.model.parameterValue(for: MLParameterKey.weights.scoped(to: "dense_2")) as! MLMultiArray
    //            defaultLogger.log("weights dense_2: \(convertToArray(from: weights))")
    //            weights = try context.model.parameterValue(for: MLParameterKey.weights.scoped(to: "dense_3")) as! MLMultiArray
    //            defaultLogger.log("weights dense_3: \(convertToArray(from: weights))")
    //            weights = try context.model.parameterValue(for: MLParameterKey.weights.scoped(to: "dense_4")) as! MLMultiArray
    //            defaultLogger.log("weights dense_4: \(convertToArray(from: weights))")
            }
        } catch {
            defaultLogger.error("Error getting weights: \(error.localizedDescription)")
        }
        
    }
}

public let Tester = Testing()
