//
//  ModelDisplay.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/23/25.
//

import Foundation

/**
 This extension is for `ObservableModelData.displayLines` to make left padding easier.
 */
extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {
        let padCount = toLength - self.count
        guard padCount > 0 else { return self }
        return String(repeating: withPad, count: padCount) + self
    }
}
 
/**
 Structure for the DisplayLinesViews to use. If eg. we wanted to add a little superscript ⁺¹ (+1) to
 HMS values over 24 hours, it should be added here and the view is responsible for rendering it.
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

/**
 Extension `ObservableModelData.displayLines` to get the `DisplayLine` structs for a single
 `Expr`.
 */
extension Expr {
    public func displayLines(includeResult: Bool = true) -> [DisplayLine] {
        let _ = ExecutionTimer("thread: \(Thread.current): Expr.displayLines() -> [DisplayLine]", indent: 3)
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

/**
 `ObservableModelData` is a wrapper around `ModelData`.
 This keeps the latter purely business logic focused - no SwiftUI `@published` etc.
 
 This is responsible for publishing and only updating when necessary.
 This helps keep the UI swift hahaha pun intenden.
 */
@MainActor
class ObservableModelData: ObservableObject {
    var md: ModelData
    
    init(mode: ModelData.ExprMode) {
        self.md = ModelData(mode: mode)
    }
    
    /** UI published versions of `ModelData` variables */
    @Published var builtExpressions: [Expr] = []
    @Published private(set) var currentNumber: String = ""
    @Published private(set) var intOnly: Bool = false
    @Published var displayLines: [DisplayLine] = []
    /** Internal copy of the generated `DisplayLine` objects. Copied to the published var when they're different. */
    internal var displayLinesCache: [DisplayLine] = []

    /**
     Main access point for the model data
     It takes a CalculatorFunction (enum) and in the case of ENTRY, the label, a string that
     contains the text being entered.
     
     Eg. a simple addition of 10 + 5
     ```
     callFunction(ENTRY, "1")
     callFunction(ENTRY, "0")
     callFunction(ADD, "")
     callFunction(ENTRY, "5")
     callFunction(EQUAL, "")
     */

    var exprMode: ModelData.ExprMode {
        get { return md.exprMode }
    }
    
    func callFunction(_ f: CalculatorFunction, label: String) {
        let _ = ExecutionTimer("thread: \(Thread.current): ObservableModelData.callFunction \(f) label: \(label)")
        md.callFunction(f, label: label)
        self.displayLinesCache = self.computeDisplayLines()
        self.publishVars()
    }
    
    func publishVars() {
        // Closure that compares published values and updates when appropriate.
        let update = {
            if self.currentNumber != self.md.currentNumber {
                self.currentNumber = self.md.currentNumber
            }
            if self.intOnly != self.md.intOnly {
                self.intOnly = self.md.intOnly
            }
            if self.builtExpressions != self.md.builtExpressions {
                self.builtExpressions = self.md.builtExpressions
            }
            if !self.displayLines.elementsEqual(self.displayLinesCache) {
                self.displayLines = self.displayLinesCache
            }
        }
        
        if Thread.isMainThread {
            update()
        } else {
            DispatchQueue.main.async {
                update()
            }
        }
    }

    private func computeDisplayLines() -> [DisplayLine] {
        let _ = ExecutionTimer("thread: \(Thread.current): ModelData.displayLines() -> [DisplayLine]", indent: 1)

        var result: [DisplayLine] = []

        // Show all previous completed expressions
        for expr in self.md.builtExpressions {
            let displayLines = expr.displayLines()
            result.append(contentsOf: displayLines)
        }

        // Current in-progress expression
        for (i, expr) in self.md.expressionStack.enumerated() {
            let displayLines = expr.displayLines(includeResult: false)
            result.append(contentsOf: displayLines.dropLast())
            let line: DisplayLine = displayLines.last!
            
            // Show operator if one exists for this expression
            if i < self.md.operatorStack.count {
                result.append(DisplayLine(value: line.value, trailingOperator: self.md.operatorStack[i].description))
            }
        }

        // Current input number
        if !self.md.currentNumber.isEmpty {
            result.append(DisplayLine(value: self.md.currentNumber.leftPadding(toLength: 11, withPad: " "), trailingOperator: nil))
        }

        // Assign ids to everything
        return result.enumerated().map { DisplayLine(id: $0.offset, value: $0.element.value, trailingOperator: $0.element.trailingOperator) }
    }
}
