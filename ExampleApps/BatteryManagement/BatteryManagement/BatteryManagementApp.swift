//
//  BatteryManagementApp.swift
//  BatteryManagement
//
//  Created by Alessandro Pavesi on 13/12/21.
//

import SwiftUI
import AppleRL
import BackgroundTasks
//import CoreLocation

class Env1: Env {
    override func reward(state: [Double], action: Int, nextState: [Double]) -> Double {
        var reward: Double = 0.0
        // reward +1 when:
        // is night (>23.30) and the agent want to activate or leave if it is already active the LPM
        // the battery is under 25% and activate
        // i'm at home and activate
        // it's morning and the battery is over 50%
        
        // reward -1 when:
        // deactivate at night
        // activate outside with high battery (>60%)
        // deactivate with low battery (<25%)
        
//        print(state)
        
        let lat = state[0]
        let long = state[1]
        let battery = state[0]
        let hourRL = state[1]
        let minuteRL = state[2]
        let brightness = state[3]
        
        
//        if hourRL > 23 && ( (lowPowerMode == 1.0 && action == 1) || (lowPowerMode == 0.0 && action == 2)) {
//            reward = 1.0
//        } else if battery <= 25.0 && action == 2 {
//            reward = 1.0
//        } else if hourRL > 7 && battery >= 50 && ( (lowPowerMode == 1.0 && action == 0) || (lowPowerMode == 0.0 && action == 1)) {
//            reward = 1.0
//        } else if hourRL > 23 && (lowPowerMode == 1.0 && action == 2) {
//            reward = -1.0
//        } else if battery > 60.0 && action == 2 {
//            reward = -1.0
//        } else if battery <= 25 && ( (lowPowerMode == 1.0 && action == 0) || (lowPowerMode == 0.0 && action == 1)) {
//            reward = -1.0
//        }
        
        // check some state-action that cannot be done
        let watchingNetflix = Double.random(in: 0...1)
//        let usingBluetooth = Double.random(in: 0...1)

        
        // Case 1: if i'm watching ntflix (20% of the time) and the agent want to decrese brightness, NOT permitted -10
        if watchingNetflix < 0.2 && action == 2 && [18.0, 19.0].contains(hourRL){
            print("i'm watching netflix: -10")
            reward += -10
//        }
//        // Case 2: if the battery is under 20% and the agent want to deactivate LPM, NOT permitted -10
//        else if battery < 0.2 && action == 2 {
//            print("the battery is under 20% and the agent want to deactivate: -10")
//            reward += -10
        }
        if battery < 0.0 {
            print("the battery is dead: -20")
            reward += -20
        }
        if brightness < 0.1 && action != 1 {
            print("Do not modify the brightness when closed: -20")
            reward += -20
        }
        
        
        // Final reward based on what the agent need to maximise
        // here the difference between the current battery value and the battery value of previous state 
        reward += nextState[0] - battery
        
        print("Final reward: \(reward)")
        
        return reward.customRound(.toNearestOrAwayFromZero)
    }
}

//class DQN1: DeepQNetwork {
//    @objc open override func listen() {
//        let state = environment.read()
//        let mlstate = convertToMLMultiArrayFloat(from:state)
//        print("New Listen: \(state)")
//        let action = self.act(state: mlstate)
//        print("New Action: \(action)")
//        let reward = environment.reward(state: state, action: action)
//        print("New Reward: \(reward)")
//
//        // adjust the nextState
//        var nextState = state
//        if action == 0 { // action deactivate
//            nextState[6] = 0.0
//        } else if action == 2 { // action activate
//            nextState[6] = 1.0
//        }
//        let mlNextState = convertToMLMultiArrayFloat(from:nextState)
//        // in-App use means the user needs to give a reward using the app and only then the SarsaTuple is saved and used for training
//        // here the online-use
////        let newNextState = convertToMLMultiArrayFloat(from:next_state)
//        self.store(state: mlstate, action: action, reward: reward, nextState: mlNextState)
//    }
//}

