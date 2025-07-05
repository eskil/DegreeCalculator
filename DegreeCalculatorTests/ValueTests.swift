//
//  Untitled.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/4/25.
//

import XCTest

@testable import DegreeCalculator

final class ValueBaseAndIntTests: XCTestCase {
    
    func testEmptyValue() throws {
        let v = Value()
        XCTAssert(v.type == .empty)
    }

    func testValue() throws {
        let v = Value(integer: 2)
        switch v.type {
        case .integer(let i):
            XCTAssertEqual(i, 2)
            XCTAssertEqual(v.description, "2")
        default:
            XCTFail("Expected .integer kind")
        }
    }
    
    func testAdding() throws {
        let lhs = Value(integer: 1)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 3)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testSubtracting() throws {
        let lhs = Value(integer: 3)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 1)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }

    func testDividing() throws {
        let lhs = Value(integer: 8)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 4)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
    
    func testDividingOdd() throws {
        let lhs = Value(integer: 9)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 4)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
}

final class ValueDMSTests: XCTestCase {
    
    func testValue() throws {
        let v = Value(degrees: 1, minutes: 2.3)
        switch v.type {
        case .dms(let d, let m):
            XCTAssertEqual(d, 1)
            XCTAssertEqual(m, 2.3)
            XCTAssertEqual(v.description, "1°02'3")
        default:
            XCTFail("Expected .dms kind")
        }
        
    }
    
    func testNormalise() throws {
        XCTAssertEqual(Value(degrees: 0, minutes: 61).normalise(), Value(degrees: 1, minutes: 1))
        XCTAssertEqual(Value(degrees: 1, minutes: -1).normalise(), Value(degrees: 0, minutes: 59))
    }
    
    func testAdding() throws {
        let lhs = Value(degrees: 1, minutes: 2.3)
        let rhs = Value(degrees: 2, minutes: 3.4)
        let expected = Value(degrees: 3, minutes: 5.7)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testAddingOverflow() throws {
        let lhs = Value(degrees: 359, minutes: 59.9)
        let rhs = Value(degrees: 1, minutes: 1.2)
        let expected = Value(degrees: 361, minutes: 1.1)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testSubtracting() throws {
        let lhs = Value(degrees: 2, minutes: 3.4)
        let rhs = Value(degrees: 1, minutes: 2.3)
        let expected = Value(degrees: 1, minutes: 1.1)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testSubtractingUnderflow() throws {
        let lhs = Value(degrees: 1, minutes: 2.3)
        let rhs = Value(degrees: 2, minutes: 3.4)
        let expected = Value(degrees: 358, minutes: 58.9)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testDividing() throws {
        let lhs = Value(degrees: 9, minutes: 30.4)
        let rhs = Value(integer: 2)
        let expected = Value(degrees: 4, minutes: 45.2)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
}

final class ValueHMSTests: XCTestCase {
    
    func testValue() throws {
        let v = Value(hours: 1, minutes: 2, seconds: 3)
        switch v.type {
        case .hms(let h, let m, let s):
            XCTAssertEqual(h, 1)
            XCTAssertEqual(m, 2)
            XCTAssertEqual(s, 3)
            XCTAssertEqual(v.description, "1h02m03s")
        default:
            XCTFail("Expected .hms kind")
        }
        
    }
    
    func testNormalise() throws {
        XCTAssertEqual(Value(hours: 0, minutes: 60, seconds: 61).normalise(), Value(hours: 1, minutes: 1, seconds: 1))
        XCTAssertEqual(Value(hours: 1, minutes: -1, seconds: -1).normalise(), Value(hours: 0, minutes: 58, seconds: 59))
    }
    
    func testAdding() throws {
        let lhs = Value(hours: 1, minutes: 2, seconds: 3)
        let rhs = Value(hours: 2, minutes: 3, seconds: 4)
        let expected = Value(hours: 3, minutes: 5, seconds: 7)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testAddingOverflow() throws {
        let lhs = Value(hours: 359, minutes: 59, seconds: 59)
        let rhs = Value(hours: 1, minutes: 1, seconds: 2)
        let expected = Value(hours: 361, minutes: 1, seconds: 1)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testSubtracting() throws {
        let lhs = Value(hours: 2, minutes: 3, seconds: 4)
        let rhs = Value(hours: 1, minutes: 2, seconds: 3)
        let expected = Value(hours: 1, minutes: 1, seconds: 1)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testSubtractingUnderflow() throws {
        let lhs = Value(hours: 1, minutes: 2, seconds: 3)
        let rhs = Value(hours: 2, minutes: 3, seconds: 4)
        let expected = Value(hours: -2, minutes: 58, seconds: 59)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testDividing() throws {
        let lhs = Value(hours: 9, minutes: 30, seconds: 4)
        let rhs = Value(integer: 2)
        let expected = Value(hours: 4, minutes: 45, seconds: 2)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
}

