//
//  Expr.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/30/23.
//

import Foundation


/**
 Define operators as an enum based on Character, and provide a function
 that returns the operators position in the precedence hierarchy.
*/
enum Operator: Character, CustomStringConvertible, Hashable, Codable  {
    case add = "+"
    case subtract = "-"
    case divide = "/"

    var precedence: Int {
        switch self {
        case .add, .subtract:
            return 1
        case .divide:
            return 2
        }
    }
    
    public var description: String {
        return String(rawValue)
    }
}


indirect enum Expr: Codable, Hashable, CustomStringConvertible {
    case value(Value)
    case binary(op: Operator, lhs: Expr, rhs: Expr)
    // Variables not supported, but here's the basic start for them.
    //case variable(String)
    // Unary ops (negate) not supported, ditto.
    //case unary(op: Operator, expr: Expr)

    var description: String {
        switch self {
        case .value(let v):
            return v.description
        case .binary(let op, let lhs, let rhs):
            return "(\(lhs) \(op) \(rhs))"
        /* Nope.
        case .variable(let name):
            return name
        case .unary(let op, let expr):
            return "(\(op)\(expr))"
        */
        }
    }
    
    init() {
        self = .value(Value())
    }
    
    func evaluate() -> Value? {
        switch self {
        case .value(let v):
            return v
        case .binary(let op, let lhs, let rhs):
            guard let lv = lhs.evaluate(),
                  let rv = rhs.evaluate() else { return nil }
            switch op {
            case .add:
                return lv.adding(rv)
            case .subtract:
                return lv.subtracting(rv)
            case .divide:
                return lv.dividing(rv)
            }
        }
    }
    
    /**
     'value' recursively computes the expression result.
     
     If the expression is fully formed (has operator, left and right), this function
     computes the value by applying the operator to the result of calling
     value on the left and right nodes.
     
     There's no caching since it's an enum and it can't have a "Value?" var.
     The operations are also ridiculously cheap.
     */
    var value: Value? {
        get {
            return evaluate()
        }
    }
    
    /**
     Inorder visit the tree, apply visit function to each node.
     */
    public func inOrder(visit: (Expr) -> Void) {
        switch self {
        case .value:
            visit(self)
        case .binary( _, let lhs, let rhs):
            lhs.inOrder(visit: visit)
            visit(self)
            rhs.inOrder(visit: visit)
        }
    }
    
    /** Generate a debug print friend multi line (list of strings) decsription of the expression. */
    var multiline: [String] {
        var result: [String] = []
        var line: String = ""
        self.inOrder { expr in
            switch expr {
            case .value(let v):
                line = v.description.leftPadding(toLength: 11, withPad: " ")
            case .binary(let op, _, _):
                line.append(" \(op.description)")
                result.append(line)
                line = ""
            }
        }
        
        if let v = value {
            line.append(" =")
            result.append(line)
            line = v.description.leftPadding(toLength: 11, withPad: " ")
            result.append(line)
        } else {
            result.append(line)
        }
        return result
    }
}
