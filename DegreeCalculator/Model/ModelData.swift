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

enum CalculatorFunction: Int {
    case ANS
    case ALL_CLEAR
    case CLEAR
    case DELETE
    case ADD
    case SUBTRACT
    case EQUAL
    case ENTRY
    
}

final class ModelData: ObservableObject {
    @Published var entries: [Expr] = [
        // These comments are various test cases I used regularly.
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
    
    // This is the string that is currently being edited. By keeping it as a simple string, we can delete
    // (edit) it by simply removing chars.
    @Published var entered: String = ""

    
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
        case .EQUAL:
            return equal()
        case .ENTRY:
            return addEntry(label)
        }
    }
    
    func allClear() {
        entries = [Expr()]
        entered = ""
    }
    
    func clear() {
        entered = ""
    }
    
    func delete() {
        if entered.isEmpty {
            // FIXME: fix this...
            if let root = entries.last {
                if root.nodes.isEmpty && root.op == nil {
                    return
                }
                let left = root.nodes[0]
                NSLog("left = \(left.description)")
                
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
        // Simple parse by just splitting on ° and '. This work since
        // prepExpr inserts ° and ' and trailing 0.
        let trimmed = entered.trimmingCharacters(in: .whitespaces)
        let dgm = trimmed.split(separator: "°")
        let degrees = Int(dgm[0]) ?? 0
        let mins = dgm[1].split(separator: "'")
        let minutes = Decimal(Int(mins[0]) ?? 0) + (Decimal((Int(mins[1]) ?? 0)) / 10.0)
        return Value(degrees: degrees, minutes: minutes)
    }
    
    private func prepExpr() -> Expr {
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
            NSLog("can't start operator on empty expression")
            return
        }
        let node = prepExpr()
        
        if var root = entries.last {
            if root.op == nil  {
                // Fresh root
                root.op = op
                root.nodes.append(node)
                entries.removeLast()
                entries.append(root)
            } else if root.op != nil && root.nodes.count == 1 {
                // Root has a left side & operator, add right side value and new operator
                root.nodes.append(node)
                let newRoot = Expr(op: op, left: root, right: nil)
                entries.removeLast()
                entries.append(newRoot)
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
    
    func equal() {
        if let root = entries.last {
            if root.nodes.count == 0 {
                return
            }
        }
        let node = prepExpr()
        
        if var root = entries.last {
            if root.op != nil && root.nodes.count == 1 {
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
                entered += "00"
            }
        }
        entered += "'"
    }
}


