//
//  DQN+LoadSave.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation
import CoreML

extension DeepQNetwork {

    /// Save the model after an MLUpdateTask
    func saveUpdatedModel(_ updateContext: MLUpdateContext, _ testPerformance: Bool = false) {
        let updatedContextModel = updateContext.model
//        Tester.checkCorrectPrediction(environment: environment, urlModel: self.getModelURL())
        
        do {
            // Create a directory for the updated model.
            try fileManager.createDirectory(at: tempUpdatedModelURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            // Save the updated model to temporary filename.
            try updatedContextModel.write(to: tempUpdatedModelURL)
            
            defaultLogger.log("modelwritten")
            
            // Replace any previously updated model with this one.
            _ = try fileManager.replaceItemAt(updatedModelURL,
                                              withItemAt: tempUpdatedModelURL)
            
            defaultLogger.log("Updated model saved to: \t\(self.updatedModelURL)")
        } catch let error {
            defaultLogger.error("Could not save updated model to the file system: \(error.localizedDescription)")
            return
        }
//        Tester.checkCorrectPrediction(environment: environment, urlModel: self.getModelURL())
        defaultLogger.log("Saved Model")
    }


    /// Loads the updated Model, if available. Same with the Target model
    func loadUpdatedModel() {

        if !fileManager.fileExists(atPath: updatedModelURL.path) {
            defaultLogger.info("The updated model is not present at its designated path \(self.updatedModelURL.path)")
            do {
                let updatedModelParentURL = updatedModelURL.deletingLastPathComponent()
                try fileManager.createDirectory(
                    at: updatedModelParentURL,
                    withIntermediateDirectories: true,
                    attributes: nil)
                
                let toTemp = updatedModelParentURL
                    .appendingPathComponent(defaultModelURL.lastPathComponent)
                try fileManager.copyItem(
                    at: defaultModelURL,
                    to: toTemp)
                try fileManager.moveItem(
                    at: toTemp,
                    to: updatedModelURL)
            } catch {
                print("Error: \(error)")
                return
            }
        }
        
        if !fileManager.fileExists(atPath: updatedTargetModelURL.path) {
            defaultLogger.info("The target updated model is not present at its designated path \(self.updatedModelURL.path)")
            do {
                let updatedModelParentURL = updatedTargetModelURL.deletingLastPathComponent()
                try fileManager.createDirectory(
                    at: updatedModelParentURL,
                    withIntermediateDirectories: true,
                    attributes: nil)

                let toTemp = updatedModelParentURL
                    .appendingPathComponent(defaultModelURL.lastPathComponent)
                try fileManager.copyItem(
                    at: defaultModelURL,
                    to: toTemp)
                try fileManager.moveItem(
                    at: toTemp,
                    to: updatedTargetModelURL)
            } catch {
                print("Error: \(error)")
                return
            }
        }
        
        // Create an instance of the updated model.
        guard let model = try? RLModel(contentsOf: updatedModelURL) else {
            defaultLogger.error("Error loading the Model")
            return
        }
        
        // Use this updated model to make predictions in the future.
        updatedModel = model
        defaultLogger.log("Model Loaded")
        
        // Align target model after epochsAlignTarget updates
        if self.countTargetUpdate >= self.epochsAlignTarget || targetModel == nil {
            targetModel = model
            do {
                // Save the updated model to temporary filename.

                // Replace any previously updated model with this one.
                // Firtly i need to remove the last targetModel and then copy the new one
                try fileManager.removeItem(at: updatedTargetModelURL)
                try fileManager.copyItem(at: updatedModelURL, to: updatedTargetModelURL)
//                _ = try fileManager.replaceItemAt(updatedTargetModelURL,
//                                                  withItemAt: updatedModelURL)
            } catch {
                defaultLogger.error("Target model not saved \(error.localizedDescription)")
            }
            self.countTargetUpdate = 0
            defaultLogger.log("Target model updated")
        }
    }
    
    /// Function to load an external Model, downloaded from CloudKit. The file extension is .mlmodel
    public func loadFromExternal(_ externalUrl: URL) {
        do {
            let compiledModelURL = try MLModel.compileModel(at: externalUrl)
            let model = try RLModel(contentsOf: compiledModelURL)
            self.updatedModel = model
            self.targetModel = model
            defaultLogger.log("Model and Target uploaded from External Source")
        } catch {
            defaultLogger.error("Error in load model from external source: \(error.localizedDescription) ")
        }
    }
}
