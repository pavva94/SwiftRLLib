//
//  Buffer.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

extension Array where Element: Comparable {
    func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }
    
    func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}

extension Array {
    func argmax(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows-> Index? {
        return try indices.max { (i, j) throws -> Bool in
            try areInIncreasingOrder(self[i], self[j])
        }
    }
    
    func argmin(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows-> Index? {
        return try indices.min { (i, j) throws -> Bool in
            try areInIncreasingOrder(self[i], self[j])
        }
    }
}

// public typealias sarTuple = (state: Int, action: Int, reward: Int)

import SwiftUI
import CoreML

/// - Tag: LabeledDrawingCollection
public struct ExperienceReplayBuffer {
    
    /// The desired number of drawings to update the model
    private let requiredDataCount = 3
    
    /// Collection of the training drawings
    private var trainingData = [SarsaTupleGeneric]()
    
    /// A Boolean that indicates whether the instance has all the required drawings.
    var isReadyForTraining: Bool { trainingData.count >= requiredDataCount }
    
    init() {
        
    }
    
    var count: Int {
        return trainingData.count
    }
    
    var batchProvider: [SarsaTupleGeneric] {return trainingData}
    
   /// Creates a batch provider of training data given the contents of `trainingData`.
   /// - Tag: DrawingBatchProvider
//    var featureBatchProvider: MLBatchProvider {
//        var featureProviders = [MLFeatureProvider]()
//
//        let inputName = "data"
//        let outputName = "actions"
//                
//        for data in trainingData {
//            let inputValue = data.featureValue
//            let outputValue = MLFeatureValue(int64: 0) // TODO the output value needs to be modified
//            
//            let dataPointFeatures: [String: MLFeatureValue] = [inputName: inputValue,
//                                                               outputName: outputValue]
//            
//            if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPointFeatures) {
//                featureProviders.append(provider)
//            }
//        }
//        
//       return MLArrayBatchProvider(array: featureProviders)
//    }
           
    /// Adds a drawing to the private array, but only if the type requires more.
    mutating func addData(_ data: SarsaTupleGeneric) {
//        if trainingData.count < requiredDataCount {
        trainingData.append(data)
//        }
    }
    
    mutating func reset() {
        self.trainingData = [SarsaTupleGeneric]()
    }
}
