//
//  DegreeCore.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/30/23.
//

import Foundation

struct Value: Codable, CustomStringConvertible {
    var degrees: Int
    var minutes: Double
    
    public var description: String { return "\(degrees)°\(minutes)'" }
}

enum Operator: String, Codable {
    case Add
    case Subtract
}

struct Entry: CustomStringConvertible, Codable {
    var left: Value?
    var right: Value?
    var op: Operator?

    var value: Value? {
        get {
            if op == nil || right == nil || left == nil {
                return nil
            }
            
            var degrees: Int = 0
            var minutes: Double = 0.0
            
            switch op! {
            case Operator.Add:
                minutes = left!.minutes + right!.minutes
                degrees = left!.degrees + right!.degrees
            case Operator.Subtract:
                minutes = left!.minutes - right!.minutes
                degrees = left!.degrees - right!.degrees
            }
            
            // This could be done via % 60 and % 360 and checking for negative.
            // However this is not runtime sensitive and this extremely literal
            // version is an easy to understand/read reflection of how a person does this math.
            while minutes > 60.0 {
                degrees += 1
                minutes -= 60.0
            }
            while minutes < 0.0  {
                minutes += 60.0
                degrees -= 1
            }
            while degrees > 360 {
                degrees -= 360
            }
            while degrees < 0 {
                degrees += 360
            }
            return Value(degrees: degrees, minutes: minutes)
        }
    }
    
    public var description: String {
        var result: [String] = []
        
        if let a = left {
            result.append("\(a)")
        } else {
            result.append("nil")
        }
        if let b = op {
            result.append("\(b)")
        } else {
            result.append("nil")
        }
        if let c = right {
            result.append("\(c)")
        } else {
            result.append("nil")
        }
        return result.joined(separator: " ")
    }
}
