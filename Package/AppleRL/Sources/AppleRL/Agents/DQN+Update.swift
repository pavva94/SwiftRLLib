//
//  DQN+Update.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation
import CoreML
import MetricKit

extension DeepQNetwork {
    
//    // Batch update used by the Timer mode (that needs the function to be @objc)
//    /// Calls the updateModel on the AppleRLModel with data from createUpdateFeatures() and parameter from Env
//    @objc open override func update() {
//        
//        // Convert the drawings into a batch provider as the update input.
//        let trainingData = createUpdateFeatures()
////        defaultLogger.log(trainingData.array)
//        
//        if trainingData.count == 0 {
//            defaultLogger.info("Training not started, caused by no data in buffer")
//            return
//        }
//        
//        // This is how we can change the hyperparameters before training. If you
//        // don't do this, the defaults as defined in the mlmodel file are used.
//        // Note that the values you choose here must match what is allowed in the
//        // mlmodel file, or else Core ML throws an exception.
//        let parameters: [MLParameterKey: Any] = [
//            .epochs: self.epochs,
//            .seed: 42,
//            .miniBatchSize: self.miniBatchSize,
//            .learningRate: self.learningRateDecayMode ? self.learningRate[
//                        self.trainingCounter<self.learningRate.count ? self.trainingCounter: self.learningRate.count-1
//                    ] : self.learningRate[0],
//            .shuffle: true,
//        ]
//
//        let config = MLModelConfiguration()
//        config.computeUnits = .all
//        config.parameters = parameters
//        defaultLogger.log("currentModelURL \(self.updatedModelURL)")
//        
//        let trainLogHandle = MXMetricManager.makeLogHandle(category: "Train")
//        mxSignpost(
//            .begin,
//          log: trainLogHandle,
//          name: "Train")
//        
//        let startTrainLogHandle = MXMetricManager.makeLogHandle(category: "Train")
//        mxSignpost(
//            .begin,
//          log: startTrainLogHandle,
//          name: "Start Train")
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            AppleRLModel.updateModel(at: self.updatedModelURL,
//                                        with: trainingData,
//                                        parameters: config,
//                                        progressHandler: self.progressHandler,
//                                     completionHandler: self.updateModelCompletionHandler)
//        }
//    }
}
