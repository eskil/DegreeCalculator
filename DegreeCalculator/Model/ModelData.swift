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
        Expr(),
        /*
        Expr(op: Operator.Add,
              left: Expr(Value(degrees: 39, minutes: 15.2)),
              right: Expr(Value(degrees: 1, minutes: 21.9))),
        */
        /*
        Expr(op: Operator.Add,
                       left: Expr(Value(degrees: 39, minutes: 15.2)),
                       right: Expr(op: Operator.Subtract,
                                    left: Expr(Value(degrees: 1, minutes: 21.9)),
                                    right: Expr(op: Operator.Add,
                                                 left: Expr(Value(degrees: 49, minutes: 37.1)),
                                                 right: Expr(Value(degrees: 350, minutes: 51.9))))),
        Expr(op: Operator.Add,
                       left: Expr(op: Operator.Subtract,
                                   left: Expr(op: Operator.Add,
                                               left: Expr(Value(degrees: 39, minutes: 15.2)),
                                               right: Expr(Value(degrees: 1, minutes: 21.9))),
                                   right: Expr(Value(degrees: 49, minutes: 37.1))),
                       right: Expr(Value(degrees: 350, minutes: 51.9)))
         */
    ]
    
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
        entered.removeLast()
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
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(entries)
            NSLog("JSON for op:")
            NSLog(String(data: data, encoding: .utf8)!)
        } catch {
            NSLog("oops")
        }
        
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
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(entries)
            NSLog("JSON for op:")
            NSLog(String(data: data, encoding: .utf8)!)
        } catch {
            NSLog("oops")
        }
        
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
        // TODO: if there's 1 digit only, add a leading 0
        entered += "'"
    }
}


