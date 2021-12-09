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
    init() {
        super.init(name: "battery")
    }

    open override func read() -> [Double] {
        return preprocessing(value: UIDevice.current.batteryLevel * 100)
    }
    
    public override func preprocessing(value: Any) -> [Double] {
        return [(value as! Float).f.swd] // [Double(Int.random(in: 1..<100))]
    }
}

open class Orientation: Sensor {
    init() {
        super.init(name: "orientation")
    }
    
    open override func read() -> [Double]
    {
        return preprocessing(value: UIDevice.current.orientation.isLandscape)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        if value as! Bool {
            return [Double(0)]
        } else {
            return [Double(1)]
        }
    }
}

open class Clock: Sensor {
    
    init() {
        super.init(name: "clock")
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return preprocessing(value: [hour, minute, second])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}

open class Date: Sensor {
    
    init() {
        super.init(name: "date")
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return preprocessing(value: [year, month, day])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}


open class Brightness: Sensor {
    
    init() {
        super.init(name: "brightness")
    }
    
    open override func read() -> [Double] {
        return preprocessing(value: UIScreen.main.brightness)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [(value as! CGFloat).swd]
    }
}

open class AmbientLight: Sensor {
    init() {
        super.init(name: "ambientLight")
    }
    
    open override func read() -> [Double] {
        let a = SRAmbientLightSample()
        let l = a.lux.value
        return [l]
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [(value as! CGFloat).swd]
    }
}

open class Accelerometer: Sensor {
    init() {
        super.init(name: "accelerometer")
    }
    
    let motion = CMMotionManager()
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    open override func read() -> [Double] {
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
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}


open class Gyroscope: Sensor {
    init() {
        super.init(name: "gyroscope")
    }
        
    let motion = CMMotionManager()
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    open override func read() -> [Double] {
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
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
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
