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
    case DIV
    case M360
    case EQUAL
    // Entry is a single number entered
    case ENTRY
    
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
    @Published var entered: String = ""
    
    // When last operator is divide, disable degrees/minutes input
    @Published var disableDegreesAndMinutes: Bool = false

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
    
    // _ is a Swift syntax to indicate the argument doesn't need to be named when
    // called, ie. addEntry("str") instead of addEntry(string: "str")
    func addEntry(_ string: String) {
        if string == "°" {
            setDegree()
        } else if string == "'" {
            setMinutes()
        } else {
            // If we have a ' and it's the last, we can add a number. But if not, we've already
            // maxed our string
            if entered.contains("'") {
                if let c = entered.last {
                    if c == "'" {
                        entered += string
                    }
                }
            } else {
                entered += string
            }
        }
    }
    
    /**
     Reset the entire state.
     */
    func allClear() {
        entries = [Expr()]
        entered = ""
    }
    
    func clear() {
        // FIXME: if entered is empty it should delete the current expression.
        // Eg. "enter 1d2'3+", pressing clear should remove that.
        entered = ""
    }
    
    func delete() {
        if entered.isEmpty {
            if let root = entries.last {
                if root.nodes.isEmpty && root.op == nil {
                    return
                }
                let left = root.nodes[0]
                
                // Reset the entered string to right.v, left.v or .v in that order of preference.
                if left.nodes.count == 2, let rightv = left.nodes[1].v {
                    entered = rightv.description
                } else if left.nodes.count == 1, let leftv = left.nodes[0].v {
                    entered = leftv.description
                } else if let v = left.v {
                    entered = v.description
                }
                
                var newRoot: Expr
                if left.op == nil {
                    // If left has no op, it's a value, so we're at the first entry of the expression - reset tree.
                    newRoot = Expr()
                    // Reenable this in case it was disabled while inputting a number for division
                    disableDegreesAndMinutes = false
                } else {
                    // Otherwise, left side forms new root, but we go back to the "pre-operator" state
                    newRoot = Expr(op: left.op, left: left.nodes[0], right: nil)
                }
                entries.removeLast()
                entries.append(newRoot)
            }
        } else {
            entered.removeLast()
        }
        debugLog("DEL")
    }
    
    func ans() {
        if entries.count > 1 {
            let last = entries[entries.count-2]
            if let val = last.value {
                entered = val.description
            }
        }
    }
    
    func parseValue(_ s: String) -> Value {
        // Simple parse by just splitting on ° and '. This works since
        // prepExpr(toDMS=true) inserts ° and ' and trailing 0, and when toDMS=false,
        // we get an integer value instead.
        var degrees = 0
        var minutes: Decimal = 0.0
        
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
    
    func prepExpr(toDMS: Bool) -> Expr {
        if (toDMS) {
            // If the string is emptish, this will create a 0d0'0
            // First add a d symbol, which will add a leading 0
            setDegree()
            // Then add ' symbol, which will add 0 after degree is there's no numbers
            setMinutes()
            // Then add a 0 after the last '
            addEntry("0")
            
            let value = parseValue(entered)
            return Expr(value)
        }
        
        let trimmed = entered.trimmingCharacters(in: .whitespaces)
        return Expr(Value(integer: Int(trimmed) ?? 0))
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
        if entered.isEmpty {
            ans()
        }
        if entered.isEmpty {
            // No previous answer
            return
        }
        
        if var root = entries.last {
            let node = prepExpr(toDMS: true)

            if root.op == nil  {
                // Fresh root
                root.op = op
                root.nodes.append(node)
                entries.removeLast()
                entries.append(root)
            } else if root.op != nil && root.nodes.count == 1 {
                // Root has a left side and an operator.
                // Determine operator precedence to determine which side to add it
                if op == Operator.Divide && (root.op == Operator.Add || root.op == Operator.Subtract) {
                    // Inserting a higher precedence, so move current node to the left.
                    let newRoot = Expr(op: op, left: node, right: nil)
                    root.nodes.append(newRoot)
                    entries.removeLast()
                    entries.append(root)
                } else {
                    // Add right side value and new operator
                    root.nodes.append(node)
                    let newRoot = Expr(op: op, left: root, right: nil)
                    entries.removeLast()
                    entries.append(newRoot)
                }
            }
        } else {
            NSLog("entries has no root?")
        }
        
        debugLog("op \(op.description)")
        
        entered = ""
    }
    
    func add() {
        startExpr(op: Operator.Add)
    }

    func subtract() {
        startExpr(op: Operator.Subtract)
    }
    
    func divide() {
        startExpr(op: Operator.Divide)
        disableDegreesAndMinutes = true
    }
    
    func minus_360() {
        // If there's an op, del() so eg. "+" gets removed.
        if let root = entries.last {
            if root.op != nil && root.nodes.count == 1 {
                delete()
            }
        }
        // Start a subtractions
        startExpr(op: Operator.Subtract)
        // and erase whatever was entered and insert 360 degrees
        entered = "360"
        setDegree()
        return equal()
    }
    
    func equal() {
        // Reenable this in case it was disabled while inputting a number for division
        disableDegreesAndMinutes = false

        if let root = entries.last {
            if root.nodes.count == 0 {
                return
            }
        }
        
        if var root = entries.last {
            TODO: root.nodes.count == 1 assumes a right balanced tree
            instead of assuming that and inserting the current Expression
            there, we have to support a tree like (+ 1 2) + (/ 3 <empty>)
            that means walk the tree and find the rightmost open node.
            
            if root.op != nil && root.nodes.count == 1 {
                let node: Expr
                if root.op == Operator.Divide {
                    node = prepExpr(toDMS: false)
                } else {
                    node = prepExpr(toDMS: true)
                }
                // Root has a left side & operator, add right side value and new operator
                root.nodes.append(node)
                entries.removeLast()
                entries.append(root)
                entries.append(Expr())
            }
        } else {
            NSLog("entries has no root?")
        }
        
        debugLog("=")

        entered = ""
    }
    
    func setDegree() {
        if entered.contains("'") {
            return
        }
        if entered.contains("°") {
            return
        }
        if entered.isEmpty {
            entered = "0°" + entered
        } else {
            entered += "°"
        }
    }
    
    func setMinutes() {
        // We already set minutes
        if entered.contains("'") {
            return
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
    }
}


