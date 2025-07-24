//
//  ExprTests.swift
//  DegreeCalculatorTests
//
//  Created by Eskil Olsen on 6/12/23.
//

import XCTest

@testable import DegreeCalculator

final class ExprTests: XCTestCase {
    func testFails() throws {
        XCTAssertEqual(true, false)
    }

    func testOperatorDescription() throws {
        XCTAssertEqual(Operator.add.description, "+")
        XCTAssertEqual(Operator.subtract.description, "-")
        XCTAssertEqual(Operator.divide.description, "/")
    }
    
    func testEmptyExprNoValue() throws {
        let expr = Expr()
        XCTAssertEqual(expr.value, Value())
    }
    
    func testEmptyRightNoValue() throws {
        let lhs = Expr.value(Value(degrees: 1, minutes: 2.3))
        let expr = Expr.binary(op: Operator.add, lhs: lhs, rhs: Expr())
        XCTAssertEqual(expr.value, nil)
        
    }

    func testAddTwoValuesBasicCase() throws {
        let lhs = Expr.value(Value(degrees: 1, minutes: 2.3))
        let rhs = Expr.value(Value(degrees: 4, minutes: 5.6))
        let expected = Value(degrees: 5, minutes: 7.9)
        let expr = Expr.binary(op: Operator.add, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
        XCTAssertEqual(expr.description, "(1°02'3 + 4°05'6)")
    }

    func testAddTwoValuesMinutesOverflow() throws {
        let lhs = Expr.value(Value(degrees: 4, minutes: 30.0))
        let rhs = Expr.value(Value(degrees: 4, minutes: 30.0))
        let expected = Value(degrees: 9, minutes: 0.0)
        let expr = Expr.binary(op: Operator.add, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func testMinutesOverflow() throws {
        let expr = Expr.value(Value(degrees: 0, minutes: 185.0))
        let expected = Value(degrees: 3, minutes: 5.0)
        XCTAssertEqual(expr.value, expected)
    }

    func testSubtractTwoValuesBaseCase() throws {
        let lhs = Expr.value(Value(degrees: 4, minutes: 5.6))
        let rhs = Expr.value(Value(degrees: 1, minutes: 2.3))
        let expected = Value(degrees: 3, minutes: 3.3)
        let expr = Expr.binary(op: Operator.subtract, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testDivideValuesBaseCase() throws {
        let lhs = Expr.value(Value(degrees: 1023, minutes: 6.3))
        let rhs = Expr.value(Value(integer: 3))
        let expected = Value(degrees: 341, minutes: 2.1)
        let expr = Expr.binary(op: Operator.divide, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func testDivideValuesDegreesDivIntoMinutes() throws {
        let lhs = Expr.value(Value(degrees: 9, minutes: 0.0))
        let rhs = Expr.value(Value(integer: 2))
        let expected = Value(degrees: 4, minutes: 30.0)
        let expr = Expr.binary(op: Operator.divide, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func testDivideValuesMinutesDivIntoSeconds() throws {
        let lhs = Expr.value(Value(degrees: 0, minutes: 1.0))
        let rhs = Expr.value(Value(integer: 2))
        let expected = Value(degrees: 0, minutes: 0.5)
        let expr = Expr.binary(op: Operator.divide, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func testDegreesAndMinutesAddOverflow() throws {
        let lhs = Expr.value(Value(degrees: 354, minutes: 54.5))
        let rhs = Expr.value(Value(degrees: 6, minutes: 6.6))
        /*
        Search for NOTE: disable auto overflow subtractions as we add -360 button instead
        let expected = Value(degrees: 1, minutes: 1.1)
        */
        let expected = Value(degrees: 361, minutes: 1.1)
        let expr = Expr.binary(op: Operator.add, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testDegreesAndMinutesSubtractUnderflow() throws {
        let lhs = Expr.value(Value(degrees: 1, minutes: 1.1))
        let rhs = Expr.value(Value(degrees: 6, minutes: 6.6))
        let expected = Value(degrees: 354, minutes: 54.5)
        let expr = Expr.binary(op: Operator.subtract, lhs: lhs, rhs: rhs)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testParenthesis() throws {
        let val123 = Expr.value(Value(degrees: 1, minutes: 2.3))
        let val456 = Expr.value(Value(degrees: 4, minutes: 5.6))
        let val789 = Expr.value(Value(degrees: 7, minutes: 8.9))
        let rightSide = Expr.binary(op: Operator.add, lhs: val123, rhs: Expr.binary(op: Operator.subtract, lhs: val456, rhs: val789))
        XCTAssertEqual(rightSide.value, Value(degrees: 357, minutes: 59.0))
        let leftSide = Expr.binary(op: Operator.subtract, lhs: Expr.binary(op: Operator.add, lhs: val123, rhs: val456), rhs: val789)
        XCTAssertEqual(leftSide.value, Value(degrees: 357, minutes: 59.0))

    }
    
    func testExprDescription() throws {
        let val123 = Expr.value(Value(degrees: 1, minutes: 2.3))
        let val456 = Expr.value(Value(degrees: 4, minutes: 5.6))
        let val789 = Expr.value(Value(degrees: 7, minutes: 8.9))
        let emptyExpr = Expr()
        XCTAssertEqual(emptyExpr.description, "<empty>")
        
        let missingRhsExpr2 = Expr.binary(op: Operator.add, lhs: val123, rhs: Expr())
        XCTAssertEqual(missingRhsExpr2.description, "(1°02'3 + <empty>)")

        let addExpr = Expr.binary(op: Operator.add, lhs: val123, rhs: val456)
        XCTAssertEqual(addExpr.description, "(1°02'3 + 4°05'6)")
        let subExpr = Expr.binary(op: Operator.subtract, lhs: val123, rhs: val456)
        XCTAssertEqual(subExpr.description, "(1°02'3 - 4°05'6)")
        
        let rightSide = Expr.binary(op: Operator.add, lhs: val123, rhs: Expr.binary(op: Operator.subtract, lhs: val456, rhs: val789))
        XCTAssertEqual(rightSide.description, "(1°02'3 + (4°05'6 - 7°08'9))")
        let leftSide = Expr.binary(op: Operator.subtract, lhs: Expr.binary(op: Operator.add, lhs: val123, rhs: val456), rhs: val789)
        XCTAssertEqual(leftSide.description, "((1°02'3 + 4°05'6) - 7°08'9)")
    }
    
    func testInorder() throws {
        let val123 = Expr.value(Value(degrees: 1, minutes: 2.3))
        let val456 = Expr.value(Value(degrees: 4, minutes: 5.6))
        let val789 = Expr.value(Value(degrees: 7, minutes: 8.9))
        let expr = Expr.binary(op: Operator.subtract,
                               lhs: Expr.binary(op: Operator.add,
                                                lhs: val123,
                                                rhs: val456),
                               rhs: val789)
        var result: [String] = []
        expr.inOrder { e in
            switch e {
            case .value(let v):
                NSLog("Value \(v)")
                result.append(v.description)
            case .binary(let op, _, _):
                NSLog("BinOp \(op)")
                result.append(op.description)
            }
        }
        XCTAssertEqual(result, ["1°02'3", "+", "4°05'6", "-", "7°08'9"])
    }

    func testDisplayable() throws {
        let val123 = Expr.value(Value(degrees: 1, minutes: 2.3))
        let val456 = Expr.value(Value(degrees: 4, minutes: 5.6))
        let val789 = Expr.value(Value(degrees: 7, minutes: 8.9))
        let expr = Expr.binary(op: Operator.subtract,
                               lhs: Expr.binary(op: Operator.add,
                                                lhs: val123,
                                                rhs: val456),
                                rhs: val789)
        XCTAssertEqual(expr.multiline, [
            "     1°02'3 +",
            "     4°05'6 -",
            "     7°08'9 =",
            "   357°59'0"
        ])
    }
}
