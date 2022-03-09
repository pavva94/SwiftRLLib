//
//  Sensor.swift
//  SwiftRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

/// Class used to create a Observable data
open class ObservableData {
    var name: String
    var stateSize: Int
    
    public init(name : String = "ObservableData", stateSize: Int) {
        self.name = name
        self.stateSize = stateSize
    }

    open func read(_ state: RLStateData = []) -> RLStateData {
        fatalError("read() has not been implemented")
    }

}

