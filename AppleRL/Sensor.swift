//
//  Sensor.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

public protocol Sensor {
    
    init()
    
    func read() -> Int
    
}
