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
    
   
    var qTable: [[Double]] = []
    var states: Dictionary<String, Int> = [:]
    var maxStateId: Int = -1
    var epsilon: Double = 0.6
    var lr: Double = 0.0001
    var gamma: Double = 0.9
    var trainingSetSize: Int = 64
    
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
        
        
        self.lr = (parameters[.learning_rate] as? Double)!
        self.gamma = (parameters[.gamma] as? Double)!
//        var temp: [[Double]] = []
//        for i in 0...env.getStateSize() {
//            temp.append([])
//            for _ in 0...env.getActionSize() {
//                temp[i].append(0.0)
//            }
//        }
//        self.qTable = temp
//        defaultLogger.log("\(temp)")
        
        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("QLearningOrientation.plist")
        
    }

    func store(state: Int, action: Int, reward: Double, nextState: Int) {
        let tuple = SarsaTuple(state: convertToMLMultiArrayFloat(from:[state]), action: action, reward: reward, nextState: convertToMLMultiArrayFloat(from:[nextState]))
        buffer.addData(tuple)
    }

    func getQValue() -> [[Double]] {
        return qTable
    }

    func epsilonGreedy(state: Int) -> Int {
        if Double.random(in: 0..<1) < epsilon {
            // epsilon choice
            return Int.random(in: 0..<self.environment.getActionSize()+1)
        }
        else {
            return qTable[state].argmax()!
        }
    }

    open func act(state: Int) -> Int {

        return epsilonGreedy(state: state)
    }

    open override func update() {

        let data = buffer.batchProvider()

        var i = 0
        while i < data.count {
            let tuple: SarsaTuple = data[i]
//            defaultLogger.log("\(tuple)")
            let s: Int = Int(convertToArray(from: tuple.getState())[0]), a: Int = tuple.getAction(), r: Double = tuple.getReward()

            var maxQtable: [Double] = []
            for i in 0...self.environment.getStateSize() {
                maxQtable.append(self.qTable[i].max()!)
            }

            let temp : Double = Double(r) + gamma * maxQtable.max()! - qTable[s][a]
            qTable[s][a] = qTable[s][a] + lr * temp
            defaultLogger.log("\(self.qTable)")
            i += 1
        }
        buffer.reset()


//        let s:Int = tuple.state, a:Int = tuple.action, r:Int = tuple.reward
//
//        var maxQtable: [Float] = []
//        for i in 0...self.environment.get_state_size() {
//            maxQtable.append(self.qTable[i].max()!)
//        }
//
//        qTable[s][a] = qTable[s][a] + lr * (Float(r) + gamma * maxQtable.max()! - qTable[s][a])
//        defaultLogger.log(qTable)
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
    
    func manageStates(_ state: [Double]) -> Int {
        
        var strState = ""
        for s in state {
            strState += String(s)
        }
        
        var stateId: Int = 0
        
        if states.keys.contains(strState) {
            stateId = states[strState]!
        } else {
            states[strState] = self.maxStateId + 1
            self.maxStateId += 1
            assert(qTable.count == self.maxStateId)
            
            
            stateId = self.maxStateId
            self.qTable.append([Double.random(in: 0...1), Double.random(in: 0...1)])
            
        }
//        print(self.states.count)
//        print(self.states)
//        print(self.qTable)
        
        return stateId
    }

    @objc open override func listen() {
        let state = environment.read()
        defaultLogger.log("\(state)")
        
        // use the state dictionary to map the state into a integer
        // transform the env state into a string and takes the integer from the dict
        let stateId = manageStates(state)
        
        let action = self.act(state: stateId)
        environment.act(state: [Double(stateId)], action: action)
//        let reward = environment.reward(state: [state], action: action)
//        //let next_state = result.1
//        self.store(state: Int(state), action: action, reward: reward)
        
        if self.buffer.count > 0 {
            // then we are done with the current tuple we can take care of finish the last one
            let last_data = self.buffer.lastData
    //        let newNextState = convertToMLMultiArrayFloat(from:state)
            // retrieve the reward based on the old state, the current state and the action done in between
            
            let lastStateId = manageStates(convertToArray(from: last_data.getState()))
            
            
            let reward = environment.reward(state:  [Double(lastStateId)], action: last_data.getAction(), nextState: [Double(stateId)])
            self.store(state: lastStateId, action: last_data.getAction(), reward: reward, nextState: stateId)
        }
        
        // wait the overriding of last tuple to save current tuple
//        self.buffer.addData(SarsaTuple(state: convertToMLMultiArrayFloat(from: [state]), action: action, reward: 0.0))
    }

    

    open override func save() {
        defaultLogger.log("Save")
        // Save to file
        (self.qTable as NSArray).write(to: path, atomically: true)
        self.defaults.set(self.states, forKey: "statesDict")
    }

    open override func load() {
        defaultLogger.log("Load")
        // Read from file
        let savedArray = NSArray(contentsOf: path)  as! [[Double]]
        defaultLogger.log("QL Table \(savedArray)")
        self.qTable = savedArray
        
        let states = self.defaults.dictionary(forKey: "stateDict")  as! Dictionary<String, Int>
        defaultLogger.log("QL states\(states)")
        self.states = states
    }
}

