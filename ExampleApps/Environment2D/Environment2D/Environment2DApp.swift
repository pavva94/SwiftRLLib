//
//  Environment2DApp.swift
//  Environment2D
//
//  Created by Alessandro Pavesi on 02/03/22.
//

import SwiftUI
import SwiftRL


let actionsArray: [Action] = [ActionLeft(), ActionRight()]
let reward: [Reward] = [Reward2D()]
var environment = Environment(observableData: [], actions: actionsArray, rewards: reward)
let params: Dictionary<ModelParameter, Any> = [.agentID: 1, .batchSize: 64, .learning_rate: Double(0.000001), .gamma: Double(0.999), .secondsObserveProcess: 1, .secondsTrainProcess: 60, .episodeEnd: episodeEndFalse]
let qnet: QLearning = QLearning(env: environment, policy: EpsilonGreedy(id: 1), parameters: params)

let newSensor = MatrixSens()

@main
struct Environment2DApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear(perform: initializeRL)
        }
    }
    
    func initializeRL()  {
        environment.addObservableData(s: newSensor)

        qnet.start(.timer, .training)

    }
}
