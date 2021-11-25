//
//  QLearning.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import CoreML


open class QLearning {
    
    open var buffer: ExperienceReplayBuffer = ExperienceReplayBuffer<Int, Int, Int>()
    private typealias SarsaTuple = SarsaTupleGeneric<Int, Int, Int>
    
    let environment: Env<Int, Int, Int>
    
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
    
    required public init(env: Env<Int, Int, Int>, parameters: Dictionary<String, Any>) {
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
        print(temp)
        
        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("QLearningOrientation.plist")
    }

    func store(state: Int, action: Int, reward: Int) {
        let tuple = SarsaTuple(state: convertToMLMultiArrayFloat(from:[state]), action: action, reward: reward)
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
            print(tuple)
            let s: Int = Int(convertToArray(from: tuple.getState())[0]), a: Int = tuple.getAction(), r: Int = tuple.getReward()

            var maxQtable: [Double] = []
            for i in 0...self.environment.getStateSize() {
                maxQtable.append(self.qTable[i].max()!)
            }

            let temp : Double = Double(r) + gamma * maxQtable.max()! - qTable[s][a]
            qTable[s][a] = qTable[s][a] + lr * temp
            print(qTable)
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
//        print(qTable)
    }

    @objc open func batchUpdate(batchSize: Int = 32) {

        // TODO this isn't a batchupdate
        let data = buffer.batchProvider

        var i = 0
        while i < data.count {
            let tuple: SarsaTuple = data[i]
            print(tuple)
            let s: Int = Int(convertToArray(from: tuple.getState())[0]), a: Int = tuple.getAction(), r: Int = tuple.getReward()

            var maxQtable: [Double] = []
            for i in 0...self.environment.getStateSize() {
                maxQtable.append(self.qTable[i].max()!)
            }
            let temp : Double = Double(r) + gamma * maxQtable.max()! - qTable[s][a]
            qTable[s][a] = qTable[s][a] + lr * temp
            print(qTable)
            i += 1
        }
        buffer.reset()
    }

    @objc open func listen() {
        let state = environment.read()[0]
        print(state)
        let action = self.act(state: state)
        let (_, reward) = environment.act(state: [state], action: action)
        //let next_state = result.1
        self.store(state: state, action: action, reward: reward)
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
        print("Save")
        // Save to file
        (self.qTable as NSArray).write(to: path, atomically: true)
    }

    open func load() {
        print("Load")
        // Read from file
        let savedArray = NSArray(contentsOf: path)  as! [[Double]]
        print(savedArray)
        self.qTable = savedArray
    }

}

