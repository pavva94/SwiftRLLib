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
    
    let defaults = UserDefaults.standard
    
    /// Collection of the training drawings
    private var trainingData = [SarsaTupleGeneric]()
    
    public var isEmpty = true
    
    /// The last state
    var lastData: SarsaTupleGeneric
    
    init() {
        do {
            let db = loadDatabase(bufferPath)
            for data in db {
                trainingData.append(SarsaTupleGeneric(state: try MLMultiArray(data.state), action: data.action, reward: data.reward))
            }
            if trainingData.isEmpty {
                lastData = SarsaTupleGeneric(state: try MLMultiArray([0]), action: 0, reward: 0.0)
            } else {
                lastData = trainingData.last!
                isEmpty = false
            }
            print("buffer ready: \(trainingData.count)")
        } catch {
            defaultLogger.error("Error during initialization of buffer: \(error.localizedDescription)")
            fatalError()
        }
    }
    
    var count: Int {
        return trainingData.count
    }
    
    
    var batchProvider: [SarsaTupleGeneric] { return trainingData }
    
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

    
    /// Override last data, this means the tuple si done so save it also in the database
//    mutating func overrideLastOne(tuple: SarsaTupleGeneric) -> Void {
//        trainingData[trainingData.count-1] = tuple
//        var idCounter: Int = self.defaults.integer(forKey: "idCounter")
//        let temp = DatabaseData(id: idCounter, state: convertToArray(from: tuple.getState()), action: tuple.getAction(), reward: tuple.getReward(), nextState: convertToArray(from: tuple.getNextState()))
//        
//        idCounter += 1
//        self.defaults.set(idCounter, forKey: "idCounter")
//        addDataToDatabase(temp, bufferPath)
//        
//        self.lastState = tuple
//    }
    
    mutating func setLastData(_ data: SarsaTupleGeneric) {
        if isEmpty {
            isEmpty = false
        }
        lastData = data
    }
           
    /// Adds a drawing to the private array, but only if the type requires more.
    mutating func addData(_ data: SarsaTupleGeneric) {
        trainingData.append(data)
        var idCounter: Int = self.defaults.integer(forKey: "idCounter")
        let temp = DatabaseData(id: idCounter, state: convertToArray(from: data.getState()), action: data.getAction(), reward: data.getReward(), nextState: convertToArray(from: data.getNextState()))
        
        idCounter += 1
        self.defaults.set(idCounter, forKey: "idCounter")
        addDataToDatabase(temp, bufferPath)
        addDataToDatabase(temp, databasePath)
    }
    
    mutating func reset() {
        self.trainingData = []
        self.defaults.set(0, forKey: "idCounter")
        resetDatabase(path: bufferPath)
        do {
            let db = loadDatabase(bufferPath)
            for data in db {
                trainingData.append(SarsaTupleGeneric(state: try MLMultiArray(data.state), action: data.action, reward: data.reward))
            }
            print("buffer ready: \(trainingData.count)")
        } catch {
            defaultLogger.error("Error during Resetting of buffer: \(error.localizedDescription)")
        }
    }
}
