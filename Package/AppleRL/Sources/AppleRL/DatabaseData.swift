//
//  File.swift
//  
//
//  Created by Alessandro Pavesi on 29/11/21.
//

import Foundation

public struct DatabaseData: Hashable, Codable, Identifiable {
    public var id: Int
    public var state: [Double]
    public var action: Int
    public var reward: Double
    
}
