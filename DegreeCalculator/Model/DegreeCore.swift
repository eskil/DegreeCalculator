//
//  DegreeCore.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/30/23.
//

import Foundation

struct Value: Codable, Hashable, CustomStringConvertible {
    var degrees: Int
    var minutes: Decimal
    public var description: String { return "\(degrees)°\(minutes)'" }
}

enum Operator: String, CustomStringConvertible, Hashable, Codable {
    case Add
    case Subtract
    
    public var description: String {
        switch self {
        case .Add:
            return "+"
        case .Subtract:
            return "-"
        }
    }
}

struct Entry: CustomStringConvertible, Hashable, Codable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.value == rhs.value
    }
    
    var nodes: [Entry]
    var op: Operator?
    var v: Value?
    
    var value: Value? {
        get {
            if v != nil {
                return v
            }
            if nodes.count == 0 {
                return nil
            }
            
            if op == nil || nodes.count == 1 {
                return nodes[0].value
            }

            if let lv = nodes[0].value, let rv = nodes[1].value {
                var degrees: Int = 0
                var minutes: Decimal = 0.0
                
                switch op! {
                case Operator.Add:
                    degrees = lv.degrees + rv.degrees
                    minutes = lv.minutes + rv.minutes
                case Operator.Subtract:
                    degrees = lv.degrees - rv.degrees
                    minutes = lv.minutes - rv.minutes
                }
                
                // This could be done via % 60 and % 360 and checking
                // for negative. But this is not runtime sensitive and
                // this extremely literal version is an easy to
                // understand/read reflection of how a person does
                // this math.
                
                while minutes > 60.0 {
                    degrees += 1
                    minutes -= 60.0
                }
                while minutes < 0.0  {
                    minutes += 60.0
                    degrees -= 1
                }
                while degrees >= 360 {
                    degrees -= 360
                }
                while degrees < 0 {
                    degrees += 360
                }
                return Value(degrees: degrees, minutes: minutes)
            } else {
                return nodes[0].value
            }
        }
    }

    init(_ value: Value) {
        self.op = nil
        self.nodes = []
        self.v = value
    }

    /*
    init(op: Operator?, left: Value?, right: Value?) {
        self.op = op
        self.nodes = []
        if let l = left {
            self.nodes.append(Entry(value: l))
        }
        if let r = right {
            self.nodes.append(Entry(value: r))
        }
    }

    init(op: Operator?, left: Value?, right: Entry?) {
        self.op = op
        self.nodes = []
        if let l = left {
            self.nodes.append(Entry(value: l))
        }
        if let r = right {
            self.nodes.append(r)
        }
    }
     */
    
    init(op: Operator?, left: Entry?, right: Entry?) {
        self.op = op
        self.nodes = []
        if let l = left {
            self.nodes.append(l)
        }
        if let r = right {
            self.nodes.append(r)
        }
    }

    public var description: String {
        var result: [String] = []
        if let v = v {
            result.append("\(v.description)")
        } else {
            if nodes.count > 0 {
                result.append("(")
            }
            if nodes.count == 0 {
                result.append("<empty>")
            } else {
                result.append("\(nodes[0].description)")
            }
            if let b = op {
                result.append("\(b)")
            } else {
                result.append("<noop>")
            }
            if nodes.count == 1 {
                result.append("<empty>")
            } else {
                result.append("\(nodes[1].description)")
            }
            if nodes.count > 0 {
                result.append(")")
            }
        }
        return result.joined(separator: " ")
    }
}
