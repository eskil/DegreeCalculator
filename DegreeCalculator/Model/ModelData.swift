//
//  ModelData.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/21/23.
//

import Foundation

/*
 https://iosapptemplates.com/blog/ios-development/data-persistence-ios-swift
 
 https://www.hackingwithswift.com/example-code/strings/how-to-save-a-string-to-a-file-on-disk-with-writeto
 https://www.hackingwithswift.com/example-code/strings/how-to-load-a-string-from-a-file-in-your-bundle
 */

/**
 This enum represents the possible functions
 */
enum CalculatorFunction: Int {
    // Insert last answer as entry
    case ANS
    // Clear everyhing
    case ALL_CLEAR
    // Clear current input
    case CLEAR
    // Delete last ENTRY
    case DELETE
    // Start + operation
    case ADD
    // Start - operation
    case SUBTRACT
    // Start / operation, only accept "normal" numeric input
    case DIV
    // Compute current math operationr
    case EQUAL
    // Entry is a single number entered
    case ENTRY
    // M360 is a triple tap on - to subtract 360
    case M360
}

extension String {
    mutating func addDegreeHour(mode: ModelData.ExprMode) -> Bool {
        switch mode {
        case .DMS:
            guard !self.contains("°") else {
                return false
            }

            if self.isEmpty {
                self = "0°"
            } else {
                self += "°"
            }
        case .HMS:
            guard !self.contains("h") else {
                return false
            }

            if self.isEmpty {
                self = "0h"
            } else {
                self += "h"
            }
        }
        return true
    }
    
    mutating func addMinutes(mode: ModelData.ExprMode) -> Bool {
        switch mode {
        case .DMS:
            // We already set minutes
            guard !self.contains("'") else {
                return false
            }
            // If we haven't set °, prefix 0°
            if !self.contains("°")  {
                self = "0°" + self
            }
            // If the last char isn't a number, we're entering "'", so put a 0
            if let c = self.last {
                if !c.isNumber {
                    self += "0"
                }
            }
            self += "'"
        case .HMS:
            // We already set minutes
            guard !self.contains("m") else {
                return false
            }
            // If we haven't set h, prefix 0h
            if !self.contains("h") {
                self = "0h" + self
            }
            // If the last char isn't a number, we're entering "m", so put a 0 up front
            if let c = self.last {
                if !c.isNumber {
                    self += "0"
                }
            }
            self += "m"
        }
        return true
    }
}

/**
 ModelData is the observable entity that the UI interacts with.
 
 The primary access is callFunction, called by button widgets to operate on the model.
 
 Internally it maintains a list of Expr objects (from DegreeCore). Where Expr is only
 responsible for storing the expressions and values and converting to a displayable string,
 ModeData controls the operations.
 
 MVC style, It'd be a better naming to have
 - ModelData is the Controller
 - DegreeCode (Expr & Value) are the Models.
 - The UI is the View that uses the descriptions() from the Expr/Value
 
 The naming stems from the SwiftUI tutorials.
*/
class ModelData {
    /* Controls whether we're doing degrees-minutes-seconds math or hours-minutes-seconds
     */
    enum ExprMode {
        case DMS
        case HMS
        
        func toHint() -> Value.ValueTypeHint {
            switch self {
            case .DMS:
                return .dms
            case .HMS:
                return .hms
            }
        }
    }

    /** The entry mode for this model. */
    let exprMode: ExprMode
    

    init(mode: ExprMode) {
        self.exprMode = mode
    }
    
    
    /**
     builtExpressions is the list of expressions built.
     
     Each time EQUAL is executed, the current expression is computed (via value)
     and a new expression is started.
     So in short, this stores all expressions computer until a allClear is issued.
     */
    var builtExpressions: [Expr] = []
    
    /**
     The inputStack is the raw unprocessed sequence of characters input by the user.
     
     This allows for editing the input, eg. the most basic operation is backspace - pop
     the last input - and the current inputStack can be replayed to a new expression.
     */
    var inputStack: [Character] = []
    
    /**
     currentNumber is the current Value being input, as a string.
     
     As long as the input character is part of a Value, it's appended to this.
     
     At any time this value should be convertible to a Value. This is relied on
     when the input is an operator (and non-number charactor). Then currentNumber is
     used to construct a Value..
     
     it is difrerent from the inputStack in that it's manipulated, not just user entered data. Eg. for DMS values, if you enter "'" alone, "0°0" is prepended.
     */
    internal var currentNumber: String = ""
    
    /**
     expressionStack is the stack of evaluated subexpressions.
     
     As operators are entered (see operatorStack), we can process the input into
     expressions. These are kept in this stack.
     
     Eg. when entering "10/2+", when + is entered, before it's pushed onto the operatorStack
     (which already has /) we eval the expression.
     
     The expressionStack has two Expr.num values (10 and 2), that can popped along with the
     operatorStack, those three components are used to make a Expr.operation that's put
     on the expressionStack.
     
     After "+", the operatorStack has "+" and the expressionStack has "10/2".
     */
    var expressionStack: [Expr] = []
    
