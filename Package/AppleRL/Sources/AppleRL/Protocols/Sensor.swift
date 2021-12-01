//
//  Sensor.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation


//protocol BaseSensor {
//
//}
//
//public class Sensor<T>: BaseSensor {
//
//    func read() -> Float {
//        fatalError("read() has not been implemented")
//    }
//
//    func preprocessing<T>(value: T) -> Float {
//        fatalError("preprocessing() has not been implemented")
//    }
//
//}

open class Sensor {
    var name: String
    
    init(name : String = "Sensor") {
        self.name = name;
    }

    func read() -> Double {
        fatalError("read() has not been implemented")
    }
    func preprocessing(value: Any) -> Double {
        fatalError("preprocessing() has not been implemented")
    }

}

//public protocol Sensor {
//    associatedtype S
//    var name: String { get }
//
//    func read() -> S
//    func preprocessing(value: Any) -> S
//}


