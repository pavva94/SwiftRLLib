//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation


let backgroundTrainURL: String = "com.pavesialessandro.applerl.backgroundLTrain"
let backgroundListenURL: String = "com.pavesialessandro.applerl.backgroundListen"

let personalizedModelFileName: String = "personalized.mlmodelc"
let tempModelFileName: String = "personalized_temp.mlmodelc"
let personalizedTargetModelFileName: String = "personalizedTarget.mlmodelc"

/// Name of model's inputs
let modelInputName = "data"
let modelOutputName = "actions_true"

public enum ModelParameters {
    case epsilon
    case gamma
    case learning_rate
    case timeIntervalBackgroundMode
}

let useSimulator = true
