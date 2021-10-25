//
//  Sensors.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit


public class Orientation: Sensor {
    
    var sensor: Bool
    
    required public init() {
        
        sensor = UIDevice.current.orientation.isLandscape
    }
    
    public func read() -> Int {
        sensor = UIDevice.current.orientation.isLandscape
        if sensor {
            return 0
        } else {
            return 1
        }
    }
}
