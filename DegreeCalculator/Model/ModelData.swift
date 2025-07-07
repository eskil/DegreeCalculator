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
    
    var mode: ExprMode
    
    init(mode: ExprMode) {
        self.mode = mode
    }
    
    /**
     expressions is the list of expressions.
     
     Each time EQUAL is executed, the current expression is computed (via value)
     and a new expression is started.
     So in short, this stores all expressions computer until a allClear is issued.
     */
    @Published var expressions: [Expr] = [
        // These comments are various test cases I used regularly. Uncomment
        // and the calculator will startup with this as the input.
        /*
         // Basic, add two values
         Expr(op: Operator.Add,
         left: Expr(Value(degrees: 39, minutes: 15.2)),
         right: Expr(Value(degrees: 1, minutes: 21.9))),
         */
        /*
         // Unsupported right-leaning tree
         Expr(op: Operator.Add,
         left: Expr(Value(degrees: 39, minutes: 15.2)),
         right: Expr(op: Operator.Subtract,
         left: Expr(Value(degrees: 1, minutes: 21.9)),
         right: Expr(op: Operator.Add,
         left: Expr(Value(degrees: 49, minutes: 37.1)),
         right: Expr(Value(degrees: 350, minutes: 51.9))))),
         */
        /*
         // Supported left-leaning tree
         Expr(op: Operator.Add,
         left: Expr(op: Operator.Subtract,
         left: Expr(op: Operator.Add,
         left: Expr(Value(degrees: 39, minutes: 15.2)),
         right: Expr(Value(degrees: 1, minutes: 21.9))),
         right: Expr(Value(degrees: 49, minutes: 37.1))),
         right: Expr(Value(degrees: 350, minutes: 51.9))),
         */
        /*
         // Unclosed tree
         Expr(op: Operator.Subtract,
         left: Expr(op: Operator.Add,
         left: Expr(Value(degrees: 1, minutes: 2.3)),
         right: Expr(Value(degrees: 4, minutes: 5.6))),
         right: nil),
         */
        // The initial value is a empty expression that we're inserting into.
        Expr(),
    ]
    
    /**
     The inputStack is the raw unprocessed sequence of characters input by the user.
     
     This allows for editing the input, eg. the most basic operation is backspace - pop
     the last input - and the current inputStack can be reprocessed to a new expression.
     */
    var inputStack: [Character] = []
    
    /**
     currentNumber is the current numeric value being input, as a string.
     
     As long as the input character is part of a number, it's appended to this.
     
     At any time this value should be convertible to a numeric value. This is relied on
     when the imput is an operator (and non-number charactor). Then currentNumber is
     used to construct a Expr.num.
     
     Eg. if input is 7 and 2, this will be "72". If we support degree or decimals,
     the code appending to this should be extended to support characters like
     °" and .
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
    
    /** The entry mode for this model. */
    // This could be encapsulated in the class hierarchy and I might do that some day.
    @Published var exprMode: ExprMode = .DMS
    
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
            return addEntry(label)
        }
    }
    
    // NOTE: _ is a Swift syntax to indicate the argument doesn't need to be named when
    // called, ie. addEntry("str") instead of addEntry(string: "str")
    func addEntry(_ string: String) {
        NSLog("addEntry (\(string))")
        
        /**
         If it's a number, append to currentNumber, otherwise it's an
         operator and we start an expression on expressionStack.
         */
        if string.count == 1,
           let char = string.first,
           char.isNumber
        {
            currentNumber.append(string)
        }
        else if string.count == 1,
                let char = string.first,
                let inputOp = Operator(rawValue: char)
        {
            /**
             We're entering an operator, so convert the currentNumber
             input into an Expr.number and push onto the expressionStack.
             This makes it availble for composing into a new expression
             depending on the precedence of the operator.
             */
            if let num = Int(currentNumber) {
                displayStack.append("\(num) \(inputOp.rawValue)")
                expressionStack.append(.value(Value(integer: num)))
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
        
        // TODO handle all the dms/hms entry here.
        
        /*
         if string == "°" || string == "h" {
         inputStack = setDegreeHour(inputStack)
         } else if string == "'" || string == "m" {
         inputStack = setMinutes(inputStack)
         } else if string == "s" {
         inputStack = setSeconds(inputStack)
         } else {
         // If we have a ' and it's the last, we can add a number. But if not, we've already
         // maxed our string
         if inputStack.contains("'") {
         if let c = inputStack.last {
         if c == "'" {
         inputStack += string
         }
         }
         } else {
         inputStack += string
         }
         }
         */
    }
    
    /**
     Reset the entire state.
     */
    func allClear() {
        disableDegreesAndMinutes = false
        expressions.removeAll()
        inputStack.removeAll()
        displayStack.removeAll()
        expressionStack.removeAll()
        operatorStack.removeAll()
    }
    
    func clear() {
        // FIXME: if inputStack is empty it should delete the current expression.
        // Eg. "enter 1d2'3+", pressing clear should remove that.
        inputStack.removeAll()
    }
    
    func delete() {
        NSLog("DEL")
        guard !inputStack.isEmpty else { return }
        let removedChar = inputStack.removeLast()
        NSLog("\tdeleted \(removedChar)")
        rebuildExpr()
    }
    
    func ans() {
        if expressions.count > 1 {
            let last = expressions[expressions.count-2]
            if let val = last.value {
                inputStack = Array(val.description)
            }
        }
    }
    
    // TODO: move to Value?
    func parseDMSValue(_ s: String) -> Value {
        // Simple parse by just splitting on ° and '. This works since
        // prepExpr(toDMS=true) inserts ° and ' and trailing 0, and when toDMS=false,
        // we get an integer value instead.
        var degrees = 0
        var minutes: Decimal = 0.0
        
        NSLog("parseDMSValue(\(s)), exprMode=\(exprMode)")
        
        let trimmed = s.trimmingCharacters(in: .whitespaces)
        let dgm = trimmed.split(separator: "°")
        // If there's a degree symbol in the string, parse and return
        // as DMS.
        if dgm.count > 0 {
            degrees = Int(dgm[0]) ?? 0
            if dgm.count == 2 {
                let mins = dgm[1].split(separator: "'")
                if mins.count == 2 {
                    minutes = Decimal(Int(mins[0]) ?? 0) + (Decimal((Int(mins[1]) ?? 0)) / 10.0)
                } else {
                    minutes = Decimal(Int(mins[0]) ?? 0)
                }
            }
        }
        
        return Value(degrees: degrees, minutes: minutes)
    }
    
    // TODO: move to Value?
    func parseHMSValue(_ s: String) -> Value {
        return Value()
    }
    
    // TODO: move to Value?
    func parseIntValue(_ s: String) -> Value {
        return Value()
    }
    
    func parseValue(_ s: String) -> Value {
        NSLog("parseValue(\(s)), exprMode=\(exprMode)")
        if exprMode == ExprMode.DMS {
            if s.contains("°") || s.contains("'") {
                return parseDMSValue(s)
            } else {
                return parseIntValue(s)
            }
        }
        if exprMode == ExprMode.HMS {
            if s.contains("h") || s.contains("m") {
                return parseHMSValue(s)
            } else {
                return parseIntValue(s)
            }
        }
        return Value()
    }
    
    func prepDMSExpr() -> Expr {
        // If the string is emptish, this will create a 0d0'0
        // First add a d symbol, which will add a leading 0
        setDegreeHour()
        // Then add ' symbol, which will add 0 after degree is there's no numbers
        setMinutes()
        // Then add a 0 after the last '
        addEntry("0")
        
        let value = Value(from: String(inputStack))
        return Expr.value(value)
    }
    
    func prepIntExpr() -> Expr {
        let trimmed = inputStack.filter { !$0.isWhitespace }
        return Expr.value(Value(integer: Int(String(trimmed)) ?? 0))
    }
    
    private func debugLog(_ name: String) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(expressions)
            NSLog("JSON for \(name)")
            NSLog(String(data: data, encoding: .utf8)!)
        } catch {
            NSLog("oops")
        }
    }
    
    func startExpr(op: Operator) {
        if inputStack.isEmpty {
            ans()
        }
        if inputStack.isEmpty {
            // No previous answer
            return
        }
        var node: Expr
        switch exprMode {
        case .DMS:
            node = prepDMSExpr()
        case .HMS:
            // node = prepHMSExpr()
            node = Expr()
        }
        
        if var root = expressions.last {
            var newRoot = Expr.binary(op: op, lhs: node, rhs: Expr())
            expressions.removeLast()
            expressions.append(newRoot)
        } else {
            NSLog("expressions has no root?")
        }
        
        debugLog("op \(op.description)")
        
        inputStack = []
    }
    
    func add() {
        startExpr(op: Operator.add)
    }
    
    func subtract() {
        startExpr(op: Operator.subtract)
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
        startExpr(op: Operator.divide)
    }
    
    func minus_360() {
        // Start a subtractions
        startExpr(op: Operator.subtract)
        // and erase whatever was entered and insert 360 degrees
        inputStack = ["3", "6", "0"]
        setDegreeHour()
        return equal()
    }
    
    func equal() {
        // Reenable this in case it was disabled while inputting a number for division
        disableDegreesAndMinutes = false
        debugLog("=")
        inputStack = []
    }
    
    func setDegreeHour() {
        switch exprMode {
        case .DMS:
            if inputStack.contains("'") {
                break
            }
            if inputStack.contains("°") {
                break
            }
            if inputStack.isEmpty {
                inputStack = ["0", "°"] + inputStack
            } else {
                inputStack += "°"
            }
        case .HMS:
            if inputStack.contains("s") {
                break
            }
            if inputStack.contains("m") {
                break
            }
            if inputStack.contains("h") {
                break
            }
            if inputStack.isEmpty {
                inputStack = ["0", "h"] + inputStack
            } else {
                inputStack += "h"
            }
        }
    }
    
    func setMinutes() {
        switch exprMode {
        case .DMS:
            // We already set minutes
            if inputStack.contains("'") {
                break
            }
            // If there's no degrees, insert 0 degrees up front
            if inputStack.contains("°") == false {
                inputStack = ["0", "°"] + inputStack
            }
            // If the last char isn't a number, we're entering "'", so put a 0 up front
            if let c = inputStack.last {
                if c.isNumber == false {
                    inputStack += "0"
                }
            }
            inputStack += "'"
        case .HMS:
            // We already set seconds
            if inputStack.contains("s") {
                break
            }
            // We already set minutes
            if inputStack.contains("m") {
                break
            }
            // If there's no degrees, insert 0 degrees up front
            if inputStack.contains("h") == false {
                inputStack = ["0", "h"] + inputStack
            }
            // If the last char isn't a number, we're entering "'", so put a 0 up front
            if let c = inputStack.last {
                if c.isNumber == false {
                    inputStack += "0"
                }
            }
            inputStack += "m"
        }
    }
    
    func setSeconds(_ entered: String) -> String {
        var entered = entered
        switch exprMode {
        case .DMS:
            break;
        case .HMS:
            // We already set seconds
            if entered.contains("s") {
                break
            }
            // If there's no degrees, insert 0 degrees up front
            if entered.contains("m") == false {
                entered = "0m" + entered
            }
            // If there's no degrees, insert 0 degrees up front
            if entered.contains("h") == false {
                entered = "0h" + entered
            }
            // If the last char isn't a number, we're entering "'", so put a 0 up front
            if let c = entered.last {
                if c.isNumber == false {
                    entered += "0"
                }
            }
            entered += "s"
        }
        return entered
    }
    
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
        if let num = Int(currentNumber) {
            displayStack.append("\(num)")
            expressionStack.append(Expr.value(Value(integer: num)))
            currentNumber = ""
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
        if operatorStack.isEmpty, expressionStack.count == 1 {
            /* "pretty" print the input from the user */
            print("----------------")
            for line in displayStack {
                print("\t\(line)")
            }
            print("----------------")
            print("\t\(expressionStack.last?.evaluate() ?? Value())")
            print("================")
            return expressionStack.last
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
        currentNumber = ""
        for char in backup {
            addEntry(String(char))
        }
    }

}


