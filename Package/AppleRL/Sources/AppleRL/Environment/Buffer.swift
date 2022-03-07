//
//  Buffer.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import SwiftUI
import CoreML

/// Expericence Replay Buffer
public struct ExperienceReplayBuffer {
    
    /// User defaults
    let defaults = UserDefaults.standard
    /// Path of the buffer
    var bufferPath: String = defaultBufferPath
    /// Path of the database
    var databasePath: String = defaultDatabasePath
    /// Max size of the data keeped
    var maxLength: Int = 512
    /// Max size of the training data returned
    var batchSize: Int = 256
    
    /// Collection of the training data
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
    
    /// Return the dimension fo the buffer
    var count: Int {
        return trainingData.count
    }
    
    /// Creates a batch provider of training data given the contents of `trainingData`.
    mutating func batchProvider() -> [SarsaTupleGeneric] {
        return Array(trainingData.choose(self.batchSize))
        
    }
    
    /// Set last data to be keeped
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
    
    /// Reset the Buffer
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
