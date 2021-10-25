//
//  Buffer.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 20/10/21.
//

import Foundation

extension Array where Element: Comparable {
    func argmax() -> Index? {
        return indices.max(by: { self[$0] < self[$1] })
    }
    
    func argmin() -> Index? {
        return indices.min(by: { self[$0] < self[$1] })
    }
}

extension Array {
    func argmax(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows-> Index? {
        return try indices.max { (i, j) throws -> Bool in
            try areInIncreasingOrder(self[i], self[j])
        }
    }
    
    func argmin(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows-> Index? {
        return try indices.min { (i, j) throws -> Bool in
            try areInIncreasingOrder(self[i], self[j])
        }
    }
}

public typealias sarTuple = (state: Int, action: Int, reward: Int)
