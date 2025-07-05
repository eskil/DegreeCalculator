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

    /**
     Entries is the list of expressions.
     
     Each time EQUAL is executed, the current expression is computed (via value)
     and a new expression is started.
     So in short, this stores all expressions computer until a allClear is issued.
     */
    @Published var entries: [Expr] = [
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
     This is the string that is currently being edited. By keeping it as a simple string, we can delete
     (edit) it by simply removing chars.
     */
    @Published var inputStack: String = ""
    
    // When last operator is divide, disable degrees/minutes input
    @Published var disableDegreesAndMinutes: Bool = false

    // Entering DMS or HMS
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
    }
    
    /**
     Reset the entire state.
     */
    func allClear() {
        entries = [Expr()]
        disableDegreesAndMinutes = false
        inputStack = ""
    }
    
    func clear() {
        // FIXME: if inputStack is empty it should delete the current expression.
        // Eg. "enter 1d2'3+", pressing clear should remove that.
        inputStack = ""
    }
    
    func delete() {
        debugLog("DEL")
    }
    
    func ans() {
        if entries.count > 1 {
            let last = entries[entries.count-2]
            if let val = last.value {
                inputStack = val.description
            }
        }
    }
    
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
    
    func parseHMSValue(_ s: String) -> Value {
        return Value()
    }

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
        inputStack = setDegreeHour(inputStack)
        // Then add ' symbol, which will add 0 after degree is there's no numbers
        inputStack = setMinutes(inputStack)
        // Then add a 0 after the last '
        addEntry("0")

        let value = parseValue(inputStack)
        return Expr.value(value)
    }
    
    func prepIntExpr() -> Expr {
        let trimmed = inputStack.trimmingCharacters(in: .whitespaces)
        return Expr.value(Value(integer: Int(trimmed) ?? 0))
    }
    
    private func debugLog(_ name: String) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(entries)
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
        
        if var root = entries.last {
            var newRoot = Expr.binary(op: op, lhs: node, rhs: Expr())
            entries.removeLast()
            entries.append(newRoot)
        } else {
            NSLog("entries has no root?")
        }
        
        debugLog("op \(op.description)")
        
        inputStack = ""
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
        inputStack = "360"
        inputStack = setDegreeHour(inputStack)
        return equal()
    }
    
    func equal() {
        // Reenable this in case it was disabled while inputting a number for division
        disableDegreesAndMinutes = false
        
        debugLog("=")

        inputStack = ""
    }
    
    func setDegreeHour(_ entered :String) -> String {
        var entered = entered
        switch exprMode {
        case .DMS:
            if entered.contains("'") {
                break
            }
            if entered.contains("°") {
                break
            }
            if inputStack.isEmpty {
                entered = "0°" + inputStack
            } else {
                entered += "°"
            }
        case .HMS:
            if entered.contains("s") {
                break
            }
            if entered.contains("m") {
                break
            }
            if entered.contains("h") {
                break
            }
            if entered.isEmpty {
                entered = "0h" + entered
            } else {
                entered += "h"
            }
        }
        return entered
    }
    
    func setMinutes(_ entered: String) -> String {
        var entered = entered
        switch exprMode {
        case .DMS:
            // We already set minutes
            if entered.contains("'") {
                break
            }
            // If there's no degrees, insert 0 degrees up front
            if entered.contains("°") == false {
                entered = "0°" + entered
            }
            // If the last char isn't a number, we're entering "'", so put a 0 up front
            if let c = entered.last {
                if c.isNumber == false {
                    entered += "0"
                }
            }
            entered += "'"
        case .HMS:
            // We already set seconds
            if entered.contains("s") {
                break
            }
            // We already set minutes
            if entered.contains("m") {
                break
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
            entered += "m"
        }
        return entered
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

}


