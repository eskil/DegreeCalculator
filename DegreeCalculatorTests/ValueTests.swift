//
//  Untitled.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 7/4/25.
//

import XCTest

@testable import DegreeCalculator

final class ValueBaseAndIntTests: XCTestCase {
    func testValueFails() throws {
        XCTAssertEqual(true, false)
    }

    func testInit_IsEmptyValue() throws {
        let v = Value()
        XCTAssert(v.type == .empty)
    }

    func testInt_Init() throws {
        let v = Value(integer: 2)
        switch v.type {
        case .integer(let i):
            XCTAssertEqual(i, 2)
            XCTAssertEqual(v.description, "2")
        default:
            XCTFail("Expected .integer kind")
        }
    }
    
    func testInt_Parsing() throws {
        if let v = Value(parsing: "23", hint: .integer) {
            switch v.type {
            case .integer(let i):
                XCTAssertEqual(i, 23)
                XCTAssertEqual(v.description, "23")
            default:
                XCTFail("Expected .integer kind")
            }
        } else {
            XCTFail("Expected to parse .integer kind")
        }
    }

    func testInt_Addding() throws {
        let lhs = Value(integer: 1)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 3)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testInt_Subtracting() throws {
        let lhs = Value(integer: 3)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 1)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }

    func testInt_Dividing() throws {
        let lhs = Value(integer: 8)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 4)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
    
    func testInt_DividingOdd() throws {
        let lhs = Value(integer: 9)
        let rhs = Value(integer: 2)
        let expected = Value(integer: 4)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
}

