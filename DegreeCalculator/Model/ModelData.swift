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
final class ModelData: ObservableObject {
    /* Controls whether we're doing degrees-minutes-seconds math or hours-minutes-seconds
     */
    enum ExprMode {
        case DMS
        case HMS
    }
        
    init(mode: ExprMode) {
        self.exprMode = mode
    }
    
    /**
     builtExpressions is the list of expressions built.
     
     Each time EQUAL is executed, the current expression is computed (via value)
     and a new expression is started.
     So in short, this stores all expressions computer until a allClear is issued.
     */
    @Published var builtExpressions: [Expr] = []
    
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
    var currentNumber: String = ""
    
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
    
    /**
     DisplayStack is purely for displaying the input in presentable way.
     
     On each operator being entered, the currentNumber is processed put on this stack
     suffixed with the operator.
     
     This allows for "printing" the inmput as lines, but the precedence is still
     left to the reader. Additionally the processing of the number means a "6" becomes
     "6.0", and if supported °'" and decimals, that would also show up on the display output.
     */
    var displayStack: [String] = []
    
    /** When last operator is divide, disable degrees/minutes input */
    @Published var disableDegreesAndMinutes: Bool = false
    
    /** The entry mode for this model.
     NOTE: This could be encapsulated in the class hierarchy and I might do that some day.
     */
    var exprMode: ExprMode = .DMS
    
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
        switch f {
        case .ANS:
            return ans()
        case .ALL_CLEAR:
            return allClear()
        case .CLEAR:
            return clear()
        case .DELETE:
            return delete()
        case .ADD:
             return add()
        case .SUBTRACT:
             return subtract()
        case .DIV:
             return divide()
        case .M360:
             return minus_360()
        case .EQUAL:
            return equal()
        case .ENTRY:
            if label.count == 1,
               let char = label.first
            {
                return addEntry(char)
            }
        }
    }
    
    // NOTE: _ is a Swift syntax to indicate the argument doesn't need to be named when
    // called, ie. addEntry("str") instead of addEntry(string: "str")
    func addEntry(_ char: Character) {
        NSLog("addEntry (\(char))")

        /**
         If it's a number or dms/hms char, append to currentNumber, otherwise it's an
         operator and we start an expression on expressionStack.
         */
        if char.isNumber {
            inputStack.append(char)
            currentNumber.append(char)
        }
        else if exprMode == .DMS && char == "°" {
            if addDegreeHour() {
                inputStack.append(char)
            }
        }
        else if exprMode == .DMS && char == "'" {
            if addMinutes() {
                inputStack.append(char)
            }
        }
        else if exprMode == .HMS && char == "h" {
            if addDegreeHour() {
                inputStack.append(char)
            }
        }
        else if exprMode == .HMS && char == "m" {
            if addMinutes() {
                inputStack.append(char)
                currentNumber.append(char)
            }
        }
        /*
        else if exprMode == .HMS && char == "s" {
            if addSeconds() {
                inputStack.append(char)
                currentNumber.append(char)
            }
        }
        */
        else if let inputOp = Operator(rawValue: char) {
            inputStack.append(char)
            /**
             We're entering an operator, so convert the currentNumber
             input into an Expr.value and push onto the expressionStack.
             This makes it availble for composing into a new expression
             depending on the precedence of the operator.
             */
            if let val = Value(from: currentNumber) {
                displayStack.append("\(val) \(inputOp.rawValue)")
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
            /* Add the newly input operator */
            operatorStack.append(inputOp)
        }
    }
    
    /**
     Reset the entire state.
     */
    func allClear() {
        disableDegreesAndMinutes = false
        builtExpressions.removeAll()
        inputStack.removeAll()
        currentNumber.removeAll()
        displayStack.removeAll()
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
        NSLog("DEL")
        guard !inputStack.isEmpty else { return }
        let removedChar = inputStack.removeLast()
        NSLog("\tdeleted \(removedChar)")
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
        /*
         This is a bit unconventional. But to avoid buildings "a full
         calculator" and have to make it clear how precedence comes into play, divide
         first issues an "equal" to reduce to 1 number.
         This is grosds.
         */
        equal()
        disableDegreesAndMinutes = true
        addEntry(Operator.divide.rawValue)
    }
    
    func minus_360() {
        // Start a subtractions
        clear()
        addEntry(Operator.subtract.rawValue)
        addEntry("3")
        addEntry("6")
        addEntry("0")
        addEntry("°")
        return equal()
    }
    
    func equal() {
        // Reenable this in case it was disabled while inputting a number for division
        disableDegreesAndMinutes = false
        debugLog("EQUAL")
        if let expr = buildExpr() {
            NSLog("Expr \(expr)")
            NSLog("Expr \(expr.description)")
            NSLog("Expr \(expr.evaluate())")
            inputStack.removeAll()
            currentNumber.removeAll()
            // TODO: save displaystack ?
        }
    }
    
    func addDegreeHour() -> Bool {
        switch exprMode {
        case .DMS:
            if currentNumber.contains("°") {
                return false
            }
            if currentNumber.isEmpty {
                currentNumber = "0°"
            } else {
                currentNumber += "°"
            }
        case .HMS:
            if currentNumber.contains("h") {
                return false
            }
            if currentNumber.isEmpty {
                currentNumber = "0h"
            } else {
                currentNumber += "h"
            }
        }
        return true
    }
    
    func addMinutes() -> Bool {
        switch exprMode {
        case .DMS:
            // We already set minutes
            if currentNumber.contains("'") {
                return false
            }
            // If we haven't set °, prefix 0°
            if currentNumber.contains("°") == false {
                currentNumber = "0°" + currentNumber
            }
            // If the last char isn't a number, we're entering "'", so put a 0
            if let c = currentNumber.last {
                if c.isNumber == false {
                    currentNumber += "0"
                }
            }
            currentNumber += "'"
        case .HMS:
            // We already set minutes
            if currentNumber.contains("m") {
                return false
            }
            // If we haven't set h, prefix 0h
            if currentNumber.contains("h") == false {
                currentNumber = "0h" + currentNumber
            }
            // If the last char isn't a number, we're entering "'", so put a 0 up front
            if let c = currentNumber.last {
                if c.isNumber == false {
                    currentNumber += "0"
                }
            }
            currentNumber += "m"
        }
        return true
    }
    
    /*
    func addSeconds() -> Bool {
        switch exprMode {
        case .DMS:
            break;
        case .HMS:
            // We already set seconds
            if currentNumber.contains("s") {
                return false
            }
            // If we haven't set m, prefix 0m
            if currentNumber.contains("m") == false {
                currentNumber = "0m" + currentNumber
            }
            // If we haven't set h, prefix 0h
            if currentNumber.contains("h") == false {
                currentNumber = "0h" + currentNumber
            }
            // If the last char isn't a number, we're entering "hms", so put a 0 up front
            if let c = currentNumber.last {
                if c.isNumber == false {
                    currentNumber += "0"
                }
            }
            currentNumber += "s"
        }
        
        return true
    }
    */
    
    /**
    Build an expression from the current expressionStack and operatorStack.
    
    */
    func buildExpr() -> Expr? {
        NSLog("BUILD")
        /* Why this rebuild? Because of the expression has become partly formed
        after a delete, but buildExpr was called, we may have manipulated the stack.

        Calling rebuild is a simple/safe way to hard reset the whole thing.

        It's possible this function could be fixed to not need this, but it's not
        worth saving a few cpu cycles for this.
        */
        rebuildExpr()

        NSLog("\tPRE")
        NSLog("\t\tbuild expressionStack")
        for expr in expressionStack {
            print("\t\t\t- \(expr)")
        }
        NSLog("\t\tbuild operatorStack \(operatorStack)")
        NSLog("\t\tbuild inputStack \(inputStack)")
        NSLog("\t\tbuild currentNumber \(currentNumber)")

        /*
        If a number is being entered, ensure it's processed and on the expressionStack.
        This manipulates the stacks and why we call rebuildExpr early
        */
        if let val = Value(from: currentNumber) {
            displayStack.append("\(val) =")
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

        NSLog("\tPOST")
        NSLog("\t\tbuild expressionStack after pop")
        for expr in expressionStack {
            NSLog("\t\t\t- \(expr)")
        }
        NSLog("\t\tbuild operatorStack \(operatorStack)")
        NSLog("\t\tbuild inputStack \(inputStack)")
        NSLog("\t\tbuild currentNumber \(currentNumber)")

        /*
        The operatorStack can be non-empty if eg. buildExpr is called,
        but there's no number entered after an operator (for example, "2+2/").

        In that case we return nil as there's no value to compute.

        As a sanity check, ensure the expressionStack is 1.
        */
        if operatorStack.isEmpty, expressionStack.count == 1, let expr = expressionStack.last {
            /* "pretty" print the input from the user */
            displayStack.append("\(expressionStack.last?.evaluate() ?? Value())")
            NSLog("----------------")
            var flip = false
            for line in displayStack {
                if flip {
                    NSLog("----------------")
                }
                NSLog("\t\(line)")
                if flip {
                    NSLog("================")
                }
                if line.contains("=") {
                    flip = true
                }
            }
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
        NSLog("\t\tpop expressionStack")
        for expr in expressionStack {
            print("\t\t\t- \(expr)")
        }
        NSLog("\t\tpop operatorStack \(operatorStack)")
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
        displayStack.removeAll()
        expressionStack.removeAll()
        operatorStack.removeAll()
        currentNumber.removeAll()
        for char in backup {
            addEntry(char)
        }
    }

}


