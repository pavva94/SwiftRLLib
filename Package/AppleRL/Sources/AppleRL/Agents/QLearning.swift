//
//  QLearning.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import CoreML


open class QLearning: Agent {
    
    open var buffer: ExperienceReplayBuffer = ExperienceReplayBuffer()
    private typealias SarsaTuple = SarsaTupleGeneric
    
    var environment: Env
    var policy: Policy
    
    /// Matrix for the Q-Value
    var qTable: [[Double]] = []
    /// Dict of states, used to transform a string state to a index value for the qTable
    var states: Dictionary<String, Int> = [:]
    /// Maximum index for the qTable
    var maxStateId: Int = -1
    /// Epsilon for the policy
    var epsilon: Double = 0.6
    /// Learning rate standard
    var lr: Double = 0.0001
    /// Gamma standard
    var gamma: Double = 0.9
    /// Training size standard
    var trainingSetSize: Int = 64
    
    /// File path of the saved qTable
    var path: URL = URL(fileURLWithPath: "")
    
    required public init(env: Env, policy: Policy, parameters: Dictionary<ModelParameters, Any>) {
        self.environment = env
        self.policy = policy
        super.init()
        
        // General parameter
        self.modelID = parameters.keys.contains(.agentID) ? (parameters[.agentID] as? Int)! : self.modelID
        self.bufferPath = parameters.keys.contains(.bufferPath) ? (parameters[.bufferPath] as? String)! : self.bufferPath + String(self.modelID) + dataManagerFileExtension
        self.databasePath = parameters.keys.contains(.databasePath) ? (parameters[.databasePath] as? String)! : self.databasePath + String(self.modelID) + dataManagerFileExtension
        self.trainingSetSize = parameters.keys.contains(.trainingSetSize) ? (parameters[.trainingSetSize] as? Int)! : self.trainingSetSize
        self.buffer = ExperienceReplayBuffer(self.trainingSetSize, bufferPath: self.bufferPath, databasePath: self.databasePath)
        
        self.secondsTrainProcess = parameters.keys.contains(.secondsTrainProcess) ? (parameters[.secondsTrainProcess] as? Int)! : 2*60*60 // 2 ore
        self.secondsObserveProcess = parameters.keys.contains(.secondsObserveProcess) ? (parameters[.secondsObserveProcess] as? Int)! : 10*60 // 10 minuti

        
        self.lr = (parameters[.learning_rate] as? Double)!
        self.gamma = (parameters[.gamma] as? Double)!
        
        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("QLearningOrientation_\(self.modelID).plist")
        load()
    }
    
    /// Store data into the buffer
    func store(state: [Double], action: Int, reward: Double, nextState: [Double]) {
        let tuple = SarsaTuple(state: convertToMLMultiArrayFloat(from: state), action: action, reward: reward, nextState: convertToMLMultiArrayFloat(from: nextState))
        buffer.addData(tuple)
    }

    /// Get Q-Table
    func getQValue() -> [[Double]] {
        return qTable
    }
    
    /// Epsilon greedy policy fixed
    func epsilonGreedy(state: Int) -> Int {
        if Double.random(in: 0..<1) < epsilon {
            // epsilon choice
            return Int.random(in: 0..<self.environment.getActionSize())
        }
        else {
            return qTable[state].argmax()!
        }
    }
    
    /// Model act
    open func act(state: Int) -> Int {
        return epsilonGreedy(state: state)
    }

    /// Train the model, updating the Q-Values
    open override func update() {
        print("UPDATE")

        let data = buffer.batchProvider()

        var i = 0
        while i < data.count {
            let tuple: SarsaTuple = data[i]
//            defaultLogger.log("\(tuple)")
            let s: Int = self.manageStates(convertToArray(from: tuple.getState())), a: Int = tuple.getAction(), r: Double = tuple.getReward()

            var maxQtable: [Double] = []
            for i in 0..<self.maxStateId {
                maxQtable.append(self.qTable[i].max()!)
            }

            let temp : Double = Double(r) + gamma * maxQtable.max()! - qTable[s][a]
            qTable[s][a] = qTable[s][a] + lr * temp
//            defaultLogger.log("\(self.qTable)")
            i += 1
        }
//        buffer.reset()


//        let s:Int = tuple.state, a:Int = tuple.action, r:Int = tuple.reward
//
//        var maxQtable: [Float] = []
//        for i in 0...self.environment.get_state_size() {
//            maxQtable.append(self.qTable[i].max()!)
//        }
//
//        qTable[s][a] = qTable[s][a] + lr * (Float(r) + gamma * maxQtable.max()! - qTable[s][a])
//        defaultLogger.log(qTable)
        save()
    }

//    @objc open override func update() {
//
//        // TODO this isn't a batchupdate
//        let data = buffer.batchProvider()
//
//        var i = 0
//        while i < data.count {
//            let tuple: SarsaTuple = data[i]
////            defaultLogger.log(tuple)
//            let s: Int = Int(convertToArray(from: tuple.getState())[0]), a: Int = tuple.getAction(), r: Double = tuple.getReward()
//
//            var maxQtable: [Double] = []
//            for i in 0...self.environment.getStateSize() {
//                maxQtable.append(self.qTable[i].max()!)
//            }
//            let temp : Double = Double(r) + gamma * maxQtable.max()! - qTable[s][a]
//            qTable[s][a] = qTable[s][a] + lr * temp
//            defaultLogger.log("\(self.qTable)")
//            i += 1
//        }
//        buffer.reset()
//    }
    
