//
//  AppSensors.swift
//  Environment2D
//
//  Created by Alessandro Pavesi on 02/03/22.
//

import Foundation
import SwiftRL

open class MatrixSens: ObservableData {
    
    init() {
        super.init(name: "matrix", stateSize: 10)
    }
    var sensStep: Int = 0
    let maxStep: Int = 250
    let originalWorld: [Double]  = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var world: [Double] = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    open override func read(_ state: RLStateData = []) -> RLStateData
    {
        if sensStep < maxStep {
            self.sensStep += 1
            return self.world
        } else {
            reset()
            return []
        }
    }
    
    public func moveLeft() {
        let posIndex = self.world.firstIndex(of: 1.0)!
        if posIndex <= self.world.count-1 && posIndex > 0 {
            self.world[posIndex] = 0
            self.world[posIndex-1] = 1
        }
        else {
            print("Agent limited by barrier")
        }
        
    }
    
    public func moveRight() {
        let posIndex = self.world.firstIndex(of: 1.0)!
        if posIndex < self.world.count-1 && posIndex >= 0 {
            self.world[posIndex] = 0
            self.world[posIndex+1] = 1
        }
        else {
            print("Agent limited by barrier")
        }
        
    }
    
    func reset() {
        print("Reset \(self.sensStep)")
        self.world = self.originalWorld
        self.sensStep = 0
    }
}

