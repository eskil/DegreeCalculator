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
    
    init() {
        degrees = 0
        minutes = 0.0
    }

    init(degrees: Int, minutes: Decimal) {
        self.degrees = degrees
        self.minutes = minutes
    }
    
    // Format to <degrees>°<mm>'<s> format.
    public var description: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        formatter.decimalSeparator = "'"
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        let number = NSDecimalNumber(decimal: minutes)
        if let s = formatter.string(from: number) {
            return String(format: "%d°%@", degrees, s)
        } else {
            return String(format: "%d°", degrees)
        }
    }
}

enum Operator: String, CustomStringConvertible, Hashable, Codable {
    case Add
    case Subtract
    case Divide
    
    public var description: String {
        switch self {
        case .Add:
            return "+"
        case .Subtract:
            return "-"
        case .Divide:
            return "/"
        }
    }
}

struct Expr: CustomStringConvertible, Hashable, Codable {
    static func == (lhs: Expr, rhs: Expr) -> Bool {
        return lhs.value == rhs.value
    }
    
    var nodes: [Expr]
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
                return nil
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
                case Operator.Divide:
                    /*
                    WOOF this needs to
                    take degrees x 60 + minutes
                    do the rounding div
                    */
                    
                    let roundingBehavior = NSDecimalNumberHandler(
                        roundingMode: NSDecimalNumber.RoundingMode.plain,
                        scale: 1, // One decimal place
                        raiseOnExactness: false,
                        raiseOnOverflow: false,
                        raiseOnUnderflow: false,
                        raiseOnDivideByZero: false
                    )

                    let full_minutes = Decimal(lv.degrees * 60) + lv.minutes
                    let unrounded = NSDecimalNumber(decimal: full_minutes / Decimal(rv.degrees))
                    let rounded = unrounded.rounding(accordingToBehavior: roundingBehavior)
                    
                    degrees = rounded.intValue / 60
                    minutes = rounded.decimalValue - Decimal(degrees * 60)
                }
                
                // This could be done via % 60 and % 360 and checking
                // for negative. But this is not runtime sensitive and
                // this extremely literal version is an easy to
                // understand/read reflection of how a person does
                // this math.
                while minutes >= 60.0 {
                    degrees += 1
                    minutes -= 60.0
                }
                while minutes < 0.0  {
                    minutes += 60.0
                    degrees -= 1
                }
                /*
                NOTE: disable auto overflow subtractions as we add -360 button instead
                while degrees >= 360 {
                    degrees -= 360
                }
                */
                while degrees < 0 {
                    degrees += 360
                }
                return Value(degrees: degrees, minutes: minutes)
            } else {
                return nodes[0].value
            }
        }
    }

    // Expr can be empty, no children and no op
    init() {
        self.op = nil
        self.nodes = []
        self.v = nil
    }
    
    // Expr can be a Value (leaf), no childre and no op
    init(_ value: Value) {
        self.op = nil
        self.nodes = []
        self.v = value
    }
    
    // Expressions are built left side first.
    init(op: Operator?, left: Expr?) {
        self.op = op
        self.nodes = []
        if let l = left {
            self.nodes.append(l)
        }
    }
    
    // Expressions are built left side first.
    init(op: Operator?, left: Expr, right: Expr?) {
        self.op = op
        self.nodes = []
        self.nodes.append(left)
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
            if nodes.count > 0 {
                result.append("\(nodes[0].description)")
            } else {
                result.append("<empty>")
            }
            if let b = op {
                result.append("\(b)")
            } else {
                result.append("<noop>")
            }
            if nodes.count > 1 {
                result.append("\(nodes[1].description)")
            } else {
                result.append("<empty>")
            }
            if nodes.count > 0 {
                result.append(")")
            }
        }
        return result.joined(separator: " ")
    }
    
    public func inOrder(visit: (Expr) -> Void) {
        if nodes.count > 0 {
            nodes[0].inOrder(visit: visit)
        }
        visit(self)
        if nodes.count > 1 {
            nodes[1].inOrder(visit: visit)
        }
    }
}
