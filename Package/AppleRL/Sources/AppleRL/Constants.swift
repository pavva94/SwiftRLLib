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
let personalizedModelFileName: String = "personalized"
/// Names of models files: personalized temp
let tempModelFileName: String = "personalized_temp"
/// Names of models files: target personalized
let personalizedTargetModelFileName: String = "personalizedTarget"
let modelFileExtension: String = ".mlmodelc"

/// Database used to check all the action done by the agent
let defaultDatabasePath: String = "database"
/// Permanent store of the buffer
let defaultBufferPath: String = "buffer"
let dataManagerFileExtension: String = ".json"

/// Name of model's inputs
let modelInputName = "data"
/// Name of model's outputs
let modelOutputName = "actions_true"

/// Enum of Parameters accepted by the model in Configurations
public enum ModelParameters {
    case agentID
    case bufferPath
    case databasePath
    case epsilon
    case gamma
    case epochs
    case batchSize
    case trainingSetSize
    case learning_rate
    case secondsObserveProcess
    case secondsTrainProcess
    case testPerformance
}

public enum WorkMode {
    case timer
    case background
    case both
}

public enum AgentMode {
    case training
    case inference
}

/// Boolean indicating the use or not of the Simulator
public let useSimulator = false
