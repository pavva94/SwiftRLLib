//
//  DQN+Timer.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation


extension DeepQNetwork {
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
        
}
