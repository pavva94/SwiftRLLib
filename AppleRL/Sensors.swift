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


public class Orientation<S>: Sensor<S> {
    public override func read() -> S {
        return preprocessing(value: UIDevice.current.orientation.isLandscape)
    }
    
    public override func preprocessing(value: Any) -> S {
        if value as! Bool {
            return 0 as! S
        } else {
            return 1 as! S
        }
    }
}


public class Brightness<S>: Sensor<S> {
    public override func read() -> S {
        return preprocessing(value: UIScreen.main.brightness)
    }
    
    public override func preprocessing(value: Any) -> S {
        return (value as! CGFloat).swf as! S
    }
}
