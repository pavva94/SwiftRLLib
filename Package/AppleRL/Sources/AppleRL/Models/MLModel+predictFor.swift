//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 20/02/22.
//

import Foundation
import CoreML

extension MLModel {
    
    func predictForAppleRL(_ value: MLFeatureValue) -> AppleRLModelOutput? {
        guard let input = value.multiArrayValue else {
            fatalError("Could not extract multiArray from the feature value")
        }
        defaultLogger.log("predictForAppleRL input \(convertToArray(from: input))")
        
        let batchProvider = MLArrayBatchProvider(array: [AppleRLModelInput(data: input)])
        
        // Use the Model to predict a label for the drawing.
        guard let prediction = try? predictions(fromBatch: batchProvider)
        else {
            defaultLogger.error("Prediction not found")
            return nil
        }
        defaultLogger.log("predictForAppleRL Prediction \(convertToArray(from: prediction.features(at: 0).featureValue(for: "actions")!.multiArrayValue!))")
        return AppleRLModelOutput(actions: prediction.features(at: 0).featureValue(for: "actions")!.multiArrayValue!)
    }
}
