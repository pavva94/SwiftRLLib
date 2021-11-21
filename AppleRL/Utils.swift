//
//  Utils.swift
//  RLBrightness
//
//  Created by Alessandro Pavesi on 21/11/21.
//

import Foundation
import CoreML

func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
    
    // Init our output array
    var array: [Double] = []
    
    // Get length
    let length = mlMultiArray.count
    
    // Set content of multi array to our out put array
    for i in 0...length - 1 {
        array.append(Double(truncating: mlMultiArray[i]))
    }
    
    return array
}

func convertToMLMultiArrayFloat<S>(from singleArray: [S]) -> MLMultiArray{
    var featureMultiArray: MLMultiArray
    do {
        featureMultiArray = try MLMultiArray(shape: [NSNumber(value: singleArray.count)], dataType: MLMultiArrayDataType.float)
        for index in 0..<singleArray.count {
            featureMultiArray[index] = NSNumber(value: singleArray[index] as! Float)
        }
    } catch {
        fatalError("Error converting in MLMultiArrayFloat")
    }
    return featureMultiArray
}
