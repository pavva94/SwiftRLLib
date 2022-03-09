//
//  Constants.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation

/// URLS for the background train tasks
public let backgroundTrainURL: String = "com.pavesialessandro.swiftrl.backgroundTrain"
/// URLS for the background listen tasks
public let backgroundListenURL: String = "com.pavesialessandro.swiftrl.backgroundListen"

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
public enum ModelParameter {
    /// The identifier of the agent
    case agentID
    /// The path of the Buffer
    case bufferPath
    /// The path of the database
    case databasePath
    /// Gamma value for the update process
    case gamma
    /// Number of epochs used in training
    case epochs
    /// Batch size for the training
    case batchSize
    /// Training set size
    case trainingSetSize
    /// Learning rate
    case learning_rate
    /// Seconds between two call of the Observe process
    case secondsObserveProcess
    /// Seconds between two call of the Train process
    case secondsTrainProcess
    /// Flag to test the performance during the  training (DEPRECATED)
    case testPerformance
    /// Function to define the end of the episode
    case episodeEnd
}

/// Agent Work Mode defines how the agent works
public enum WorkMode {
    /// Use only the Timers
    case timer
    /// Use only the Background Task
    case background
    /// Use Both background tasks and timers
    case both
}

/// Describes the Agent Mode
public enum AgentMode {
    /// Use the agent with training and observe
    case training
    /// Use the agent only in Inference
    case inference
}

/// Boolean indicating the use or not of the Simulator
public let useSimulator = true
