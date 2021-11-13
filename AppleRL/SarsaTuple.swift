//
//  SarsaTuple.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import CoreML
import CoreImage

/// Convenience structure that stores a drawing's `CGImage`
/// along with the `CGRect` in which it was drawn on the `PKCanvasView`
/// - Tag: Drawing
struct SarsaTuple {
    private var state: Int
    private var action: Int
    private var reward: Int
    private var next_state: Int
    var featureValue: MLFeatureValue
    
    init(s:Int, a:Int, r:Int, ns: Int) {
        state = s
        action = a
        reward = r
        next_state = ns
        featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, next_state]))
    }
    
    init(s:Int, a:Int, r:Int) {
        state = s
        action = a
        reward = r
        next_state = 0
        featureValue = try! MLFeatureValue(multiArray: MLMultiArray([state, action, reward, next_state]))
    }
}
