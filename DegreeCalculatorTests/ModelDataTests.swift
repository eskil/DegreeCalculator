//
//  ModelDataTests.swift
//  DegreeCalculatorTests
//
//  Created by Eskil Olsen on 6/13/23.
//

import XCTest

@testable import DegreeCalculator

final class ModelDataTests: XCTestCase {
    var md: ModelData! = nil

    override func setUp() {
        md = ModelData()
    }

    override func tearDown() {
        md = nil
    }

    // Test behaviour of clear, specifically that entered is reset and entries is unchanged.
    func testClear() throws {
        md.callFunction(CalculatorFunction.CLEAR, label: "")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "")
        
        let entries = [Expr(Value(degrees: 1, minutes: 2.3))]
        md.entries = entries
        md.entered = "1"
        md.callFunction(CalculatorFunction.CLEAR, label: "")
        XCTAssertEqual(md.entries, entries)
        XCTAssertEqual(md.entered, "")
    }

    // Test behaviour of all-clear, specifically that entered and entries is reset
    func testAllClear() throws {
        md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "")
        
        let entries = [Expr(Value(degrees: 1, minutes: 2.3))]
        md.entries = entries
        md.entered = "1"
        md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "")
    }
    
    func testEntyBasic() throws {
        md.entered = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "12")
    }
    
    // Test a full and proper 1d2'3 build
    func testEntryFullBuild() throws {
        md.entered = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'3")
    }
    
    // Test shortcut building by pressing d and ' without numbers
    func testEntryShortcutDegreesMinutes() throws {
        md.entered = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "0°")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "0°0'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "0°0'1")
    }

    // Test shortcut building by pressing ' without numbers or degrees
    func testEntryShortcutMinutes() throws {
        md.entered = ""

        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "0°0'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "0°0'1")
    }
    
    // Test adding second d and ' at various times is a noop
    func testDoubleDegreeMinuteEntryNoop() throws {
        md.entered = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°")

        // Immediate repeated degree
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°")

        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2")

        // Repeated degree later in string that immediate repeat
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'")

        // Immediate repeated minute
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'")

        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'3")
        
        // Repeated minute later in string that immediate repeat
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'3")
        
        // Repeated degree later in string that immediate repeat
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.entries, [Expr()])
        XCTAssertEqual(md.entered, "1°2'3")
    }
    
    func testDelete() {
        md.entered = "12"
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.entered, "1")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.entered, "")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.entered, "")
    }
    
    func testDeleteOneExpr() {
        md.entered = ""
        md.entries = [Expr(op: Operator.Add, left: Expr(Value(degrees: 1, minutes: 2.3)))]
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.entered, "1°02'3")
        XCTAssertEqual(md.entries, [Expr(op: nil, left: Expr(Value(degrees: 1, minutes: 2.3)))])
    }
    
    func testDeleteTwoExpr() {
        md.entered = ""
        md.entries = [Expr(op: Operator.Subtract,
                           left: Expr(op: Operator.Add,
                                      left: Expr(Value(degrees: 1, minutes: 2.3)),
                                      right: Expr(Value(degrees: 4, minutes: 5.6))))]
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.entered, "4°05'6")
        XCTAssertEqual(md.entries, [Expr(op: Operator.Add,
                                         left: Expr(Value(degrees: 1, minutes: 2.3)))])
    }
    
    func testParseValue() {
        XCTAssertEqual(md.parseValue("1°2'3"), Value(degrees: 1, minutes: 2.3))
        XCTAssertEqual(md.parseValue("1°2"), Value(degrees: 1, minutes: 2.0))
        XCTAssertEqual(md.parseValue("1°"), Value(degrees: 1, minutes: 0))
        XCTAssertEqual(md.parseValue("°"), Value(degrees: 0, minutes: 0))
        XCTAssertEqual(md.parseValue("°'"), Value(degrees: 0, minutes: 0))
        XCTAssertEqual(md.parseValue(""), Value(degrees: 0, minutes: 0))
        XCTAssertEqual(md.parseValue("a°"), Value(degrees: 0, minutes: 0))
        XCTAssertEqual(md.parseValue("a°b'c"), Value(degrees: 0, minutes: 0))
        XCTAssertEqual(md.parseValue("a°b'"), Value(degrees: 0, minutes: 0))
    }
    
    func testPrepExpr() {
        md.entered = ""
        XCTAssertEqual(md.prepExpr(toDMS: true), Expr(Value(degrees: 0, minutes: 0.0)))
        XCTAssertEqual(md.entered, "0°0'0")
        
        md.entered = "0"
        XCTAssertEqual(md.prepExpr(toDMS: true), Expr(Value(degrees: 0, minutes: 0.0)))
        XCTAssertEqual(md.entered, "0°0'0")

        md.entered = "0"
        XCTAssertEqual(md.prepExpr(toDMS: false), Expr(Value(integer: 0)))
        XCTAssertEqual(md.entered, "0")

        md.entered = "1°"
        XCTAssertEqual(md.prepExpr(toDMS: true), Expr(Value(degrees: 1, minutes: 0.0)))
        XCTAssertEqual(md.entered, "1°0'0")

        // Parseing 1d as not-DMS yields 0
        md.entered = "1°"
        XCTAssertEqual(md.prepExpr(toDMS: false), Expr(Value(integer: 0)))
        XCTAssertEqual(md.entered, "1°")

        md.entered = "1"
        XCTAssertEqual(md.prepExpr(toDMS: false), Expr(Value(integer: 1)))
        XCTAssertEqual(md.entered, "1")

        md.entered = "1°2"
        XCTAssertEqual(md.prepExpr(toDMS: true), Expr(Value(degrees: 1, minutes: 2.0)))
        XCTAssertEqual(md.entered, "1°2'0")

        md.entered = "1°2'"
        XCTAssertEqual(md.prepExpr(toDMS: true), Expr(Value(degrees: 1, minutes: 2.0)))
        XCTAssertEqual(md.entered, "1°2'0")
        
        md.entered = "1°2'3"
        XCTAssertEqual(md.prepExpr(toDMS: true), Expr(Value(degrees: 1, minutes: 2.3)))
        XCTAssertEqual(md.entered, "1°2'3")
    }
    
    func testAns() {
        md.entered = ""
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.entered, "")
        
        md.entries = [Expr(op: Operator.Add,
                           left: Expr(Value(degrees: 1, minutes: 2.3)),
                           right: Expr(Value(degrees: 4, minutes: 5.6))),
                      Expr()]
        md.callFunction(CalculatorFunction.EQUAL, label: "")
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.entered, "5°07'9")
    }
    
    func testMinus360() {
        md.entered = "361°02'3"
        // Check that Minus 360 adds a subtract operation for 360
        md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.entries, [Expr(op: Operator.Subtract,
                                             left: Expr(Value(degrees: 361, minutes: 2.3)),
                                             right: Expr(Value(degrees: 360, minutes: 0.0))),
                                    Expr()])
        XCTAssertEqual(md.entered, "")
    }

    func testMinus360_resets_operator() {
        md.entered = "361°02'3"
        md.callFunction(CalculatorFunction.ADD, label: "")
        // Check that Minus 360 adds a subtract operation for 360
        md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.entries, [Expr(op: Operator.Subtract,
                                             left: Expr(Value(degrees: 361, minutes: 2.3)),
                                             right: Expr(Value(degrees: 360, minutes: 0.0))),
                                    Expr()])
        XCTAssertEqual(md.entered, "")
    }
    
    func testDivide_add_add_add_left_sided_tree() {
        md.entered = "1"
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.entered = "2"
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.entered = "3"
        md.callFunction(CalculatorFunction.ADD, label: "")
        XCTAssertEqual(md.entries, [Expr(op: Operator.Add,
                                         left: Expr(op: Operator.Add,
                                                    left: Expr(op: Operator.Add,
                                                               left: Expr(Value(degrees: 1, minutes: 0.0)),
                                                               right: Expr(Value(degrees: 2, minutes: 0.0))
                                                              ),
                                                    right: Expr(Value(degrees: 3, minutes: 0.0))))])
        XCTAssertEqual(md.entries.last?.description, "(((1°00'0+2°00'0)+3°00'0)+<empty>)")
        XCTAssertEqual(md.entered, "")
    }
    
    /*
    func testDivide_wrong_add_add_divide_left_sided_tree() {
        md.entered = "1"
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.entered = "2"
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.entered = "3"
        md.callFunction(CalculatorFunction.DIV, label: "")
        XCTAssertEqual(md.entries, [Expr(op: Operator.Divide,
                                         left: Expr(op: Operator.Add,
                                                    left: Expr(op: Operator.Add,
                                                               left: Expr(Value(degrees: 1, minutes: 0.0)),
                                                               right: Expr(Value(degrees: 2, minutes: 0.0))
                                                              ),
                                                    right: Expr(Value(degrees: 3, minutes: 0))))
        ])
        XCTAssertEqual(md.entered, "")
    }
    */
    
    func testDivide_right_add_add_divide() {
        md.entered = "1"
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.entered = "2"
        md.callFunction(CalculatorFunction.ADD, label: "")
        md.entered = "3"
        md.callFunction(CalculatorFunction.DIV, label: "")
        XCTAssertEqual(md.entries, [Expr(op: Operator.Add,
                                         left: Expr(op: Operator.Add,
                                                    left: Expr(Value(degrees: 1, minutes: 0.0)),
                                                    right: Expr(Value(degrees: 2, minutes: 0.0))
                                                   ),
                                         right: Expr(op: Operator.Divide,
                                                     left: Expr(Value(degrees: 3, minutes: 0.0))
                                                    ))
        ])
        XCTAssertEqual(md.entries.last?.description, "((1°00'0+2°00'0)+(3°00'0/<empty>))")
        XCTAssertEqual(md.entered, "")
    }
}
