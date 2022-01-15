//
//  AppleRLModel+Update.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import CoreML

extension AppleRLModel {    
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
        do {
            print(url)
            let updateTask = try MLUpdateTask(forModelAt: url,
                                           trainingData: trainingData,
                                           configuration: parameters,
                                            progressHandlers: handlers)
            updateTask.resume()
        } catch {
            defaultLogger.error("Could't create an MLUpdateTask: \(error.localizedDescription)")
            return
        }
        
       
    }
}


