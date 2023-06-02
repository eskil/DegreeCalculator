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

final class ModelData: ObservableObject {
    @Published var entries: [Entry] = [Entry(left: Value(degrees: 39, minutes: 15.2),
                                             right: Value(degrees: 1, minutes: 21.9),
                                             op: Operator.Add),
                                       Entry(left: Value(degrees: 40, minutes: 37.1),
                                             right: Value(degrees: 350, minutes: 51.9),
                                             op: Operator.Subtract)]
                                             //" 39°15.2' +", "  1° 6.7' =", " 40°21.9'"]
    @Published var entered: String = ""
    
    func add(_ char: Character) {
        entered += String(char)
    }
    
    func clearAll() {
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
}


