//
//  Agent.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

public protocol Agent {
    func act(state: Int) -> Int
    
    func update(tuple: sarTuple)
    
    func batchUpdate(batchSize: Int)
    
    func startTrain()
    
    func stopTrain()
    
}
