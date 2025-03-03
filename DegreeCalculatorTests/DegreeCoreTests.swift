//
//  DegreeCoreTests.swift
//  DegreeCalculatorTests
//
//  Created by Eskil Olsen on 6/12/23.
//

import XCTest

@testable import DegreeCalculator

final class DegreeCoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testOperator() throws {
        XCTAssertEqual(Operator.Add.description, "+")
        XCTAssertEqual(Operator.Subtract.description, "-")
    }
    
    func testEmptyValue() throws {
        let v = Value()
        XCTAssertEqual(v.degrees, 0)
        XCTAssertEqual(v.minutes, 0.0)
        XCTAssertEqual(v.description, "0°00'0")
    }
   
    func testNonEmptyValue() throws {
        let v = Value(degrees: 1, minutes: 2.3)
        XCTAssertEqual(v.degrees, 1)
        XCTAssertEqual(v.minutes, 2.3)
        XCTAssertEqual(v.description, "1°02'3")
    }
    
    func testEmptyExpr_NoValue() throws {
        let expr = Expr()
        XCTAssertEqual(expr.value, nil)
    }
    
    func testEmptyOp_NoValue() throws {
        let lhs = Expr(Value(degrees: 1, minutes: 2.3))
        let rhs = Expr(Value(degrees: 4, minutes: 5.6))
        let expr = Expr(op: nil, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, nil)
    }
    
    func testEmptyRight_NoValue() throws {
        let lhs = Expr(Value(degrees: 1, minutes: 2.3))
        let expr = Expr(op: Operator.Add, left: lhs, right: nil)
        XCTAssertEqual(expr.value, nil)
        XCTAssertEqual(expr.description, "( 1°02'3 + <empty> )")
        
    }

    func testAddTwoValues_1() throws {
        let lhs = Expr(Value(degrees: 1, minutes: 2.3))
        let rhs = Expr(Value(degrees: 4, minutes: 5.6))
        let expected = Value(degrees: 5, minutes: 7.9)
        let expr = Expr(op: Operator.Add, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func testAddTwoValues_minutes_overflow() throws {
        let lhs = Expr(Value(degrees: 4, minutes: 30.0))
        let rhs = Expr(Value(degrees: 4, minutes: 30.0))
        let expected = Value(degrees: 9, minutes: 0.0)
        let expr = Expr(op: Operator.Add, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func test_minutes_overflow() throws {
        let expr = Expr(Value(degrees: 0, minutes: 185.0))
        let expected = Value(degrees: 3, minutes: 5.0)
        XCTAssertEqual(expr.value, expected)
    }

    func testSubtractTwoValues() throws {
        let lhs = Expr(Value(degrees: 4, minutes: 5.6))
        let rhs = Expr(Value(degrees: 1, minutes: 2.3))
        let expected = Value(degrees: 3, minutes: 3.3)
        let expr = Expr(op: Operator.Subtract, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testDivideValues_base_case() throws {
        let lhs = Expr(Value(degrees: 1023, minutes: 6.3))
        let rhs = Expr(Value(integer: 3))
        let expected = Value(degrees: 341, minutes: 2.1)
        let expr = Expr(op: Operator.Divide, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testDivideValues_degrees_divvy_into_minutes() throws {
        let lhs = Expr(Value(degrees: 9, minutes: 0.0))
        let rhs = Expr(Value(integer: 2))
        let expected = Value(degrees: 4, minutes: 30.0)
        let expr = Expr(op: Operator.Divide, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, expected)
    }

    func testDegreesAndMinutesOverflow() throws {
        let lhs = Expr(Value(degrees: 354, minutes: 54.5))
        let rhs = Expr(Value(degrees: 6, minutes: 6.6))
        let expr = Expr(op: Operator.Add, left: lhs, right: rhs)
        /*
         Search for NOTE: disable auto overflow subtractions as we add -360 button instead

        let expected = Value(degrees: 1, minutes: 1.1)
        XCTAssertEqual(expr.value, expected)
        */
        let expected = Value(degrees: 361, minutes: 1.1)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testDegreesAndMinutesUnderflow() throws {
        let lhs = Expr(Value(degrees: 1, minutes: 1.1))
        let rhs = Expr(Value(degrees: 6, minutes: 6.6))
        let expected = Value(degrees: 354, minutes: 54.5)
        let expr = Expr(op: Operator.Subtract, left: lhs, right: rhs)
        XCTAssertEqual(expr.value, expected)
    }
    
    func testParenthesis() throws {
        let val123 = Expr(Value(degrees: 1, minutes: 2.3))
        let val456 = Expr(Value(degrees: 4, minutes: 5.6))
        let val789 = Expr(Value(degrees: 7, minutes: 8.9))
        let rightSide = Expr(op: Operator.Add, left: val123, right: Expr(op: Operator.Subtract, left: val456, right: val789))
        XCTAssertEqual(rightSide.value, Value(degrees: 357, minutes: 59.0))
        let leftSide = Expr(op: Operator.Subtract, left: Expr(op: Operator.Add, left: val123, right: val456), right: val789)
        XCTAssertEqual(leftSide.value, Value(degrees: 357, minutes: 59.0))

    }
    
    func testExprDescription() throws {
        let val123 = Expr(Value(degrees: 1, minutes: 2.3))
        let val456 = Expr(Value(degrees: 4, minutes: 5.6))
        let val789 = Expr(Value(degrees: 7, minutes: 8.9))
        let emptyExpr = Expr()
        XCTAssertEqual(emptyExpr.description, "<empty> <noop> <empty>")

        let missingOpExpr = Expr(op: nil, left: val123, right: val456)
        XCTAssertEqual(missingOpExpr.description, "( 1°02'3 <noop> 4°05'6 )")
        
        let missingRhsExpr1 = Expr(op: Operator.Add, left: val123)
        XCTAssertEqual(missingRhsExpr1.description, "( 1°02'3 + <empty> )")
        let missingRhsExpr2 = Expr(op: Operator.Add, left: val123, right: nil)
        XCTAssertEqual(missingRhsExpr2.description, "( 1°02'3 + <empty> )")

        let addExpr = Expr(op: Operator.Add, left: val123, right: val456)
        XCTAssertEqual(addExpr.description, "( 1°02'3 + 4°05'6 )")
        let subExpr = Expr(op: Operator.Subtract, left: val123, right: val456)
        XCTAssertEqual(subExpr.description, "( 1°02'3 - 4°05'6 )")
        
        let rightSide = Expr(op: Operator.Add, left: val123, right: Expr(op: Operator.Subtract, left: val456, right: val789))
        XCTAssertEqual(rightSide.description, "( 1°02'3 + ( 4°05'6 - 7°08'9 ) )")
        let leftSide = Expr(op: Operator.Subtract, left: Expr(op: Operator.Add, left: val123, right: val456), right: val789)
        XCTAssertEqual(leftSide.description, "( ( 1°02'3 + 4°05'6 ) - 7°08'9 )")
    }
}