    /**
     OperatorStack contains the operators input but _not yet_ evaluated.
     
     This is key to handling precedence. As numbers and operators are entered, we keep a stack of
     operators entered. Eg. entering "2 + 4 -" will have + on the stack until -
     is entered. Since it's same-or-lower precedence, we can pop + from the stack and
     process "2 + 4" into a new expression and put into expressionStack.
     
     If we entered "2 / 4 + ", we'd have / on the stack until + is entered.
     Since + is same-or-lower precedence then /, we can pop / from the stack and process "2 / 4".
     This leaves - on the operator stack.
     
     But if we enter "2 + 4 /", we'd have - on the stack until / is entered.
     Since / higher precedence then +, we can't evaluate "2 + 4" yet, so the stack is now "+ /".
     */
    var operatorStack: [Operator] = []
    
    /** When last operator is divide, disable degrees/jhours/minutes input */
    internal var intOnly: Bool = false
    
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
    func callFunction(_ f: CalculatorFunction, label: String) {
        let _ = ExecutionTimer("thread: \(Thread.current): ModelData.callFunction \(f) label: \(label)", indent:1 )
                
        switch f {
        case .ANS:
            ans()
        case .ALL_CLEAR:
            allClear()
        case .CLEAR:
            clear()
        case .DELETE:
            delete()
        case .ADD:
             add()
        case .SUBTRACT:
             subtract()
        case .DIV:
             divide()
        case .M360:
             minus_360()
        case .EQUAL:
            equal()
        case .ENTRY:
            if label.count == 1,
               let char = label.first
            {
                addEntry(char)
            }
        }
    }
    
    // NOTE: _ is a Swift syntax to indicate the argument doesn't need to be named when
    // called, ie. addEntry("str") instead of addEntry(string: "str")
    func addEntry(_ char: Character) {
        /**
         If it's a number or dms/hms char, append to currentNumber, otherwise it's an
         operator and we start an expression on expressionStack.
         */
        if char.isNumber {
            inputStack.append(char)
            currentNumber.append(char)
        }
        else if exprMode == .DMS && char == "°" && !intOnly {
            if currentNumber.addDegreeHour(mode: exprMode) {
                inputStack.append(char)
            }
        }
        else if exprMode == .DMS && char == "'" && !intOnly {
            if currentNumber.addMinutes(mode: exprMode) {
                inputStack.append(char)
            }
        }
        else if exprMode == .HMS && char == "h" && !intOnly {
            if currentNumber.addDegreeHour(mode: exprMode) {
                inputStack.append(char)
            }
        }
        else if exprMode == .HMS && char == "m" && !intOnly {
            if currentNumber.addMinutes(mode: exprMode) {
                inputStack.append(char)
            }
        }
        else if !currentNumber.isEmpty, let inputOp = Operator(rawValue: char) {
            inputStack.append(char)
            /**
             We're entering an operator, so convert the currentNumber
             input into an Expr.value and push onto the expressionStack.
             This makes it availble for composing into a new expression
             depending on the precedence of the operator.
             */
            if let val = Value(parsing: currentNumber, hint: intOnly ? .integer : exprMode.toHint()) {
                expressionStack.append(.value(val))
                currentNumber = ""
            }
            /**
             As long as the top of the operator stack has higher or equal
             precedence than the operator entered, we pop the operator, which will
             replace the last two entries on expressionStack with a "left op right"
             expression. This handles precedence.
             */
            while let lastOp = operatorStack.last, lastOp.precedence >= inputOp.precedence {
                popOperator()
            }
            // Add the newly input operator
            operatorStack.append(inputOp)
            
            // If we've entered an divide operator, only accept ints - no division by dms/hms.
            if inputOp == Operator.divide {
                intOnly = true
            }
        }
    }
    
    /**
     Reset the entire state.
     */
    func allClear() {
        intOnly = false
        builtExpressions.removeAll()
        inputStack.removeAll()
        currentNumber.removeAll()
        expressionStack.removeAll()
        operatorStack.removeAll()
    }
    
    func clear() {
        // FIXME: if inputStack is empty it should delete the current expression.
        // Eg. "enter 1d2'3+", pressing clear should remove that.
        inputStack.removeAll()
        currentNumber.removeAll()
    }
    
    func delete() {
        guard !inputStack.isEmpty else { return }
        let _ = inputStack.removeLast()
        rebuildExpr()
    }
    
    func ans() {
        if let val = builtExpressions.last?.value {
            inputStack.removeAll()
            currentNumber.removeAll()
            for c in val.description {
                addEntry(c)
            }
        }
    }
        
