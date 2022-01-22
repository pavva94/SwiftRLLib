//
//  DQN+Listen.swift
//  
//
//  Created by Alessandro Pavesi on 14/01/22.
//

import Foundation
import CoreML
import MetricKit

extension DeepQNetwork {
    
    
    @objc open func listen() {
        // read new state and do things like act
        let state = environment.read()
        
        // check if state is terminal
        if state == [] {
            do {
                defaultLogger.log("Terminal State reached")
                let newState = try MLMultiArray([Double]())
                let reward = environment.reward(state: convertToArray(from: self.buffer.lastData.getState()), action: self.buffer.lastData.getAction(), nextState: state)
                self.store(state: self.buffer.lastData.getState(), action: self.buffer.lastData.getAction(), reward: reward, nextState: newState)
                // wait the overriding of last tuple to save current tuple
                self.buffer.isEmpty = true
                return
            } catch {
                defaultLogger.error("Error saving terminal state: \(error.localizedDescription)")
                return
            }
        }
        
        let newState = convertToMLMultiArrayFloat(from:state)
        defaultLogger.log("Listen State: \(state)")
        let action = self.act(state: newState)
        environment.act(state: state, action: action)

        
        defaultLogger.log("Buffer count \(self.buffer.count)")
        // then we are done with the current tuple we can take care of finish the last one
        if !self.buffer.isEmpty {
            defaultLogger.log("Listen Old State: \(self.buffer.lastData.getState())")
            // retrieve the reward based on the old state, the current state and the action done in between
            let reward = environment.reward(state: convertToArray(from: self.buffer.lastData.getState()), action: self.buffer.lastData.getAction(), nextState: state)
            
            self.store(state: self.buffer.lastData.getState(), action: self.buffer.lastData.getAction(), reward: reward, nextState: newState)
        }
        
        // wait the overriding of last tuple to save current tuple
        self.buffer.setLastData(SarsaTuple(state: newState, action: action, reward: 0.0))
        
        // add metrics
        let listenLogHandle = MXMetricManager.makeLogHandle(category: "Listen")
        mxSignpost(
          .event,
          log: listenLogHandle,
          name: "Listen")
    }
}