    /// Manages the states, checking if exists or not and then return the corresponding index
    private func manageStates(_ state: [Double]) -> Int {
        
        var strState = ""
        for s in state {
            strState += String(s)
        }
        
        var stateId: Int = 0
        
        if states.keys.contains(strState) {
            stateId = states[strState]!
        } else {
            states[strState] = self.maxStateId
            stateId = self.maxStateId
            self.maxStateId += 1
            var newValue: [Double] = []
            for _ in 0..<self.environment.getActionSize() {
                newValue.append(Double.random(in: 0...1))
            }
            self.qTable.append(newValue)
            assert(qTable.count == self.maxStateId)
            
        }
//        print(self.states.count)
//        print(self.states)
//        print(self.qTable)
        save()
        
        return stateId
    }
    
    /// Read the environment and act
    @objc open override func listen() {
        let state = environment.read()
        defaultLogger.log("\(state)")
        
        // check if state is terminal
        if state == [] {
            do {
                defaultLogger.log("Terminal State reached")
                let newState = [Double]()
                let reward = self.environment.reward(state: convertToArray(from: self.buffer.lastData.getState()), action: self.buffer.lastData.getAction(), nextState: state)
                self.store(state: convertToArray(from: self.buffer.lastData.getState()), action: self.buffer.lastData.getAction(), reward: reward, nextState: newState)
                // wait the overriding of last tuple to save current tuple
                self.buffer.isEmpty = true
                return
            } catch {
                defaultLogger.error("Error saving terminal state: \(error.localizedDescription)")
                return
            }
        }
        
        // use the state dictionary to map the state into a integer
        // transform the env state into a string and takes the integer from the dict
        let stateId = manageStates(state)
        
        let action = self.act(state: stateId)
        environment.act(state: [Double(stateId)], action: action)
//        let reward = environment.reward(state: [state], action: action)
//        //let next_state = result.1
//        self.store(state: Int(state), action: action, reward: reward)
        
        defaultLogger.log("Buffer count \(self.buffer.count)")
        if !self.buffer.isEmpty {
            // then we are done with the current tuple we can take care of finish the last one
            let last_data = self.buffer.lastData
    //        let newNextState = convertToMLMultiArrayFloat(from:state)
            // retrieve the reward based on the old state, the current state and the action done in between
            let lastState = convertToArray(from: last_data.getState())
//            let lastStateId = manageStates(lastState)
            
            
            let reward = environment.reward(state: lastState, action: last_data.getAction(), nextState: state)
            self.store(state: lastState, action: last_data.getAction(), reward: reward, nextState: state)
        }
        let newState = convertToMLMultiArrayFloat(from: state)
        self.buffer.setLastData(SarsaTuple(state: newState, action: action, reward: 0.0))
        
        // wait the overriding of last tuple to save current tuple
//        self.buffer.addData(SarsaTuple(state: convertToMLMultiArrayFloat(from: [state]), action: action, reward: 0.0))
    }
    
    /// Save the qTable and others parameters
    open override func save() {
        defaultLogger.log("Save")
        // Save to file
        (self.qTable as NSArray).write(to: path, atomically: true)
        self.defaults.set(self.states, forKey: "statesDict")
        self.defaults.set(self.maxStateId, forKey: "maxStateId")
    }
    
    /// Load the qTable and others parameters
    open override func load() {
        defaultLogger.log("Load")
        // Read from file
        var savedArray: [[Double]] = []
        if NSArray(contentsOf: path) != nil {
            savedArray = NSArray(contentsOf: path)  as! [[Double]]
        }
//        defaultLogger.log("QL Table \(savedArray)")
        self.qTable = savedArray
        
        var states: Dictionary<String, Int> = [:]
        if self.defaults.dictionary(forKey: "statesDict") != nil {
            states = self.defaults.dictionary(forKey: "statesDict")  as! Dictionary<String, Int>
        }
//        defaultLogger.log("QL states\(states)")
        self.states = states
        
        var maxStateId: Int = -1
        if self.defaults.integer(forKey: "maxStateId") != nil {
            maxStateId = self.defaults.integer(forKey: "maxStateId")  as! Int
        }
//        defaultLogger.log("QL maxStateId\(maxStateId)")
        self.maxStateId = maxStateId
    }
}