let actionsArray: [Action] = [BrightnessDecrese(), BrightnessLeaveIt(), BrightnessIncrese()]
var environment: Env = Env1(sensors: ["battery", "clock", "brightness"], actions: actionsArray, actionSize: 3)
let params: Dictionary<ModelParameters, Any> = [.epsilon: Double(0.3), .learning_rate: Double(0.15), .gamma: Double(0.5), .timeIntervalBackgroundMode: Double(30*60)]
let qnet: DeepQNetwork = DeepQNetwork(env: environment, parameters: params)
var firstOpen = true
let locationManager = LocationManagerRL()

@main
struct BatteryManagementApp: App {
    
    init(){
//        resetDatabase(path: "database.json")
//        resetDatabase(path: "buffer.json")
//        print("Background tasks registered")
//        BGTaskScheduler.shared.register(
//          forTaskWithIdentifier: backgroundListenURL,
//          using: nil) { (task) in
//            print("Listen Task handler")
//              qnet.handleAppRefreshTask(task: task as! BGAppRefreshTask)
//        }
//
//        BGTaskScheduler.shared.register(
//          forTaskWithIdentifier: backgroundTrainURL,
//          using: nil) { (task) in
//            print("Background Task handler")
//              qnet.handleTrainingTask(task: task as! BGProcessingTask)
//        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(databaseDataApp: loadDatabase("database.json"), qnet: qnet, actionsArray: actionsArray).onAppear(perform: initializeRL)
        }
    }
    
    func initializeRL() {
        if firstOpen {
//            let state = environment.read()
////            resetDatabase(path: "database.json")
//            let MLState = convertToMLMultiArrayFloat(from:state)
//            print("Listen: \(state)")
//            let action = qnet.act(state: MLState)
//            print("Action: \(action)")
            
//            var reward: Double = 0.0
//            // reward +1 when:
            // is night (>23.30) and the agent want to activate or leave if it is already active the LPM
            // the battery is under 25% and activate
            // i'm at home and activate
            // it's morning and the battery is over 50%
            
            // reward -1 when:
            // deactivate at night
            // activate outside with high battery (>60%)
            // deactivate with low battery (<25%)
            
//            let lat = state[0]
//            let long = state[1]
//            let battery = state[2]
//            let hourRL = state[3]
//            let lowPowerMode = state[6]
//
//
//            if hourRL > 23 && ( (lowPowerMode == 1.0 && action == 1) || (lowPowerMode == 0.0 && action == 2)) {
//                reward = 1.0
//            } else if battery <= 25.0 && action == 2 {
//                reward = 1.0
//            } else if hourRL > 7 && battery >= 50 && ( (lowPowerMode == 1.0 && action == 0) || (lowPowerMode == 0.0 && action == 1)) {
//                reward = 1.0
//            } else if hourRL > 23 && (lowPowerMode == 1.0 && action == 2) {
//                reward = -1.0
//            } else if battery > 60.0 && action == 2 {
//                reward = -1.0
//            } else if battery <= 25 && ( (lowPowerMode == 1.0 && action == 0) || (lowPowerMode == 0.0 && action == 1)) {
//                reward = -1.0
//            }
//
//
//
//            qnet.store(state: MLState, action: action, reward: reward, nextState: MLState)
            
            
            qnet.startListen(interval: 5)
            qnet.startTrain(interval: 30)
//            BGTaskScheduler.shared.cancelAllTaskRequests()
//            qnet.scheduleBackgroundSensorFetch()
//            qnet.scheduleBackgroundTrainingFetch()
            print("------------- \(qnet.getDeafultModelURL())")
            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getDeafultModelURL())
            print("------------- \(qnet.getModelURL())")
            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
            print("-------------")
//            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
//            print("-------------")
//            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
//            print("-------------")
//            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
//            print("-------------")
//            Tester.checkCorrectPrediction(environment: environment, urlModel: qnet.getModelURL())
//            print("-------------")
            }
        firstOpen = false
        
    }
}
