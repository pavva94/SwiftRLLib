//
//  Environment2DApp.swift
//  Environment2D
//
//  Created by Alessandro Pavesi on 02/03/22.
//

import SwiftUI
import AppleRL


//let actionsArray: [Action] = [ActionLeft(), ActionRight()]
//let reward: [Reward] = [Reward2D()]
//var environment: Env = Env(observableData: [], actions: actionsArray, rewards: reward, actionSize: 2)
//let params: Dictionary<ModelParameters, Any> = [.agentID: 0, .batchSize: 64, .learning_rate: Double(0.00001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 60]
//let qnet: DeepQNetwork = DeepQNetwork(env: environment, policy: EpsilonGreedy(id: 1), parameters: params)
//
//let newSensor = MatrixSens()
//
//
let actionsArray2: [Action] = [ActionLeft2(), ActionRight2()]
let reward2: [Reward] = [Reward2D()]
var environment2: Env = Env(observableData: [], actions: actionsArray2, rewards: reward2, actionSize: 2)
let params2: Dictionary<ModelParameters, Any> = [.agentID: 1, .batchSize: 64, .learning_rate: Double(0.000001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 60]
let qnet2: QLearning = QLearning(env: environment2, policy: EpsilonGreedy(id: 1), parameters: params2)

let newSensor2 = MatrixSens()



let actionsArray3: [Action] = [ActionLeft3(), ActionRight3()]
let reward3: [Reward] = [Reward2D()]
var environment3: Env = Env(observableData: [], actions: actionsArray3, rewards: reward3, actionSize: 2)
let params3: Dictionary<ModelParameters, Any> = [.agentID: 2, .batchSize: 64, .learning_rate: Double(0.00001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 60]
let qnet3: QLearning = QLearning(env: environment3, policy: EpsilonGreedy(id: 2), parameters: params3)

let newSensor3 = MatrixSens()


let actionsArray4: [Action] = [ActionLeft4(), ActionRight4()]
let reward4: [Reward] = [Reward2D()]
var environment4: Env = Env(observableData: [], actions: actionsArray4, rewards: reward4, actionSize: 2)
let params4: Dictionary<ModelParameters, Any> = [.agentID: 3, .batchSize: 64, .learning_rate: Double(0.0001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 60]
let qnet4: QLearning = QLearning(env: environment4, policy: EpsilonGreedy(id: 3), parameters: params4)

let newSensor4 = MatrixSens()

@main
struct Environment2DApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: initializeRL)
        }
    }
    
    func initializeRL()  {
//        environment.addObservableData(s: newSensor)
        environment2.addObservableData(s: newSensor2)
        environment3.addObservableData(s: newSensor3)
        environment4.addObservableData(s: newSensor4)
//        qnet.observe(.timer, .training)
        qnet2.observe(.timer, .training)
        qnet3.observe(.timer, .training)
        qnet4.observe(.timer, .training)
    }
}
