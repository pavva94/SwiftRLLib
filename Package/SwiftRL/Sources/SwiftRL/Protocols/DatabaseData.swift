//
//  DatabaseData.swift
//  
//
//  Created by Alessandro Pavesi on 29/11/21.
//

import Foundation

/// Strinct used to save the data into files
public struct DatabaseData: Hashable, Codable, Identifiable {
    public var id: Int
    public var state: RLStateData
    public var action: RLActionData
    public var reward: RLRewardData
    public var nextState: RLStateData
    
}
