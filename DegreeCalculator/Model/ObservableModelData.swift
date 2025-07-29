//
//  ModelDisplay.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/23/25.
//

import Foundation

extension String {
    func leftPadding(toLength: Int, withPad: String = " ") -> String {
        let padCount = toLength - self.count
        guard padCount > 0 else { return self }
        return String(repeating: withPad, count: padCount) + self
    }
}
 
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
    public func cachedDisplayLines(using cache: inout [Expr: [DisplayLine]], includeResult: Bool = true) -> [DisplayLine] {
        // Cache for UI performance
        if let cached = cache[self] {
            return cached
        }
        
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
        
        cache[self] = result
        return result
    }
}

final class ObservableModelData: ObservableObject {
    var md: ModelData
    
    init(mode: ModelData.ExprMode) {
        self.exprMode = mode
        self.md = ModelData(mode: mode)
    }
    
    let exprMode: ModelData.ExprMode
    
    /* UI published version of ModelData variables */
    @Published var builtExpressions: [Expr] = []
    @Published private(set) var currentNumber: String = ""
    @Published private(set) var intOnly: Bool = false
    @Published var displayLines: [DisplayLine] = []
    var displayLinesCache: [DisplayLine] = []
    var exprCache: [Expr: [DisplayLine]] = [:]

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
    func callFunctionAsync(_ f: CalculatorFunction, label: String) async {
        return self.callFunction(f, label: label)
    }
    func callFunction(_ f: CalculatorFunction, label: String) {
        let _ = ExecutionTimer("thread: \(Thread.current): ObservableModelData.callFunction \(f) label: \(label)")
        md.callFunction(f, label: label)
        self.displayLinesCache = self.computeDisplayLines()
        publishVars()
    }
    
    func publishVars() {
        // Update UI thread
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
            if self.displayLines != self.displayLinesCache {
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

        // 1. Show all previous completed expressions
        if true {
            let _ = ExecutionTimer("thread: \(Thread.current): ModelData.displayLines() -> 1", indent: 2)
            for expr in self.md.builtExpressions {
                let displayLines = expr.cachedDisplayLines(using: &exprCache)
                result.append(contentsOf: displayLines)
            }
        }

        // 2. Current in-progress expression
        if true {
            let _ = ExecutionTimer("thread: \(Thread.current): ModelData.displayLines() -> 2", indent: 2)
            for (i, expr) in self.md.expressionStack.enumerated() {
                let displayLines = expr.cachedDisplayLines(using: &exprCache, includeResult: false)
                result.append(contentsOf: displayLines.dropLast())
                let line: DisplayLine = displayLines.last!
                
                // Show operator if one exists for this expression
                if i < self.md.operatorStack.count {
                    result.append(DisplayLine(value: line.value, trailingOperator: self.md.operatorStack[i].description))
                }
            }
        }

        // 3. Current input number
        if true {
            let _ = ExecutionTimer("thread: \(Thread.current): ModelData.displayLines() -> 3", indent: 2)
            if !self.md.currentNumber.isEmpty {
                result.append(DisplayLine(value: self.md.currentNumber.leftPadding(toLength: 11, withPad: " "), trailingOperator: nil))
            }
        }

        if true {
            let _ = ExecutionTimer("thread: \(Thread.current): ModelData.displayLines() -> 4", indent: 2)
            return result.enumerated().map { DisplayLine(id: $0.offset, value: $0.element.value, trailingOperator: $0.element.trailingOperator) }
        }
    }
}
