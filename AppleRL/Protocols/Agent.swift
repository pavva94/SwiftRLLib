//
//  Agent.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

public protocol Agent {
    
//    var buffer: ExperienceReplayBuffer<> { get }
    
    init(env: Env, parameters: Dictionary<String, Any>)
    
    func act(state: Any) -> Int
    
    func update()
    
    func startListen(interval: Int)
    
    func stopListen()
    
    func startTrain(interval: Int)
    
    func stopTrain()
    
    func save()
    
    func load()
    
}
