//
//  Extensions.swift
//  AppleRL
//
//  Created by Alessandro Pavesi on 12/11/21.
//

import CoreML


extension Int {
  var f: CGFloat { return CGFloat(self) }
}

extension Float {
  var f: CGFloat { return CGFloat(self) }
}

extension Double {
  var f: CGFloat { return CGFloat(self) }
}

extension CGFloat {
    var swf: Float { return Float(self) }
    var swd: Double { return Double(self) }
}

extension Collection {
    func choose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}


// Specify the decimal place to round to using an enum
public enum RoundingPrecision {
    case ones
    case tenths
    case hundredths
    case thousands
}

public extension Double {
    // Round to the specific decimal place
    func customRound(_ rule: FloatingPointRoundingRule, precision: RoundingPrecision = .tenths) -> Double {
        switch precision {
        case .ones: return (self * Double(1)).rounded(rule) / 1
        case .tenths: return (self * Double(10)).rounded(rule) / 10
        case .hundredths: return (self * Double(100)).rounded(rule) / 100
        case .thousands: return (self * Double(1000)).rounded(rule) / 1000
        }
    }
}
