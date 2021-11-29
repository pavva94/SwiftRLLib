//
//  Sensors.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit
import SensorKit
import CoreMotion

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

open class Battery: Sensor {
    public let name: String = "battery"

    open override func read() -> Double {
        return preprocessing(value: UIDevice.current.batteryLevel * 100)
    }
    
    public override func preprocessing(value: Any) -> Double {
        return Double(Int.random(in: 1..<100))//(value as! Float).f.swd as! S
    }
}

open class Orientation: Sensor {
    public let name: String = "orientation"
    
    open override func read() -> Double
    {
        return preprocessing(value: UIDevice.current.orientation.isLandscape)
    }
    
    open override func preprocessing(value: Any) -> Double {
        if value as! Bool {
            return Double(0)
        } else {
            return Double(1)
        }
    }
}


open class Brightness: Sensor {
    public let name: String = "brightness"
    
    open override func read() -> Double {
        return preprocessing(value: UIScreen.main.brightness)
    }
    
    open override func preprocessing(value: Any) -> Double {
        return (value as! CGFloat).swd
    }
}

open class AmbientLight: Sensor {
    public let name: String = "ambientLight"
    
    open override func read() -> Double {
//        var a = SRAmbientLightSample()
//        var l = a.lux.value
        return Double.random(in: 0..<10)
    }
    
    open override func preprocessing(value: Any) -> Double {
        return (value as! CGFloat).swd
    }
}

open class Accelerometer: Sensor {
    let name: String = "accelerometer"
    
    let motion = CMMotionManager()
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    open override func read() -> Double {
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            if let data = self.motion.accelerometerData {
                        x = data.acceleration.x
                        y = data.acceleration.y
                        z = data.acceleration.z
            }
        }
        return preprocessing(value: [x, y, z])
    }
    
    open override func preprocessing(value: Any) -> Double {
        return value as! Double
    }
}


open class Gyroscope: Sensor {
    public let name: String = "gyroscope"
        
    let motion = CMMotionManager()
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    open override func read() -> Double {
        // Make sure the accelerometer hardware is available.
        if self.motion.isGyroAvailable {
            if let data = self.motion.gyroData {
                        x = data.rotationRate.x
                        y = data.rotationRate.y
                        z = data.rotationRate.z
            }
        }
        return preprocessing(value: [x, y, z])
    }
    
    open override func preprocessing(value: Any) -> Double {
        return value as! Double
    }
}
//public class Accelerometer: Sensor<[Double]> {
//    let motion = CMMotionManager()
//    var x: Double = 0
//    var y: Double = 0
//    var z: Double = 0
//
//    public override func read() -> [Double] {
//        // Make sure the accelerometer hardware is available.
//        if self.motion.isAccelerometerAvailable {
//            if let data = self.motion.accelerometerData {
//                        x = data.acceleration.x
//                        y = data.acceleration.y
//                        z = data.acceleration.z
//            }
//        }
//        return preprocessing(value: [x, y, z])
//    }
//
//    public override func preprocessing(value: Any) -> [Double] {
//        return value as! [Double]
//    }
//}