final class ValueDMSTests: XCTestCase {
    func testDMS_Init() throws {
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
    
    func testDMS_ParsingComplete() throws {
        if let v = Value(parsing: "123°45'6") {
            switch v.type {
            case .dms(let d, let m):
                XCTAssertEqual(d, 123)
            XCTAssertEqual(m, 45.6)
                XCTAssertEqual(v.description, "123°45'6")
            default:
                XCTFail("Expected .dms kind")
            }
        } else {
            XCTFail("Expected to parse .dms kind")
        }
    }
    
    func testDMS_ParsingIncomplete() throws {
        if let v = Value(parsing: "°45'6", hint: .detect) {
            switch v.type {
            case .dms(let d, let m):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 45.6)
                XCTAssertEqual(v.description, "0°45'6")
            default:
                XCTFail("Expected .dms kind")
            }
        } else {
            XCTFail("Expected to parse .dms kind")
        }
        if let v = Value(parsing: "45'6", hint: .detect) {
            switch v.type {
            case .dms(let d, let m):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 45.6)
                XCTAssertEqual(v.description, "0°45'6")
            default:
                XCTFail("Expected .dms kind")
            }
        } else {
            XCTFail("Expected to parse .dms kind")
        }
        if let v = Value(parsing: "'6", hint: .detect) {
            switch v.type {
            case .dms(let d, let m):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 0.6)
                XCTAssertEqual(v.description, "0°00'6")
            default:
                XCTFail("Expected .dms kind")
            }
        } else {
            XCTFail("Expected to parse .dms kind")
        }
        if let v = Value(parsing: "5", hint: .dms) {
            switch v.type {
            case .dms(let d, let m):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 5.0)
                XCTAssertEqual(v.description, "0°05'0")
            default:
                XCTFail("Expected .dms kind")
            }
        } else {
            XCTFail("Expected to parse .dms kind")
        }
    }

    func testDMS_Normalise() throws {
        XCTAssertEqual(Value(degrees: 0, minutes: 61).normalised(), Value(degrees: 1, minutes: 1))
        XCTAssertEqual(Value(degrees: 0, minutes: 60).normalised(), Value(degrees: 1, minutes: 0))
        XCTAssertEqual(Value(degrees: 1, minutes: -1).normalised(), Value(degrees: 0, minutes: 59))
    }
    
    func testDMS_Adding() throws {
        let lhs = Value(degrees: 1, minutes: 2.3)
        let rhs = Value(degrees: 2, minutes: 3.4)
        let expected = Value(degrees: 3, minutes: 5.7)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testDMS_AddingOverflow() throws {
        let lhs = Value(degrees: 359, minutes: 59.9)
        let rhs = Value(degrees: 1, minutes: 1.2)
        let expected = Value(degrees: 361, minutes: 1.1)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testDMS_Subtracting() throws {
        let lhs = Value(degrees: 2, minutes: 3.4)
        let rhs = Value(degrees: 1, minutes: 2.3)
        let expected = Value(degrees: 1, minutes: 1.1)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testDMS_SubtractingUnderflow() throws {
        let lhs = Value(degrees: 1, minutes: 2.3)
        let rhs = Value(degrees: 2, minutes: 3.4)
        let expected = Value(degrees: 358, minutes: 58.9)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testDMS_Dividing() throws {
        let lhs = Value(degrees: 9, minutes: 30.4)
        let rhs = Value(integer: 2)
        let expected = Value(degrees: 4, minutes: 45.2)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
}

final class ValueHMSTests: XCTestCase {
    func testHMS_Init() throws {
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
    
    func testHMS_ParsingComplete() throws {
        if let v = Value(parsing: "12h34m56s") {
            switch v.type {
            case .hms(let d, let m, let s):
                XCTAssertEqual(d, 12)
                XCTAssertEqual(m, 34)
                XCTAssertEqual(s, 56)
                XCTAssertEqual(v.description, "12h34m56s")
            default:
                XCTFail("Expected .hms kind")
            }
        } else {
            XCTFail("Expected to parse .hms kind")
        }
    }
    
    func testHMS_ParsingIncomplete() throws {
        if let v = Value(parsing: "h45m6", hint: .detect) {
            switch v.type {
            case .hms(let d, let m, let s):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 45)
                XCTAssertEqual(s, 6)
                XCTAssertEqual(v.description, "0h45m06s")
            default:
                XCTFail("Expected .hms kind")
            }
        } else {
            XCTFail("Expected to parse .hms kind")
        }
        if let v = Value(parsing: "45m6", hint: .detect) {
            switch v.type {
            case .hms(let d, let m, let s):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 45)
                XCTAssertEqual(s, 6)
                XCTAssertEqual(v.description, "0h45m06s")
            default:
                XCTFail("Expected .hms kind")
            }
        } else {
            XCTFail("Expected to parse .hms kind")
        }
        if let v = Value(parsing: "m6", hint: .detect) {
            switch v.type {
            case .hms(let d, let m, let s):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 0)
                XCTAssertEqual(s, 6)
                XCTAssertEqual(v.description, "0h00m06s")
            default:
                XCTFail("Expected .hms kind")
            }
        } else {
            XCTFail("Expected to parse .hms kind")
        }
        if let v = Value(parsing: "45", hint: .hms) {
            switch v.type {
            case .hms(let d, let m, let s):
                XCTAssertEqual(d, 0)
                XCTAssertEqual(m, 0)
                XCTAssertEqual(s, 45)
                XCTAssertEqual(v.description, "0h00m45s")
            default:
                XCTFail("Expected .hms kind")
            }
        } else {
            XCTFail("Expected to parse .hms kind")
        }
    }
    
    func testHMS_Normalise() throws {
        XCTAssertEqual(Value(hours: 0, minutes: 60, seconds: 61).normalised(), Value(hours: 1, minutes: 1, seconds: 1))
        XCTAssertEqual(Value(hours: 0, minutes: 59, seconds: 61).normalised(), Value(hours: 1, minutes: 0, seconds: 1))
        XCTAssertEqual(Value(hours: 1, minutes: -1, seconds: -1).normalised(), Value(hours: 0, minutes: 58, seconds: 59))
    }
    
    func testHMS_Adding() throws {
        let lhs = Value(hours: 1, minutes: 2, seconds: 3)
        let rhs = Value(hours: 2, minutes: 3, seconds: 4)
        let expected = Value(hours: 3, minutes: 5, seconds: 7)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testHMS_AddingOverflow() throws {
        let lhs = Value(hours: 359, minutes: 59, seconds: 59)
        let rhs = Value(hours: 1, minutes: 1, seconds: 2)
        let expected = Value(hours: 361, minutes: 1, seconds: 1)
        XCTAssertEqual(lhs.adding(rhs), expected)
    }
    
    func testHMS_Subtracting() throws {
        let lhs = Value(hours: 2, minutes: 3, seconds: 4)
        let rhs = Value(hours: 1, minutes: 2, seconds: 3)
        let expected = Value(hours: 1, minutes: 1, seconds: 1)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testHMS_SubtractingUnderflow() throws {
        let lhs = Value(hours: 1, minutes: 2, seconds: 3)
        let rhs = Value(hours: 2, minutes: 3, seconds: 4)
        let expected = Value(hours: -2, minutes: 58, seconds: 59)
        XCTAssertEqual(lhs.subtracting(rhs), expected)
    }
    
    func testHMS_Dividing() throws {
        let lhs = Value(hours: 9, minutes: 30, seconds: 4)
        let rhs = Value(integer: 2)
        let expected = Value(hours: 4, minutes: 45, seconds: 2)
        XCTAssertEqual(lhs.dividing(rhs), expected)
    }
}

