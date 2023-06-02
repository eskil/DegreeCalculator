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
    @Published var entries: [Entry] = [Entry(left: Value(degrees: 39, minutes: 15.2),
                                             right: Value(degrees: 1, minutes: 21.9),
                                             op: Operator.Add),
                                       Entry(left: Value(degrees: 40, minutes: 37.1),
                                             right: Value(degrees: 350, minutes: 51.9),
                                             op: Operator.Subtract)]
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
    
    func add() {
        if value == nil {
            return
        }
        if entry == nil {
            entry = Entry(left: value, op: Operator.Add)
        } else {
            
        }
    }

    func subtract() {
        if value == nil {
            return
        }
        if entry == nil {
            entry = Entry(left: value, op: Operator.Subtract)
        } else {
            
        }
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


