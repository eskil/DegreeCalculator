//
//  ModelDisplay.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/23/25.
//

import Foundation

/*
extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {
        let padCount = toLength - self.count
        guard padCount > 0 else { return self }
        return String(repeating: withPad, count: padCount) + self
    }
}
*/
 
struct DisplayLine: Identifiable, Hashable {
    let id: Int
    let value: String
    let trailingOperator: String? // e.g. "+", "=", "=="
    
    init(id: Int = 0, value: String, trailingOperator: String?) {
        self.id = id
        self.value = value
        self.trailingOperator = trailingOperator
    }
}

extension Expr {
    public func displayLines(includeResult: Bool = true) -> [DisplayLine] {
        var result: [DisplayLine] = []
        var value: String? = nil
        self.inOrder { expr in
            switch expr {
            case .value(let v):
                value = v.description.leftPadding(toLength: 11, withPad: " ")
            case .binary(let op, _, _):
                // Id is irrelevant, ModelData.displayLines reassigns it
                result.append(DisplayLine(value: value ?? "", trailingOperator: op.description))
                value = nil
            }
        }

        // Add result line with "=="
        if includeResult, let expr_value = self.value?.description.leftPadding(toLength: 11, withPad: " ") {
            result.append(DisplayLine(value: value ?? "", trailingOperator: "="))
            result.append(DisplayLine(value: expr_value, trailingOperator: "=="))
        } else {
            result.append(DisplayLine(value: value ?? "", trailingOperator: nil))
        }

        return result
    }
}

extension ModelData {
    func displayLines() -> [DisplayLine] {
        var result: [DisplayLine] = []

        // 1. Show all previous completed expressions
        for expr in builtExpressions {
            let displayLines = expr.displayLines()
            result.append(contentsOf: displayLines)
        }

        // 2. Current in-progress expression
        for (i, expr) in expressionStack.enumerated() {
            let displayLines = expr.displayLines(includeResult: false)
            result.append(contentsOf: displayLines.dropLast())
            let line: DisplayLine = displayLines.last!

            // Show operator if one exists for this expression
            if i < operatorStack.count {
                result.append(DisplayLine(value: line.value, trailingOperator: operatorStack[i].description))
            }
        }

        // 3. Current input number
        if !currentNumber.isEmpty {
            result.append(DisplayLine(value: currentNumber.leftPadding(toLength: 11, withPad: " "), trailingOperator: nil))
        }

        return result.enumerated().map { DisplayLine(id: $0.offset, value: $0.element.value, trailingOperator: $0.element.trailingOperator) }
    }
}
