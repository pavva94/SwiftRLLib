//
//  DQN.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 02/11/21.
//

import CoreML


public class DeepQNetwork: Agent {
    public var buffer: ExperienceReplayBuffer
    
    
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
    
    var qTable: [[Float]]
    var epsilon: Float
    var lr: Float
    var gamma: Float
    
    var path: URL
    
    required public init(env: Env, parameters: Dictionary<String, Any>) {
        environment = env
        
        self.buffer = ExperienceReplayBuffer()
        
        self.epsilon = (parameters["epsilon"] as? Float)!
        self.lr = (parameters["learning_rate"] as? Float)!
        self.gamma = (parameters["gamma"] as? Float)!
        var temp: [[Float]] = []
        for i in 0...env.get_state_size() {
            temp.append([])
            for _ in 0...env.get_action_size() {
                temp[i].append(0.0)
            }
        }
        self.qTable = temp
        print(temp)
        
        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("QLearningOrientation.plist")
    }
    
    func store(s:Int, a:Int, r:Int) {
        let tuple = SarsaTuple(s: s, a: a, r: r)
        buffer.addData(tuple)
    }
    
    func getQValue() -> [[Float]] {
        return qTable
    }
    
    func epsilonGreedy(state: Int) -> Int {
        if Float.random(in: 0..<1) < epsilon {
            // epsilon choice
            return Int.random(in: 0..<self.environment.get_action_size()+1)
        }
        else {
            return qTable[state].argmax()!
        }
    }
    
    public func act(state: Int) -> Int {
        
        return epsilonGreedy(state:state)
    }
    
    public func update() {
        
        // Convert the drawings into a batch provider as the update input.
        let drawingTrainingData = buffer.featureBatchProvider
        
        // Update the Drawing Classifier with the drawings.
        DispatchQueue.global(qos: .userInitiated).async {
            ModelUpdater.updateWith(trainingData: drawingTrainingData) {
                DispatchQueue.main.async { print("Trained") }
            }
        }
    }
    
    @objc public func batchUpdate(batchSize: Int = 32) {
        
        // Convert the drawings into a batch provider as the update input.
        let drawingTrainingData = buffer.featureBatchProvider
        
        // Update the Drawing Classifier with the drawings.
        DispatchQueue.global(qos: .userInitiated).async {
            ModelUpdater.updateWith(trainingData: drawingTrainingData) {
                DispatchQueue.main.async { print("Trained") }
            }
        }
    }
    
    @objc public func listen() {
        let state = environment.read()[0]
        print(state)
        let action = self.act(state: state as! Int)
        let reward = environment.act(s: state, a: action)
        //let next_state = result.1
        self.store(s: state as! Int, a: action, r: reward)
    }
    
    public func startListen(interval: Int) {
        stopListen()
        guard self.timerListen == nil else { return }
        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }

    public func stopListen() {
        guard timerListen != nil else { return }
        timerListen?.invalidate()
        timerListen = nil
    }
    
    public func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.batchUpdate), userInfo: nil, repeats: true)
    }

    public func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
    
    public func save() {
        print("Save")
        // Save to file
        (self.qTable as NSArray).write(to: path, atomically: true)
    }
    
    public func load() {
        print("Load")
        // Read from file
        let savedArray = NSArray(contentsOf: path)  as! [[Float]]
        print(savedArray)
        self.qTable = savedArray
    }
    
}

