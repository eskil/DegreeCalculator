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
    
    // MARK: Setup and helpers

    func makeModel(with mode: ModelData.ExprMode) -> ModelData {
        return ModelData(mode: mode)
    }
    
    /**
     Helper function to input a string into the test md.
     */
    func inputString(_ string: String) {
        for ch in string {
            switch ch {
            case _ where ch.isWhitespace:
                break
            case "+":
                md.callFunction(CalculatorFunction.ADD, label: "")
            case "-":
                md.callFunction(CalculatorFunction.SUBTRACT, label: "")
            case "/":
                md.callFunction(CalculatorFunction.DIV, label: "")
            case "=":
                md.callFunction(CalculatorFunction.EQUAL, label: "")
            case "D":
                md.callFunction(CalculatorFunction.DELETE, label: "")
            case "C":
                md.callFunction(CalculatorFunction.CLEAR, label: "")
            case "A":
                md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
            default:
                md.callFunction(CalculatorFunction.ENTRY, label: String(ch))
            }
        }
    }
    
// MARK: Test basic input
    
    // Test a full and proper 1°2'3 build
    func testDMSEntryBuildFull() throws {
        md = makeModel(with: .DMS)
        
        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
        
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // Test shortcut building by pressing ° and ' without numbers
    func testDMSEntryShortcutDegreesMinutes() throws {
        md = makeModel(with: .DMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("°"))
        XCTAssertEqual(md.currentNumber, "0°")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("°'"))
        XCTAssertEqual(md.currentNumber, "0°0'")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("°'1"))
        XCTAssertEqual(md.currentNumber, "0°0'1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }

    // Test shortcut building by pressing ' without numbers or degrees
    func testDMSEntryShortcutMinutes() throws {
        md = makeModel(with: .DMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("'"))
        XCTAssertEqual(md.currentNumber, "0°0'")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("'1"))
        XCTAssertEqual(md.currentNumber, "0°0'1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // Test shortcut building by ' with a > 60 value
    func testDMSEntryShortcutMinutesWhenOver60() throws {
        md = makeModel(with: .DMS)

        inputString("185'")
        XCTAssertEqual(md.inputStack, Array("185'"))
        XCTAssertEqual(md.currentNumber, "0°185'")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("185'1"))
        XCTAssertEqual(md.currentNumber, "0°185'1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // Test adding second ° and ' at various times is a noop
    func testDMSDoubleDegreeMinuteEntryNoop() throws {
        md = makeModel(with: .DMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Immediate repeated degree (°) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Later epeated degree (°) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Immediate repeated minute
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Later repeated minute (') is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Later repeated degree (°) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // MARK: Test full HMS expressions
    
    // Test a full and proper 1h2m3 build
    func testHMSEntryBuildFull() throws {
        md = makeModel(with: .HMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
        
        md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h"))
        XCTAssertEqual(md.currentNumber, "1h")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1h2"))
        XCTAssertEqual(md.currentNumber, "1h2")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m"))
        XCTAssertEqual(md.currentNumber, "1h2m")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }

    // Test shortcut building by pressing h and m without numbers
    func testHMSEntryShortcutDegreesMinutes() throws {
        md = makeModel(with: .HMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("h"))
        XCTAssertEqual(md.currentNumber, "0h")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("hm"))
        XCTAssertEqual(md.currentNumber, "0h0m")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("hm1"))
        XCTAssertEqual(md.currentNumber, "0h0m1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }

    // Test shortcut building by pressing m without numbers or degrees
    func testHMSEntryShortcutMinutes() throws {
        md = makeModel(with: .HMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("m"))
        XCTAssertEqual(md.currentNumber, "0h0m")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("m1"))
        XCTAssertEqual(md.currentNumber, "0h0m1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // Test shortcut building by m with a > 60 value
    func testHMSEntryShortcutMinutesWhenOver60() throws {
        md = makeModel(with: .HMS)

        inputString("185m")
        XCTAssertEqual(md.inputStack, Array("185m"))
        XCTAssertEqual(md.currentNumber, "0h185m")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("185m1"))
        XCTAssertEqual(md.currentNumber, "0h185m1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // Test adding second h and m at various times is a noop
    func testHMSDoubleDegreeMinuteEntryNoop() throws {
        md = makeModel(with: .HMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h"))
        XCTAssertEqual(md.currentNumber, "1h")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Immediate repeated hour (h) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h"))
        XCTAssertEqual(md.currentNumber, "1h")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1h2"))
        XCTAssertEqual(md.currentNumber, "1h2")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Later epeated hour (h) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h2"))
        XCTAssertEqual(md.currentNumber, "1h2")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m"))
        XCTAssertEqual(md.currentNumber, "1h2m")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Immediate repeated minute
        md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m"))
        XCTAssertEqual(md.currentNumber, "1h2m")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Later repeated minute (m) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])

        // Later repeated hour (h) is noop
        md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, [])
    }
    
    // MARK: Test full expressions
    
    func testUnterminatedOperators() {
        md = makeModel(with: .DMS)
        
        inputString("1°2'3 +")
        XCTAssertEqual(md.inputStack, Array("1°2'3+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, ["1°02'3 +"])

        inputString("4°5'6 +")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        XCTAssertEqual(md.displayStack, ["1°02'3 +", "4°05'6 +"])
    }
    
    func testAddAndEqual() {
        md = makeModel(with: .DMS)

        inputString("1°2'3 + 4°5'6")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6"))
        XCTAssertEqual(md.displayStack, ["1°02'3 +"])
        XCTAssertEqual(md.currentNumber, "4°5'6")
        XCTAssertEqual(md.builtExpressions, [])

        md.callFunction(CalculatorFunction.EQUAL, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
    }

    func testAddAndEqualShortStyle() {
        md = makeModel(with: .DMS)

        inputString("°4 + 2 =")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 0, minutes: 4.0)),
                                    rhs: Expr.value(Value(degrees: 0, minutes: 2.0)))
                       ]
        )
    }

    // MARK: Test functions like clear/del/ans

    func testAddAndEqualAndAns() {
        md = makeModel(with: .DMS)

        inputString("1°2'3 + 4°5'6 = 1°2'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
          // ANS replaces the current input
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, Array("5°07'9"))
        // TODO: if we save displayStack, this should pass
        // XCTAssertEqual(md.displayStack, ["1°02'3 +", "4°05'6 =", "5°07'9", "5°07'9"])
        // and if we don't, it's empty
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "5°07'9")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
    }

    // Test behaviour of clear, specifically that inputStack is reset and expressions is unchanged.
    func testClear() throws {
        md = makeModel(with: .DMS)

        inputString("1°2'3 + 4°5'6 = 1°2'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
        
        md.callFunction(CalculatorFunction.CLEAR, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
    }
    
    // Test behaviour of all-clear, specifically that inputStack and expressions is reset
    func testAllClear() throws {
        md = makeModel(with: .DMS)

        inputString("1°2'3 + 4°5'6 = 1°2'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
        
        md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // FIXME: test entering +/- before any numbers
    
    func testDelete() {
        md = makeModel(with: .DMS)

        md.callFunction(CalculatorFunction.ENTRY, label: "1")
        md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("12"))
        XCTAssertEqual(md.currentNumber, "12")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
    }
    
    func testDeleteOneExpr() {
        md = makeModel(with: .DMS)

        // Test inputting a partial expressing and deleting
        // reverts as expected
        inputString("1°2'3+")
        XCTAssertEqual(md.inputStack, Array("1°2'3+"))
        XCTAssertEqual(md.displayStack, ["1°02'3 +"])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.displayStack, [])
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
#if false
    func testDeleteTwoExpr() {
        inputString("1°2'3 + 4°5'6 -")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6-"))
        XCTAssertEqual(md.displayStack, ["1°02'3 +", "4°05'6 -"])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        /*
         md.builtExpressions = [Expr.binary(op: Operator.subtract,
         lhs: Expr.binary(op: Operator.add,
         lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
         rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
         rhs: Expr())]
         */
        // Deleting removes the -, and moves the last number back to currentNumber,
        // and displayStack just has the first number+
        md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6"))
        XCTAssertEqual(md.currentNumber, "4°5'6")
        XCTAssertEqual(md.displayStack, ["1°02'3 +"])
        XCTAssertEqual(md.builtExpressions, [Expr.binary(op: Operator.add,
                                                         lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                                         rhs: Expr())])
    }
#endif
    
    
#if false
    func testAns() {
        inputString("1°2'3 + 4°5'6")
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.displayStack, ["1°02'3 +", "4°05'6 =", "5°07'9"])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
        md.callFunction(CalculatorFunction.EQUAL, label: "")
        md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, "5°07'9")
    }
    
    func testMinus360() {
        md.inputStack = "361°02'3"
        // Check that Minus 360 adds a subtract operation for 360
        md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.builtExpressions, [Expr.binary(op: Operator.subtract,
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
        XCTAssertEqual(md.builtExpressions, [Expr.binary(op: Operator.subtract,
                                                         lhs: Expr.value(Value(degrees: 361, minutes: 2.3)),
                                                         rhs: Expr.value(Value(degrees: 360, minutes: 0.0))),
                                             Expr()])
        XCTAssertEqual(md.inputStack, "")
    }
#endif
}
