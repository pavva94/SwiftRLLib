//
//  RLModel+Predict.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import CoreML

extension RLModel {
    // static let unknownLabel = "unknown"
    
    /// Predicts a label for the given drawing.
    /// - Parameter value: A user's drawing represented as a feature value.
    /// - Returns: The predicted string label, if known; otherwise `nil`.
    func predictLabelFor(_ value: MLFeatureValue) -> String? {
        guard let input = value.multiArrayValue else {
            fatalError("Could not extract multiArray from the feature value")
        }
        
        // Use the Model to predict a label for the drawing.
        guard let prediction = try? prediction(data: input)
//                .label
        else {
            defaultLogger.error("Label Prediction not found")
            return nil
        }
        
        // A label of "unknown" means the model has no prediction for the image.
        // This typically means the Model hasn't been updated with any image/label pairs.
//        guard prediction != RLModel.unknownLabel else {
//            return nil
//        }
        
        // return prediction
//        defaultLogger.log(convertToArray(from: prediction.actions).argmax()!)
        return String(convertToArray(from: prediction.actions).argmax()!)
    }
    
    func predictFor(_ value: MLFeatureValue) -> RLModelOutput? {
        guard let input = value.multiArrayValue else {
            fatalError("Could not extract multiArray from the feature value")
        }
//        defaultLogger.log("RLModel input \(convertToArray(from: input))")
        // Use the Model to predict a label for the drawing.
        guard let prediction = try? prediction(data: input)
        else {
            defaultLogger.error("Prediction not found")
            return nil
        }
//        defaultLogger.log("RLModel Prediction \(convertToArray(from: prediction.actions))")
        return prediction
    }
}
