//
//  Sensors.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit
import SensorKit


//public class Orientation: Sensor<Bool> {
//
//    public override func preprocessing<Bool>(value: Bool) -> Float {
//        if value as! Bool {
//            return 0
//        } else {
//            return 1
//        }
//    }
//
//
//    public override func read() -> Float {
//        let sensor = UIDevice.current.orientation.isLandscape
//        return preprocessing(value: sensor)
//
//    }
//}


public class Orientation: Sensor {
    public func read() -> Any {
        return preprocessing(value: UIDevice.current.orientation.isLandscape)
    }
    
    public func preprocessing(value: Any) -> Any {
        if value as! Bool {
            return 0
        } else {
            return 1
        }
    }
    
    
    
}
