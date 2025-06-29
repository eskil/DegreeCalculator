//
//  DegreeCore.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/30/23.
//

import Foundation

/**
 Value is the part of an expression that models the numeric value.
 
 It only supports degrees (int) and minutes (decimal).
 */
struct Value: Codable, Hashable, CustomStringConvertible {
    var degrees: Int?
    var minutes: Decimal?
    var integer: Int?
    
    init() {
        degrees = 0
        minutes = 0.0
    }

    init(integer: Int) {
        self.integer = integer
    }
    
    init(degrees: Int, minutes: Decimal) {
        self.degrees = degrees
        self.minutes = minutes
        /*
        while self.minutes >= 60.0 {
            self.degrees += 1
            self.minutes -= 60.0
        }
        */
    }
    
    /**
     Format to  displayable `<degrees>°<mm>'<s>` format used inside the calculator view.
     */
    public var description: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        formatter.decimalSeparator = "'"
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        if let d = degrees, let m = minutes {
            let number = NSDecimalNumber(decimal: m)
            if let s = formatter.string(from: number) {
                return String(format: "%d°%@", d, s)
            } else {
                return String(format: "%d°", d)
            }
        } else if let i = integer {
            return String(format: "%d", i)
        } else {
            return String("nan")
        }
    }
}

/**
 The Operator is the part of the expression that models the operator.
 */
enum Operator: String, CustomStringConvertible, Hashable, Codable {
    case Add
    case Subtract
    case Divide
    
    /**
     Format to  displayable `string used inside the calculator view.
     */
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

/**
 Expr captures the binary tree structure of an expression.
 It has an Operator and array of Exprs the operator applies to.
 The operator is optional and it can be a value instead.
 
 This is binary tree, so the array of Exprs is at max two, representing
 left and right.
 
 So eg. a basic 2+3 is an Expr with op = PLUS and two Exprs,
 each that have no op but have a value.
 */
struct Expr: CustomStringConvertible, Hashable, Codable {
    static func == (lhs: Expr, rhs: Expr) -> Bool {
        return lhs.value == rhs.value
    }
    
    /** Instead of optional left/rights, we use an erros. This is because
     swift doesn't support recursive structures.
    Another alternative wouldn't been enums;
     enum BinaryTree<T> {
         case empty
         case node(value: T, left: BinaryTree, right: BinaryTree)
     }
    */
    var nodes: [Expr]
    var op: Operator?
    var v: Value?
    
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
    
    /**
     value recursively computes the expression value.
     If the expression is fully formed (has operator, left and right), this function
     computes the value by applying the operator to the result of calling
     value on the left and right nodes.
     
     There's no caching of the value (for simplicity's sake), but the operations
     are so simple that this should not pose a problem.
     */
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

            // Compute left and right side, and if they're
            // non-nil, compute the result.
            if let lv = nodes[0].value, let rv = nodes[1].value {
                var degrees: Int = 0
                var minutes: Decimal = 0.0
                
                // Apply the operation first...
                switch op! {
                case Operator.Add:
                    if let lvd = lv.degrees, let rvd = rv.degrees  {
                        degrees = lvd + rvd
                    }
                    if let lvm = lv.minutes, let rvm = rv.minutes {
                        minutes = lvm + rvm
                    }
                case Operator.Subtract:
                    if let lvd = lv.degrees, let rvd = rv.degrees  {
                        degrees = lvd - rvd
                    }
                    if let lvm = lv.minutes, let rvm = rv.minutes {
                        minutes = lvm - rvm
                    }
                case Operator.Divide:
                    let roundingBehavior = NSDecimalNumberHandler(
                        roundingMode: NSDecimalNumber.RoundingMode.plain,
                        scale: 1, // One decimal place
                        raiseOnExactness: false,
                        raiseOnOverflow: false,
                        raiseOnUnderflow: false,
                        raiseOnDivideByZero: false
                    )

                    if let lvd = lv.degrees, let lvm = lv.minutes, let denom = rv.integer {
                        let full_minutes = Decimal(lvd * 60) + lvm
                        let unrounded = NSDecimalNumber(decimal: full_minutes / Decimal(denom))
                        let rounded = unrounded.rounding(accordingToBehavior: roundingBehavior)

                        degrees = rounded.intValue / 60
                        minutes = rounded.decimalValue - Decimal(degrees * 60)
                    } else {
                        // left of right node is nil,
                        return nil
                    }
                }
                
                // Normalise minutes to keep within [0..60] and degreess
                // as positive.
                // This could be done via % 60 and % 360 and checking
                // for negative. But this is not runtime sensitive.
                while minutes >= 60.0 {
                    degrees += 1
                    minutes -= 60.0
                }
                while minutes < 0.0  {
                    minutes += 60.0
                    degrees -= 1
                }
                /*
                NOTE: disable auto overflow subtractions as we add -360 button
                instead. This allows adding eg. 250° + 251°= 501° to divide
                by 2 to get 250°30'0. If we still did this, 501 would become
                141° and /2 would yield 70°30'0.
                 
                while degrees >= 360 {
                    degrees -= 360
                }
                */
                while degrees < 0 {
                    degrees += 360
                }
                return Value(degrees: degrees, minutes: minutes)
            } else if nodes[0].value != nil {
                return nodes[0].value
            } else {
                // Neither left not right value means nil
                return nil
            }
        }
    }
    
    /**
     Format to  displayable `string used inside the calculator view.
     */
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
        return result.joined(separator: "")
    }
    
    /**
     Inorder visit the tree, apply visit function to each node.
     */
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
