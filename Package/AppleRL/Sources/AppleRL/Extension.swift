//
//  MLModelExt.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import CoreML

extension AppleRLModel {
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
//        guard prediction != AppleRLModel.unknownLabel else {
//            return nil
//        }
        
        // return prediction
//        defaultLogger.log(convertToArray(from: prediction.actions).argmax()!)
        return String(convertToArray(from: prediction.actions).argmax()!)
    }
    
    func predictFor(_ value: MLFeatureValue) -> AppleRLModelOutput? {
        guard let input = value.multiArrayValue else {
            fatalError("Could not extract multiArray from the feature value")
        }
        
        // Use the Model to predict a label for the drawing.
        guard let prediction = try? prediction(data: input)
//                .label
        else {
            defaultLogger.error("Prediction not found")
            return nil
        }
        
        // A label of "unknown" means the model has no prediction for the image.
        // This typically means the Model hasn't been updated with any image/label pairs.
//        guard prediction != AppleRLModel.unknownLabel else {
//            return nil
//        }
        
        // return prediction
//        defaultLogger.log(type(of:prediction))
//        defaultLogger.log(prediction)
        return prediction
    }
    
    
    /// Creates an update model from a given model URL and training data.
    ///
    /// - Parameters:
    ///     - url: The location of the model the Update Task will update.
    ///     - trainingData: The training data the Update Task uses to update the model.
    ///     - completionHandler: A closure the Update Task calls when it finishes updating the model.
    /// - Tag: CreateUpdateTask
    static func updateModel(at url: URL,
                            with trainingData: MLBatchProvider,
                            parameters: MLModelConfiguration,
                            progressHandler: @escaping (MLUpdateContext) -> Void,
                            completionHandler: @escaping (MLUpdateContext) -> Void) {
        
        
        
        let handlers = MLUpdateProgressHandlers(
                            forEvents: [.trainingBegin, .miniBatchEnd, .epochEnd],
                            progressHandler: progressHandler,
                            completionHandler: completionHandler)
        
        // Create an Update Task.
        guard let updateTask = try? MLUpdateTask(forModelAt: url,
                                           trainingData: trainingData,
                                           configuration: parameters,
                                            progressHandlers: handlers)
            else {
                defaultLogger.error("Could't create an MLUpdateTask.")
                return
        }
        
        updateTask.resume()
    }
}


extension Int {
  var f: CGFloat { return CGFloat(self) }
}

extension Float {
  var f: CGFloat { return CGFloat(self) }
}

extension Double {
  var f: CGFloat { return CGFloat(self) }
}

extension CGFloat {
    var swf: Float { return Float(self) }
    var swd: Double { return Double(self) }
}
