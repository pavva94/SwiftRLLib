//
//  Buffer.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import SwiftUI
import CoreML

/// - Tag: LabeledDrawingCollection
public struct ExperienceReplayBuffer {
    
    let defaults = UserDefaults.standard
    
    var bufferPath: String = defaultBufferPath
    var databasePath: String = defaultDatabasePath
    var maxLength: Int = 512
    var batchSize: Int = 256
    
    /// Collection of the training drawings
    private var trainingData = [SarsaTupleGeneric]()
    
    public var isEmpty = true
    
    /// The last state
    var lastData: SarsaTupleGeneric
    
    init(_ batchSize: Int = 256, _ maxBufferLength: Int = 512, bufferPath: String = defaultBufferPath, databasePath: String = defaultDatabasePath) {
        self.bufferPath = bufferPath
        self.databasePath = databasePath
        self.maxLength = maxBufferLength
        self.batchSize = batchSize
        
        do {
            let db = dataManager.loadDatabase(bufferPath)
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
    
    /// Creates a batch provider of training data given the contents of `trainingData`.
    mutating func batchProvider() -> [SarsaTupleGeneric] {
        return Array(trainingData.choose(self.batchSize))
        
    }
    
    mutating func setLastData(_ data: SarsaTupleGeneric) {
        if isEmpty {
            isEmpty = false
        }
        lastData = data
    }
           
    /// Adds a drawing to the private array, but only if the type requires more.
    mutating func addData(_ data: SarsaTupleGeneric) {
        if trainingData.count >= self.maxLength {
            trainingData = Array(trainingData.suffix(from: 1))
            dataManager.removeFirstDataFromDatabase(bufferPath)
        }
        
        trainingData.append(data)
        
        var idBufferCounter: Int = self.defaults.integer(forKey: "idBufferCounter")
        var temp = DatabaseData(id: idBufferCounter, state: convertToArray(from: data.getState()), action: data.getAction(), reward: data.getReward(), nextState: convertToArray(from: data.getNextState()))
        
        idBufferCounter += 1
        self.defaults.set(idBufferCounter, forKey: "idBufferCounter")
        dataManager.addDataToDatabase(temp, bufferPath)
        
        var idDatabaseCounter: Int = self.defaults.integer(forKey: "idDatabaseCounter")
        temp = DatabaseData(id: idDatabaseCounter, state: convertToArray(from: data.getState()), action: data.getAction(), reward: data.getReward(), nextState: convertToArray(from: data.getNextState()))
        
        idDatabaseCounter += 1
        self.defaults.set(idDatabaseCounter, forKey: "idDatabaseCounter")
        dataManager.addDataToDatabase(temp, databasePath)
    }
    
    mutating func reset() {
        self.trainingData = []
        self.defaults.set(0, forKey: "idBufferCounter")
        dataManager.resetDatabase(path: bufferPath)
        do {
            let db = dataManager.loadDatabase(bufferPath)
            for data in db {
                trainingData.append(SarsaTupleGeneric(state: try MLMultiArray(data.state), action: data.action, reward: data.reward))
            }
            print("buffer ready: \(trainingData.count)")
        } catch {
            defaultLogger.error("Error during Resetting of buffer: \(error.localizedDescription)")
        }
    }
}
