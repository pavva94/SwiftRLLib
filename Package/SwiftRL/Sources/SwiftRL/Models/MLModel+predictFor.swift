//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 20/02/22.
//

import Foundation
import CoreML

extension MLModel {
    
    public func predictForRL(_ value: MLFeatureValue) -> MLMultiArray? {
        guard let input = value.multiArrayValue else {
            fatalError("Could not extract multiArray from the feature value")
        }
        defaultLogger.log("predictForRL input \(convertToArray(from: input))")
        
        let batchProvider = MLArrayBatchProvider(array: [RLModelInput(data: input)])
        
        // Use the Model to predict a label for the drawing.
        guard let prediction = try? predictions(fromBatch: batchProvider)
        else {
            defaultLogger.error("Prediction not found")
            return nil
        }
        defaultLogger.log("predictForRL Prediction \(convertToArray(from: prediction.features(at: 0).featureValue(for: "actions")!.multiArrayValue!))")
        return prediction.features(at: 0).featureValue(for: "actions")!.multiArrayValue!
    }
}
