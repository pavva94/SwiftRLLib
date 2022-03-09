//
//  Sensors.swift
//  SwiftRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation
import UIKit
import CoreMotion
import AVKit
import CoreLocation
import Combine


//open class AmbientLightSensor: ObservableData {
//    init() {
//        super.init(name: "ambientLight", stateSize: 1)
//    }
//    
//    open override func read(_ state: RLStateData = []) -> RLStateData {
//        let a = SRAmbientLightSample()
//        let l = a.lux.value
//        return [l]
//    }
//    
//    open override func preprocessing(value: Any) -> RLStateData {
//        return [(value as! CGFloat).swd]
//    }
//}

/// Sensor for the Altitude of the device
open class AltitudeSensor: ObservableData {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "altitude", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData
    {
        return [locationManager.lastSeenLocation?.altitude ?? 0.0]
    }
    
}

/// Sensor for the Accelerometer
open class AccelerometerSensor: ObservableData {
    init() {
        super.init(name: "accelerometer", stateSize: 3)
    }
    
    let motion = CMMotionManager()
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            if let data = self.motion.accelerometerData {
                        x = data.acceleration.x
                        y = data.acceleration.y
                        z = data.acceleration.z
            }
        }
        return [x, y, z]
    }
    
}

/// Sensor for the Battery of the device
open class BatterySensor: ObservableData {
    init() {
        super.init(name: "battery", stateSize: 1)
    }

    open override func read(_ state: RLStateData = []) -> RLStateData {
//        return [Double(Int.random(in: 0...100))]
        return [(UIDevice.current.batteryLevel * 100).f.swd]
    }
    
}

/// Sensor for the Brightness of the device
open class BrightnessSensor: ObservableData {
    
    init() {
        super.init(name: "brightness", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
//        if useSimulator {
//            return [BatterySimulator.simulateBrightness()]
//        }
        return [UIScreen.main.brightness.swd]
    }
    

}

/// Sensor for the Barometer of the device
open class BarometerSensor: ObservableData {
    private var altimeter: CMAltimeter!
    
    init() {
        super.init(name: "barometer", stateSize: 1)
        altimeter = CMAltimeter()
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
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

}

/// Sensor for the City in which the device is
open class CitySensor: ObservableData {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "city", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData
    {
        return [0.0]
//        return [locationManager.currentPlacemark?.administrativeArea ?? 0]
    }
}

/// Sensor for the Clock
open class ClockSensor: ObservableData {
    
    public init() {
        super.init(name: "clock", stateSize: 2)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
//        let second = calendar.component(.second, from: date)
        
        return [Double(hour), Double(minute)] //, Double(second)]
        
    }

}


/// Sensor for the Country in which the device is
open class CountrySensor: ObservableData {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "country", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData
    {
        return [0.0]
//        return [locationManager.currentPlacemark?.country ?? 0]
    }
    
}

/// Sensor for the Date
open class DateSensor: ObservableData {
    
    init() {
        super.init(name: "date", stateSize: 3)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return [Double(year), Double(month), Double(day)]
    }

}

/// Sensor for the Gyroscope of the device
open class GyroscopeSensor: ObservableData {
    init() {
        super.init(name: "gyroscope", stateSize: 3)
    }
        
    let motion = CMMotionManager()
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        // Make sure the accelerometer hardware is available.
        if self.motion.isGyroAvailable {
            if let data = self.motion.gyroData {
                        x = data.rotationRate.x
                        y = data.rotationRate.y
                        z = data.rotationRate.z
            }
        }
        return [x, y, z]
    }
    
}

/// Sensor for the Hour
open class HourSensor: ObservableData {
    
    init() {
        super.init(name: "hour", stateSize: 3)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let hour = calendar.component(.hour, from: date)
        return [Double(hour)]
    }
}

/// Sensor for the Location in coordinates of the device
open class LocationSensor: ObservableData {

    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "location", stateSize: 2)
        locationManager.requestPermission()

    }
    var coordinate: CLLocationCoordinate2D? {
        locationManager.lastSeenLocation?.coordinate
    }

    open override func read(_ state: RLStateData = []) -> RLStateData {
        var userLatitude: Double {
            return coordinate?.latitude ?? 0
        }
        
        var userLongitude: Double {
            return coordinate?.longitude ?? 0
        }
        return [userLatitude, userLongitude]
    }
    
}

/// Sensor for the Lock of the device
open class LockedSensor: ObservableData {
    
    init() {
        super.init(name: "locked", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let value = UIApplication.shared.isProtectedDataAvailable
        if value {
            return [Double(0)]
        } else {
            return [Double(1)]
        }
    }
}

/// Sensor for the Low Power Mode of the device
open class LowPowerModeSensor: ObservableData {
    
    init() {
        super.init(name: "lowPowerMode", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let value = ProcessInfo.processInfo.isLowPowerModeEnabled

        if value {
            return [Double(1.0)]
        } else {
            return [Double(0.0)]
        }
    }
    
}

/// Sensor for the Minute
open class MinuteSensor: ObservableData {
    
    init() {
        super.init(name: "minute", stateSize: 3)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let minute = calendar.component(.minute, from: date)
        return [Double(minute)]
    }

}

/// Sensor for the Orientation of the device
open class OrientationSensor: ObservableData {
    init() {
        super.init(name: "orientation", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData
    {
        let value = UIDevice.current.orientation.isLandscape
        if value {
            return [Double(0)]
        } else {
            return [Double(1)]
        }
    }

}

/// Sensor for the Seconds
open class SecondSensor: ObservableData {
    
    init() {
        super.init(name: "second", stateSize: 3)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        let date = Foundation.Date() // save date, so all components use the same date
        let calendar = Calendar.current // or e.g. Calendar(identifier: .persian)

        let second = calendar.component(.second, from: date)
        return [Double(second)]
    }
}

/// Sensor for the Speed at which the device
open class SpeedSensor: ObservableData {
    let locationManager = LocationManagerRL()
    
    init() {
        super.init(name: "speed", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData
    {
        return [locationManager.lastSeenLocation?.speed ?? 0.0]
    }
    
}

/// Sensor for the Volume of the device
open class VolumeSensor: ObservableData {
    
    init() {
        super.init(name: "volume", stateSize: 1)
    }
    
    open override func read(_ state: RLStateData = []) -> RLStateData {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            defaultLogger.log("Error on Volume")
        }
        return [Double(AVAudioSession.sharedInstance().outputVolume)]
    }
}
