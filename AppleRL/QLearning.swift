//
//  QLearning.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation


public class QLearn: Agent {
    
    var timerTrain : Timer? = nil {
            willSet {
                timerTrain?.invalidate()
            }
        }
    
    var qTable: [[Float]] = [
        [0.0, 0.0, 0.0],   // state Landscape: visualizzoLand, visualPort
        [0.0, 0.0, 0.0]    // state Portrait: visualizzoLand, visualPort
    ]
    var epsilon: Float = 0.8
    var lr: Float = 0.1
    var gamma: Float = 0.5
    
    var buffer: [sarTuple] = []
    
    func store(s:Int, a:Int, r:Int) {
        let tuple = sarTuple(s, a, r)
        buffer.append(tuple)
    }
    
    func getQValue() -> [[Float]] {
        return qTable
    }
    
    func epsilonGreedy(state: Int) -> Int {
        if Float.random(in: 0..<1) < epsilon {
            // epsilon choice
            return Int.random(in: 0..<3)
        }
        else {
            return qTable[state].argmax()!
        }
    }
    
    public func act(state: Int) -> Int {
        
        return epsilonGreedy(state:state)
    }
    
    public func update(tuple: sarTuple) {
        
        let s:Int = tuple.state, a:Int = tuple.action, r:Int = tuple.reward
        
        // s: 0=Land, 1=Port
        // a: 0=Land, 1=Port
        // r: +1 if match, -1 otherwise
        qTable[s][a] = qTable[s][a] + lr * (Float(r) + gamma * [qTable[0].max()!, qTable[1].max()!].max()! - qTable[s][a])
        print(qTable)
    }
    
    @objc public func batchUpdate(batchSize: Int = 32) {
        
        // TODO this isn't a batchupdate
        print("TIME TO TRAIIINNNNN!!!!")
        var i = 0
        while i < buffer.count {
            let data: sarTuple = buffer[i]
            print(data)
            update(tuple: data)
            i += 1
        }
        buffer = []
    }
    
    public func startTrain() {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.batchUpdate), userInfo: nil, repeats: true)
    }

    public func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
    
    
}

let QLearning = QLearn()
