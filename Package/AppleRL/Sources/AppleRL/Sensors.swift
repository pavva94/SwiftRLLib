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


open class AltitudeSensor: Sensor {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "altitude", stateSize: 1)
    }
    
    open override func read() -> [Double]
    {
        return preprocessing(value: locationManager.lastSeenLocation?.altitude ?? 0.0)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
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


open class BatterySensor: Sensor {
    init() {
        super.init(name: "battery", stateSize: 1)
    }

    open override func read() -> [Double] {
//        return [Double(Int.random(in: 0...100))]
        return preprocessing(value: UIDevice.current.batteryLevel * 100)
    }
    
    public override func preprocessing(value: Any) -> [Double] {
        return [(value as! Float).f.swd] // [Double(Int.random(in: 1..<100))]
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

open class BarometerSensor: Sensor {
    private var altimeter: CMAltimeter!
    
    init() {
        super.init(name: "barometer", stateSize: 1)
        altimeter = CMAltimeter()
    }
    
    open override func read() -> [Double] {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            // 2
            altimeter.startRelativeAltitudeUpdates(to: .main, withHandler: { data, error in
                // 3
                if (error == nil) {
                    print("Relative Altitude: \(data!.relativeAltitude)")
                    print("Pressure: \(data!.pressure)")
                }
            })
        }
        return [0]
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [(value as! CGFloat).swd]
    }
}


open class CitySensor: Sensor {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "city", stateSize: 1)
    }
    
    open override func read() -> [Double]
    {
        return preprocessing(value: locationManager.currentPlacemark?.administrativeArea ?? 0)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
    }
}

open class ClockSensor: Sensor {
    
    init() {
        super.init(name: "clock", stateSize: 2)
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
//        return preprocessing(value: [Double(Int.random(in: 0...24)), Double(Int.random(in: 0...60)), Double(Int.random(in: 0...60))])
        return preprocessing(value: [Double(hour), Double(minute), Double(second)])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        
        // define range of 30 minute
        let hms = value as! [Double]
        var newHms = [hms[0], 0.0]
        if hms[1] > 30 {
            newHms[1] = 30.0
        }
        return newHms
    }
}



open class CountrySensor: Sensor {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "country", stateSize: 1)
    }
    
    open override func read() -> [Double]
    {
        return preprocessing(value: locationManager.currentPlacemark?.country ?? 0)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
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


open class HourSensor: Sensor {
    
    init() {
        super.init(name: "hour", stateSize: 3)
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        return preprocessing(value: [Double(hour)])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}


open class LocationSensor: Sensor {

    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "location", stateSize: 2)
        locationManager.requestPermission()

    }
    var coordinate: CLLocationCoordinate2D? {
        locationManager.lastSeenLocation?.coordinate
    }

    open override func read() -> [Double] {
        var userLatitude: Double {
            return coordinate?.latitude ?? 0
        }
        
        var userLongitude: Double {
            return coordinate?.longitude ?? 0
        }
        return preprocessing(value: [userLatitude, userLongitude])
    }
    
    public override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}


open class LowPowerModeSensor: Sensor {
    
    init() {
        super.init(name: "lowPowerMode", stateSize: 1)
    }
    
    open override func read() -> [Double] {
        let lowerPowerEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        return  preprocessing(value: Bool.random())
//        return preprocessing(value: lowerPowerEnabled)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        if value as! Bool {
            return [Double(1.0)]
        } else {
            return [Double(0.0)]
        }
    }
}


open class MinuteSensor: Sensor {
    
    init() {
        super.init(name: "minute", stateSize: 3)
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let minute = calendar.component(.minute, from: date)
        return preprocessing(value: [Double(minute)])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
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

open class SecondSensor: Sensor {
    
    init() {
        super.init(name: "second", stateSize: 3)
    }
    
    open override func read() -> [Double] {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let second = calendar.component(.second, from: date)
        return preprocessing(value: [Double(second)])
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return value as! [Double]
    }
}


open class SpeedSensor: Sensor {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "speed", stateSize: 1)
    }
    
    open override func read() -> [Double]
    {
        return preprocessing(value: locationManager.lastSeenLocation?.speed ?? 0.0)
    }
    
    open override func preprocessing(value: Any) -> [Double] {
        return [value as! Double]
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
        return [Double(value as! Float)]
        
    }
}
