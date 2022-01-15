//
//  QLearning.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import CoreML


open class QLearning {
    
    open var buffer: ExperienceReplayBuffer = ExperienceReplayBuffer()
    private typealias SarsaTuple = SarsaTupleGeneric
    
    let environment: Env
    
    var timerListen : Timer? = nil {
            willSet {
                timerListen?.invalidate()
            }
        }
    
    var timerTrain : Timer? = nil {
            willSet {
                timerTrain?.invalidate()
            }
        }
    
    var qTable: [[Double]]
    var epsilon: Double
    var lr: Double
    var gamma: Double
    
    var path: URL
    
    required public init(env: Env, parameters: Dictionary<String, Any>) {
        environment = env
        
        self.epsilon = (parameters["epsilon"] as? Double)!
        self.lr = (parameters["learning_rate"] as? Double)!
        self.gamma = (parameters["gamma"] as? Double)!
        var temp: [[Double]] = []
        for i in 0...env.getStateSize() {
            temp.append([])
            for _ in 0...env.getActionSize() {
                temp[i].append(0.0)
            }
        }
        self.qTable = temp
        defaultLogger.log("\(temp)")
        
        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("QLearningOrientation.plist")
    }

    func store(state: Int, action: Int, reward: Double, nextState: Double) {
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

        return epsilonGreedy(state:state)
    }

    open func update() {

        let data = buffer.batchProvider

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

    @objc open func batchUpdate(batchSize: Int = 32) {

        // TODO this isn't a batchupdate
        let data = buffer.batchProvider

        var i = 0
        while i < data.count {
            let tuple: SarsaTuple = data[i]
//            defaultLogger.log(tuple)
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
    }

    @objc open func listen() {
        let state = environment.read()[0]
        defaultLogger.log("\(state)")
        let action = self.act(state: Int(state))
        environment.act(state: [state], action: action)
//        let reward = environment.reward(state: [state], action: action)
//        //let next_state = result.1
//        self.store(state: Int(state), action: action, reward: reward)
        
        if self.buffer.count > 0 {
            // then we are done with the current tuple we can take care of finish the last one
            let last_state = self.buffer.lastData
    //        let newNextState = convertToMLMultiArrayFloat(from:state)
            // retrieve the reward based on the old state, the current state and the action done in between
            let reward = environment.reward(state: convertToArray(from: last_state.getState()), action: last_state.getAction(), nextState: [state])
            self.store(state: Int(convertToArray(from: last_state.getState())[0]), action: last_state.getAction(), reward: reward, nextState: state)
        }
        
        // wait the overriding of last tuple to save current tuple
//        self.buffer.addData(SarsaTuple(state: convertToMLMultiArrayFloat(from: [state]), action: action, reward: 0.0))
    }

    open func startListen(interval: Int) {
        stopListen()
        guard self.timerListen == nil else { return }
        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }

    open func stopListen() {
        guard timerListen != nil else { return }
        timerListen?.invalidate()
        timerListen = nil
    }

    open func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.batchUpdate), userInfo: nil, repeats: true)
    }

    open func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }

    open func save() {
        defaultLogger.log("Save")
        // Save to file
        (self.qTable as NSArray).write(to: path, atomically: true)
    }

    open func load() {
        defaultLogger.log("Load")
        // Read from file
        let savedArray = NSArray(contentsOf: path)  as! [[Double]]
        defaultLogger.log("\(savedArray)")
        self.qTable = savedArray
    }

}

