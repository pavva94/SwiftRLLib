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

public class Sensor<S> {
    
    func read() -> S {
        fatalError("read() has not been implemented")
    }
    func preprocessing(value: Any) -> S {
        fatalError("preprocessing() has not been implemented")
    }
    
}
