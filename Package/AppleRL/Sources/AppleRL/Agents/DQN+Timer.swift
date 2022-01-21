//
//  DQN+Timer.swift
//  
//
//  Created by Alessandro Pavesi on 27/12/21.
//

import Foundation


extension DeepQNetwork {
    
    /// Start the timer to read the env observaleData
    open func startListen(interval: Int) {
        stopListen()
        guard self.timerListen == nil else { return }
        self.timerListen = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.listen), userInfo: nil, repeats: true)
    }
    
    /// Stop the timer to read the env observaleData
    open func stopListen() {
        guard timerListen != nil else { return }
        timerListen?.invalidate()
        timerListen = nil
    }
    
    /// Start the timer to update the model
    open func startTrain(interval: Int) {
        stopTrain()
        guard self.timerTrain == nil else { return }
        self.timerTrain = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }

    /// Stop the timer to update the model
    open func stopTrain() {
        guard timerTrain != nil else { return }
        timerTrain?.invalidate()
        timerTrain = nil
    }
        
}
