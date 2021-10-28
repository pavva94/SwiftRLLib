//
//  Agent.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

public protocol Agent {
    
    init(env: Env)
    
    func act(state: Int) -> Int
    
    func update(tuple: sarTuple)
    
    func startListen(interval: Int)
    
    func stopListen()
    
    func startTrain(interval: Int)
    
    func stopTrain()
    
}
