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
    @Published var entries: [Entry] = [
        Entry(op: Operator.Add,
              left: Entry(Value(degrees: 39, minutes: 15.2)),
              right: Entry(Value(degrees: 1, minutes: 21.9))),
        Entry(op: Operator.Add,
                       left: Entry(Value(degrees: 39, minutes: 15.2)),
                       right: Entry(op: Operator.Subtract,
                                    left: Entry(Value(degrees: 1, minutes: 21.9)),
                                    right: Entry(op: Operator.Add,
                                                 left: Entry(Value(degrees: 49, minutes: 37.1)),
                                                 right: Entry(Value(degrees: 350, minutes: 51.9))))),
        Entry(op: Operator.Add,
                       left: Entry(op: Operator.Subtract,
                                   left: Entry(op: Operator.Add,
                                               left: Entry(Value(degrees: 39, minutes: 15.2)),
                                               right: Entry(Value(degrees: 1, minutes: 21.9))),
                                   right: Entry(Value(degrees: 49, minutes: 37.1))),
                       right: Entry(Value(degrees: 350, minutes: 51.9)))
    ]
                                             //" 39°15.2' +", "  1° 6.7' =", " 40°21.9'"]
    @Published var entered: String = ""
    @Published var value: Value?
    @Published var entry: Entry?

    func addEntry(_ string: String) {
        if string == "°" {
            return setDegree()
        } else if string == "." {
            return setFraction()
        } else {
            entered += string
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
        entries = []
        entered = ""
    }
    
    func clear() {
        entered = ""
    }
    
    func delete() {
        entered.removeLast()
    }
    
    func ans() {
        if let last = entries.last {
            if let val = last.value {
                entered = val.description
            }
        }
    }
    
    func startExpr(op: Operator) {
        if let value = value {
            if entry == nil {
                entry = Entry(op: op, left: Entry(value), right: nil)
            }
        } else {
            NSLog("No value on left side")
        }

    }
    
    func add() {
        startExpr(op: Operator.Add)
    }

    func subtract() {
        startExpr(op: Operator.Subtract)
    }
    
    func equal() {
        entered += "="
    }
    
    func setDegree() {
        if entered.contains("°") {
            return
        }
        if entered.contains(".") {
            return
        }
    }
    
    func setFraction() {
        
    }
}


