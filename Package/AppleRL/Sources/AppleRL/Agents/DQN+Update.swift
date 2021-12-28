//
//  DQN+Update.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation
import CoreML

extension DeepQNetwork {
    
    /// Create the MLArrayBatchProvider used to train the MLModel
    /// It's created using the buffer data,
    private func createUpdateFeatures() -> MLArrayBatchProvider {
        // Get the SarsaTuples
        let data = buffer.batchProvider
        // Create the variable for the Target
        var target: MLFeatureValue
        // Array of MLFeatureProvider that will compose the MLArrayBatchProvider
        // It's composed by MLDictionaryFeatureProvider that contains the 'data' and the 'actions_true' as a dict
        var featureProviders = [MLFeatureProvider]()
        
        // Iter over data from buffer
        for d in data {
            defaultLogger.log("__________\(d.getAction())___________")
            defaultLogger.log("__________\(d.getState())___________")
            defaultLogger.log("__________\(d.getReward())___________")
            defaultLogger.log("__________\(d.getNextState())___________")
            let state = d.getState()
            let action = d.getAction()
            let reward = d.getReward()
            let nextState = d.getNextState()
            
            // Create a MLFeatureValue as input for the model
            let stateValue = MLFeatureValue(multiArray: state)
            // predict value
            let stateTarget = updatedModel!.predictFor(stateValue)!.actions
            defaultLogger.log("Predict livemodel \(stateTarget)")
            
            if convertToArray(from: nextState) != [] {
                // Create a MLFeatureValue as input for the target model
                let nextStateValue = MLFeatureValue(multiArray: nextState)
                
                // take value for next state
                let nextStateActions = targetModel!.predictFor(nextStateValue)!.actions
                let nextStateTarget = convertToArray(from: nextStateActions)
                defaultLogger.log("Predict TargetModel \(nextStateActions)")
                // Update the taget with the max q-value of next state, using a greedy policy
                stateTarget[action] = NSNumber(value: Double(reward) + self.gamma * nextStateTarget.max()!)
            } else {
                stateTarget[action] = NSNumber(value: Double(reward))
            }

            defaultLogger.log("Target Updated \(stateTarget)")
            target = MLFeatureValue(multiArray: stateTarget)
            
            // Create the final Dictionary to build the input
            let dataPointFeatures: [String: MLFeatureValue] = [inputName: stateValue,
                                                            outputName: target]

            if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
             featureProviders.append(provider)
            }
         }
         
        return MLArrayBatchProvider(array: featureProviders.shuffled())
        
    }
    
    open func update() {
        
        // Convert the drawings into a batch provider as the update input.
        let trainingData = createUpdateFeatures()
        defaultLogger.log("\(trainingData.array)")
        if trainingData.count == 0 {
            defaultLogger.info("Training not started caused by no data in buffer")
            return
        }
        
        if !self.isReadyForTraining {
            defaultLogger.info("Training not started caused by too little data in buffer")
            return
        }
        
        // This is how we can change the hyperparameters before training. If you
        // don't do this, the defaults as defined in the mlmodel file are used.
        // Note that the values you choose here must match what is allowed in the
        // mlmodel file, or else Core ML throws an exception.
        let parameters: [MLParameterKey: Any] = [
            .epochs: self.epochs,
            .seed: 1234,
            .miniBatchSize: self.miniBatchSize,
            .learningRate: self.learningRate,
            .shuffle: true,
        ]

        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.parameters = parameters
        
        defaultLogger.log("currentModelURL \(self.updatedModelURL)")
//        loadUpdatedModel()
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: self.updatedModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                     completionHandler: self.updateModelCompletionHandler)
        }
    }
    
    /// The closure an MLUpdateTask calls when it finishes updating the model.
    func updateModelCompletionHandler(updateContext: MLUpdateContext) {
        
        defaultLogger.log("Training completed with state \(updateContext.task.state.rawValue)")
        if updateContext.task.state == .failed {
            defaultLogger.log("Failed")
            defaultLogger.log("\(updateContext.task.error!.localizedDescription)")
            return
          }
        
        self.countTargetUpdate += 1
        
        // Save the updated model to the file system.
        saveUpdatedModel(updateContext)

        // Begin using the saved updated model.
        loadUpdatedModel()
        
        // reset the buffer only after the model trained for sure
        buffer.reset()

        // Inform the calling View Controller when the update is complete
        DispatchQueue.main.async { defaultLogger.log("Trained") }
    }
    
    func progressHandler(context: MLUpdateContext) {
        switch context.event {
        case .trainingBegin:
            defaultLogger.info("Training begin")
        case .miniBatchEnd:
            let batchIndex = context.metrics[.miniBatchIndex] as! Int
//            let batchLoss = context.metrics[.lossValue] as! Double
//            defaultLogger.log("Mini batch \(batchIndex), loss: \(batchLoss)")
            print("batchIndex: \(batchIndex)")
            Tester.readWeights(currentModel: context.model)

        case .epochEnd:
            let epochIndex = context.metrics[.epochIndex] as! Int
            let trainLoss = context.metrics[.lossValue] as! Double
            defaultLogger.info("Epoch \(epochIndex) Loss \(trainLoss)")
            
            Tester.readWeights(currentModel: context.model)
            
        default:
            defaultLogger.log("Unknown event")
        }
    }
    
    @objc open func batchUpdate(batchSize: Int = 32) {
        
        // Convert the drawings into a batch provider as the update input.
        let trainingData = createUpdateFeatures()
//        defaultLogger.log(trainingData.array)
        
        if trainingData.count == 0 {
            defaultLogger.info("Training not started, caused by no data in buffer")
            return
        }
        
        // This is how we can change the hyperparameters before training. If you
        // don't do this, the defaults as defined in the mlmodel file are used.
        // Note that the values you choose here must match what is allowed in the
        // mlmodel file, or else Core ML throws an exception.
        let parameters: [MLParameterKey: Any] = [
            .epochs: self.epochs,
            .seed: 1234,
            .miniBatchSize: 8,
            .learningRate: self.learningRate,
            .shuffle: true,
        ]

        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.parameters = parameters
        defaultLogger.log("currentModelURL \(self.updatedModelURL)")
        
//        loadUpdatedModel()
        
        DispatchQueue.global(qos: .userInitiated).async {
            AppleRLModel.updateModel(at: self.updatedModelURL,
                                        with: trainingData,
                                        parameters: config,
                                        progressHandler: self.progressHandler,
                                     completionHandler: self.updateModelCompletionHandler)
        }
    }
}
