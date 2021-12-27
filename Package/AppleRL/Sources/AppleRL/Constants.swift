//
//  Constants.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation

/// URLS for the background train tasks
public let backgroundTrainURL: String = "com.pavesialessandro.applerl.backgroundLTrain"
/// URLS for the background listen tasks
public let backgroundListenURL: String = "com.pavesialessandro.applerl.backgroundListen"

/// Names of models files: personalized
let personalizedModelFileName: String = "personalized.mlmodelc"
/// Names of models files: personalized temp
let tempModelFileName: String = "personalized_temp.mlmodelc"
/// Names of models files: target personalized
let personalizedTargetModelFileName: String = "personalizedTarget.mlmodelc"

/// Name of model's inputs
let modelInputName = "data"
/// Name of model's outputs
let modelOutputName = "actions_true"

/// Enum of Parameters accepted by the model in Configurations
public enum ModelParameters {
    case epsilon
    case gamma
    case learning_rate
    case timeIntervalBackgroundMode
}

/// Boolean indicating the use or not of the Simulator
let useSimulator = true
