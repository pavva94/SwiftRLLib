//
//  Sensor.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation


open class ObservableData {
    var name: String
    var stateSize: Int
    
    public init(name : String = "ObservableData", stateSize: Int) {
        self.name = name
        self.stateSize = stateSize
    }

    open func read() -> [Double] {
        fatalError("read() has not been implemented")
    }
    
    open func preprocessing(value: Any) -> [Double] {
        fatalError("preprocessing() has not been implemented")
    }

}

