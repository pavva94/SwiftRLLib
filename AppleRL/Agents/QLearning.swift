//
//  QLearning.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation


//public class QLearning<S, A, R> {
//    
//    public var buffer: ExperienceReplayBuffer = ExperienceReplayBuffer<S, A, R>()
//    private typealias SarsaTuple = SarsaTupleGeneric<S, A, R>
//    
//    let environment: Env<S, A, R>
//    
//    var timerListen : Timer? = nil {
//            willSet {
//                timerListen?.invalidate()
//            }
//        }
//    
//    var timerTrain : Timer? = nil {
//            willSet {
//                timerTrain?.invalidate()
//            }
//        }
//    
//    var qTable: [[S]]
//    var epsilon: Float
//    var lr: Float
//    var gamma: Float
//    
//    var path: URL
//    
//    required public init(env: Env<S, A, R>, parameters: Dictionary<String, Any>) {
//        environment = env
//        
//        self.epsilon = (parameters["epsilon"] as? Float)!
//        self.lr = (parameters["learning_rate"] as? Float)!
//        self.gamma = (parameters["gamma"] as? Float)!
//        var temp: [[S]] = []
//        for i in 0...env.get_state_size() {
//            temp.append([])
//            for _ in 0...env.get_action_size() {
//                temp[i].append(0.0 as! S)
//            }
//        }
//        self.qTable = temp
//        print(temp)
//        
//        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("QLearningOrientation.plist")
//    }
//
//    func store(s: S, a: A, r: R) {
//        let tuple = SarsaTuple(state: s, action: a, reward: r)
//        buffer.addData(tuple)
//    }
//
//    func getQValue() -> [[S]] {
//        return qTable
//    }
//
//    func epsilonGreedy(state: S) -> A {
//        if Float.random(in: 0..<1) < epsilon {
//            // epsilon choice
//            return Int.random(in: 0..<self.environment.get_action_size()+1) as! A
//        }
//        else {
//            return qTable[state as! Int].argmax()! as! A
//        }
//    }
//
//    public func act(state: S) -> A {
//
//        return epsilonGreedy(state:state)
//    }
//
//    public func update() {
//
//        let data = buffer.batchProvider
//
//        var i = 0
//        while i < data.count {
//            let tuple: SarsaTuple = data[i]
//            print(tuple)
//            let s: S = tuple.getState(), a: A = tuple.getAction(), r: R = tuple.getReward()
//
//            var maxQtable: [Float] = []
//            for i in 0...self.environment.get_state_size() {
//                maxQtable.append(self.qTable[i].max()!)
//            }
//
//            qTable[s][a] = qTable[s][a] + lr * (Float(r) + gamma * maxQtable.max()! - qTable[s][a])
//            print(qTable)
//            i += 1
//        }
//        buffer.reset()
//
//
////        let s:Int = tuple.state, a:Int = tuple.action, r:Int = tuple.reward
////
////        var maxQtable: [Float] = []
////        for i in 0...self.environment.get_state_size() {
////            maxQtable.append(self.qTable[i].max()!)
////        }
////
////        qTable[s][a] = qTable[s][a] + lr * (Float(r) + gamma * maxQtable.max()! - qTable[s][a])
////        print(qTable)
//    }
//
//    @objc public func batchUpdate(batchSize: Int = 32) {
//
//        // TODO this isn't a batchupdate
//        let data = buffer.batchProvider
//
//        var i = 0
//        while i < data.count {
//            let tuple: SarsaTuple = data.features(at: i) as! SarsaTuple
//            print(tuple)
//            let s: S = tuple.getState(), a: A = tuple.getAction(), r: R = tuple.getReward()
//
//            var maxQtable: [S] = []
//            for i in 0...self.environment.get_state_size() {
//                maxQtable.append(self.qTable[i].max()!)
//            }
//
//            qTable[s][a] = qTable[s][a] + lr * (Float(r) + gamma * maxQtable.max()! - qTable[s][a])
//            print(qTable)
//            i += 1
//        }
//        buffer.reset()
//    }
//
//    @objc public func listen() {
//        let state = environment.read()[0]
//        print(state)
//        let action = self.act(state: state)
//        let (next_state, reward) = environment.act(s: [state], a: action)
//        //let next_state = result.1
//        self.store(s: state, a: action, r: reward)
//    }
//
//    public func startListen(interval: Int) {
//        stopListen()
//        guard self.timerListen == nil else { return }
//        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
//    }
//
//    public func stopListen() {
//        guard timerListen != nil else { return }
//        timerListen?.invalidate()
//        timerListen = nil
//    }
//
//    public func startTrain(interval: Int) {
//        stopTrain()
//        guard self.timerTrain == nil else { return }
//        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.batchUpdate), userInfo: nil, repeats: true)
//    }
//
//    public func stopTrain() {
//        guard timerTrain != nil else { return }
//        timerTrain?.invalidate()
//        timerTrain = nil
//    }
//
//    public func save() {
//        print("Save")
//        // Save to file
//        (self.qTable as NSArray).write(to: path, atomically: true)
//    }
//
//    public func load() {
//        print("Load")
//        // Read from file
//        let savedArray = NSArray(contentsOf: path)  as! [[Float]]
//        print(savedArray)
//        self.qTable = savedArray
//    }
//
//}

