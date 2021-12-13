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
import AVKit
import CoreLocation
import Combine

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

open class BatterySensor: Sensor {
    init() {
        super.init(name: "battery", stateSize: 1)
    }

    open override func read() -> [Double] {
        return preprocessing(value: UIDevice.current.batteryLevel * 100)
    }
    
    public override func preprocessing(value: Any) -> [Double] {
        return [(value as! Float).f.swd] // [Double(Int.random(in: 1..<100))]
    }
}

open class LocationSensor: Sensor {

    class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

        private let locationManager = CLLocationManager()
        @Published var locationStatus: CLAuthorizationStatus?
        @Published var lastLocation: CLLocation?

        override init() {
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
        }

       
        
        var statusString: String {
            guard let status = locationStatus else {
                return "unknown"
            }
            
            switch status {
            case .notDetermined: return "notDetermined"
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            case .restricted: return "restricted"
            case .denied: return "denied"
            default: return "unknown"
            }
        }
    }
    
    let locationManager = LocationManager()
    
    init() {
        super.init(name: "location", stateSize: 2)
        

    }

    open override func read() -> [Double] {
        print(locationManager.statusString)
        var userLatitude: Double {
            return locationManager.lastLocation?.coordinate.latitude ?? 0
        }
        
        var userLongitude: Double {
            return locationManager.lastLocation?.coordinate.longitude ?? 0
        }
        return preprocessing(value: [userLatitude, userLongitude])
    }
    
    public override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}

open class OrientationSensor: Sensor {
    init() {
        super.init(name: "orientation", stateSize: 1)
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

open class ClockSensor: Sensor {
    
    init() {
        super.init(name: "clock", stateSize: 3)
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return preprocessing(value: [Double(hour), Double(minute), Double(second)])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}

open class DateSensor: Sensor {
    
    init() {
        super.init(name: "date", stateSize: 3)
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return preprocessing(value: [Double(year), Double(month), Double(day)])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}

open class VolumeSensor: Sensor {
    
    init() {
        super.init(name: "volume", stateSize: 1)
    }
    
    open override func read() -> [Double] {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            defaultLogger.log("Error on Volume")
        }
        return preprocessing(value: AVAudioSession.sharedInstance().outputVolume)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [(value as! CGFloat).swd]
    }
}


open class BrightnessSensor: Sensor {
    
    init() {
        super.init(name: "brightness", stateSize: 1)
    }
    
    open override func read() -> [Double] {
        return preprocessing(value: UIScreen.main.brightness)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [(value as! CGFloat).swd]
    }
}

open class AmbientLightSensor: Sensor {
    init() {
        super.init(name: "ambientLight", stateSize: 1)
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


open class LowPowerModeSensor: Sensor {
    
    init() {
        super.init(name: "lowPowerMode", stateSize: 2)
    }
    
    open override func read() -> [Double] {
        let lowerPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
            
        return preprocessing(value: lowerPowerEnabled)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        if value as! Bool {
            return [Double(1.0)]
        } else {
            return [Double(0.0)]
        }
    }
}


open class AccelerometerSensor: Sensor {
    init() {
        super.init(name: "accelerometer", stateSize: 3)
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


open class GyroscopeSensor: Sensor {
    init() {
        super.init(name: "gyroscope", stateSize: 3)
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
