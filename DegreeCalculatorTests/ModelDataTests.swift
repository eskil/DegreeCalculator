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

    // Test behaviour of clear, specifically that inputStack is reset and expressions is unchanged.
    func testClear() throws {
        md.callFunction(CalculatorFunction.CLEAR, label: "")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "")
        
        let expressions = [Expr.value(Value(degrees: 1, minutes: 2.3))]
        md.expressions = expressions
        md.inputStack = "1"
        md.callFunction(CalculatorFunction.CLEAR, label: "")
        XCTAssertEqual(md.expressions, expressions)
        XCTAssertEqual(md.inputStack, "")
    }

    // Test behaviour of all-clear, specifically that inputStack and expressions is reset
    func testAllClear() throws {
        md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "")
        
        let expressions = [Expr.value(Value(degrees: 1, minutes: 2.3))]
        md.expressions = expressions
        md.inputStack = "1"
        md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "")
    }
    
    func testEntyBasic() throws {
        md.inputStack = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "12")
    }
    
    // Test a full and proper 1d2'3 build
    func testEntryFullBuild() throws {
        md.inputStack = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'3")
    }
    
    // Test shortcut building by pressing d and ' without numbers
    func testEntryShortcutDegreesMinutes() throws {
        md.inputStack = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°0'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°0'1")
    }

    // Test shortcut building by pressing ' without numbers or degrees
    func testEntryShortcutMinutes() throws {
        md.inputStack = ""

        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°0'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°0'1")
    }
    
    // Test shortcut building by ' with a > 60 value
    func testEntryShortcutMinutesWhenOver60() throws {
        md.inputStack = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        md.callFunction(CalculatorFunction.ENTRY, label: "8")
        md.callFunction(CalculatorFunction.ENTRY, label: "5")
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°185'")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "0°185'1")
    }

    // Test adding second d and ' at various times is a noop
    func testDoubleDegreeMinuteEntryNoop() throws {
        md.inputStack = ""
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°")

        // Immediate repeated degree
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°")

        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2")

        // Repeated degree later in string that immediate repeat
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2")
        
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'")

        // Immediate repeated minute
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'")

        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'3")
        
        // Repeated minute later in string that immediate repeat
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'3")
        
        // Repeated degree later in string that immediate repeat
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.expressions, [Expr()])
        XCTAssertEqual(md.inputStack, "1°2'3")
    }
    
    func testDelete() {
        md.inputStack = "12"
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, "1")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, "")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, "")
    }
    
    func testDeleteOneExpr() {
        md.inputStack = ""
        md.expressions = [Expr.binary(op: Operator.add, lhs: Expr.value(Value(degrees: 1, minutes: 2.3)), rhs: Expr())]
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, "1°02'3")
        XCTAssertEqual(md.expressions, [Expr.value(Value(degrees: 1, minutes: 2.3))])
    }
    
    func testDeleteTwoExpr() {
        md.inputStack = ""
        md.expressions = [Expr.binary(op: Operator.subtract,
                                  lhs: Expr.binary(op: Operator.add,
                                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
                                  rhs: Expr())]
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, "4°05'6")
        XCTAssertEqual(md.expressions, [Expr.binary(op: Operator.add,
                                                lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                                rhs: Expr())])
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
    
    func testPrepIntExpr() {
        // Parseing 1d as not-DMS yields 0
        md.inputStack = "1°"
        XCTAssertEqual(md.prepIntExpr(), Expr.value(Value(integer: 0)))
        XCTAssertEqual(md.inputStack, "1°")

        md.inputStack = "1"
        XCTAssertEqual(md.prepIntExpr(), Expr.value(Value(integer: 1)))
        XCTAssertEqual(md.inputStack, "1")
    }

    func testPrepDMSExpr() {
        md.inputStack = ""
        XCTAssertEqual(md.prepDMSExpr(), Expr.value(Value(degrees: 0, minutes: 0.0)))
        XCTAssertEqual(md.inputStack, "0°0'0")
        
        md.inputStack = "0"
        XCTAssertEqual(md.prepDMSExpr(), Expr.value(Value(degrees: 0, minutes: 0.0)))
        XCTAssertEqual(md.inputStack, "0°0'0")

        md.inputStack = "1°"
        XCTAssertEqual(md.prepDMSExpr(), Expr.value(Value(degrees: 1, minutes: 0.0)))
        XCTAssertEqual(md.inputStack, "1°0'0")

        md.inputStack = "1°2"
        XCTAssertEqual(md.prepDMSExpr(), Expr.value(Value(degrees: 1, minutes: 2.0)))
        XCTAssertEqual(md.inputStack, "1°2'0")

        md.inputStack = "1°2'"
        XCTAssertEqual(md.prepDMSExpr(), Expr.value(Value(degrees: 1, minutes: 2.0)))
        XCTAssertEqual(md.inputStack, "1°2'0")
        
        md.inputStack = "1°2'3"
        XCTAssertEqual(md.prepDMSExpr(), Expr.value(Value(degrees: 1, minutes: 2.3)))
        XCTAssertEqual(md.inputStack, "1°2'3")
    }

    func testAns() {
        md.inputStack = ""
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, "")
        
        md.expressions = [Expr.binary(op: Operator.add,
                                  lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                  rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
                      Expr()]
        md.callFunction(CalculatorFunction.EQUAL, label: "")
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, "5°07'9")
    }
    
    func testMinus360() {
        md.inputStack = "361°02'3"
        // Check that Minus 360 adds a subtract operation for 360
        md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.expressions, [Expr.binary(op: Operator.subtract,
                                                lhs: Expr.value(Value(degrees: 361, minutes: 2.3)),
                                                rhs: Expr.value(Value(degrees: 360, minutes: 0.0))),
                                    Expr()])
        XCTAssertEqual(md.inputStack, "")
    }

    func testMinus360_resets_operator() {
        md.inputStack = "361°02'3"
        md.callFunction(CalculatorFunction.ADD, label: "")
        // Check that Minus 360 adds a subtract operation for 360
        md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.expressions, [Expr.binary(op: Operator.subtract,
                                             lhs: Expr.value(Value(degrees: 361, minutes: 2.3)),
                                             rhs: Expr.value(Value(degrees: 360, minutes: 0.0))),
                                    Expr()])
        XCTAssertEqual(md.inputStack, "")
    }}