    private func debugLog(_ name: String) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(builtExpressions)
            NSLog("JSON for \(name)")
            NSLog(String(data: data, encoding: .utf8)!)
        } catch {
            NSLog("oops")
        }
    }
        
    func add() {
        addEntry(Operator.add.rawValue)
    }
    
    func subtract() {
        addEntry(Operator.subtract.rawValue)
    }
    
    func divide() {
        // If a number is being entered, attempt to close expression first.
        if !currentNumber.isEmpty {
            if !(operatorStack.isEmpty && expressionStack.isEmpty) {
                equal()
                // If the expr is still open, bail
                if !currentNumber.isEmpty {
                    return
                }
            }
        }
        
        // If there's nothing being entered, pull in the previous answer.
        if currentNumber.isEmpty {
            // **nothing** being entered, pull in the previous answer.
            if operatorStack.isEmpty && expressionStack.isEmpty {
                ans()
            }
            // Corner case where there's no answer, it's a NOOP.
            if currentNumber.isEmpty {
                return
            }
        }

        addEntry(Operator.divide.rawValue)
    }
    
    func minus_360() {
        // If a number is being entered, attempt to close expression first.
        if !currentNumber.isEmpty {
            if !(operatorStack.isEmpty && expressionStack.isEmpty) {
                equal()
                // If the expr is still open, bail
                if !currentNumber.isEmpty {
                    return
                }
            }
        }
        
        // If there's nothing being entered, pull in the previous answer.
        if currentNumber.isEmpty {
            // **nothing** being entered, pull in the previous answer.
            if operatorStack.isEmpty && expressionStack.isEmpty {
                ans()
            }
            // Corner case where there's no answer, it's a NOOP.
            if currentNumber.isEmpty {
                return
            }
        }
        
        addEntry(Operator.subtract.rawValue)
        addEntry("3")
        addEntry("6")
        addEntry("0")
        addEntry("°")
        return equal()
    }
    
    func equal() {
        // Avoid cases like "1=" leaving 1 on the builtExpressions.
        if expressionStack.isEmpty {
            return
        }
        
        if let _ = buildExpr() {
            // Reset this now, since buildExpr replays the input,
            // so it could have gotten toggled.
            intOnly = false
            inputStack.removeAll()
            currentNumber.removeAll()
            expressionStack.removeAll()
            operatorStack.removeAll()
        }
    }
    
    /**
    Build an expression from the current expressionStack and operatorStack.
    */
    func buildExpr() -> Expr? {
        let _ = ExecutionTimer("thread: \(Thread.current): ModelData.buildExpr \(self)", indent: 2)

        /* Why this rebuild? Because of the expression has become partly formed
        after a delete, but buildExpr was called, we may have manipulated the stack.

        Calling rebuild is a simple/safe way to hard reset the whole thing.

        It's possible this function could be fixed to not need this, but it's not
        worth saving a few cpu cycles for this.
        */
        rebuildExpr()

        for expr in expressionStack {
            print("\t\t\t- \(expr)")
        }

        /*
        If a number is being entered, ensure it's processed and on the expressionStack.
        This manipulates the stacks and why we call rebuildExpr early
        */
        if let val = Value(parsing: currentNumber, hint: intOnly ? .integer : exprMode.toHint()) {
            expressionStack.append(Expr.value(val))
            currentNumber = ""
        } else {
            NSLog("Cannot convert currentNumber to value")
            return nil
        }
        /* Now clear the operator stack. */
        while !operatorStack.isEmpty {
            popOperator()
        }

        for expr in expressionStack {
            NSLog("\t\t\t- \(expr)")
        }

        /*
        The operatorStack can be non-empty if eg. buildExpr is called,
        but there's no number entered after an operator (for example, "2+2/").

        In that case we return nil as there's no value to compute.

        As a sanity check, ensure the expressionStack is 1.
        */
        if operatorStack.isEmpty, expressionStack.count == 1, let expr = expressionStack.last {
            builtExpressions.append(expr)
            return expr
        } else {
            NSLog("Expression not closed, operatorStack not empty")
        }
        return nil
    }

    
    /**
     Pop a single operator from the operatorStack and build an expression.
     See comment for operatorStack for details.
     */
    private func popOperator() {
        for expr in expressionStack {
            print("\t\t\t- \(expr)")
        }
        guard operatorStack.count > 0, expressionStack.count > 0 else { return }
        guard let op = operatorStack.popLast(),
              let right = expressionStack.popLast(),
              let left = expressionStack.popLast()
        else {
            /*
            NO, if there's an op but no rhs, we did go get gone fucked'
             */
            NSLog("\t\tpop missing element")
            return
        }
        expressionStack.append(Expr.binary(op: op, lhs: left, rhs: right))
    }
    
    /**
    Rebuild the expression from scratch.
    
    This clears all the stacks and replays (from a copy)
    all the characters input.
    
    This simplifies a lot of stack management, eg. during "backspace",
    since we don't have to try and manage the tree.
    */
    func rebuildExpr() {
        print("REBUILD")
        // copy the array
        let backup = inputStack
        inputStack.removeAll()
        expressionStack.removeAll()
        operatorStack.removeAll()
        currentNumber.removeAll()

        // let tmp = intOnly
        // defer { intOnly = tmp }

        // Turn off intonly, addEntry sets it to true if we're ending on a /
        intOnly = false
        for char in backup {
            addEntry(char)
        }
    }

}


