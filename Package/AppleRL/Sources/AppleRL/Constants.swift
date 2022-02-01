//
//  Constants.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation

/// URLS for the background train tasks
public let backgroundTrainURL: String = "com.pavesialessandro.applerl.backgroundTrain"
/// URLS for the background listen tasks
public let backgroundListenURL: String = "com.pavesialessandro.applerl.backgroundListen"

/// Names of models files: personalized
let personalizedModelFileName: String = "personalized.mlmodelc"
/// Names of models files: personalized temp
let tempModelFileName: String = "personalized_temp.mlmodelc"
/// Names of models files: target personalized
let personalizedTargetModelFileName: String = "personalizedTarget.mlmodelc"

/// Database used to check all the action done by the agent
let databasePath: String = "database.json"
/// Permanent store of the buffer
let bufferPath: String = "buffer.json"

/// Name of model's inputs
let modelInputName = "data"
/// Name of model's outputs
let modelOutputName = "actions_true"

/// Enum of Parameters accepted by the model in Configurations
public enum ModelParameters {
    case epsilon
    case gamma
    case epochs
    case batchSize
    case trainingSetSize
    case learning_rate
    case timeIntervalBackgroundMode
    case timeIntervalTrainingBackgroundMode
    case testPerformance
}

public enum ObserveMode {
    case timer
    case background
    case both
}

/// Boolean indicating the use or not of the Simulator
public let useSimulator = false
