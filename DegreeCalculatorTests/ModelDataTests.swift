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
    
    // Default to make a DMS model
    override func setUp() {
        md = makeModel(with: .DMS)
    }
    
    override func tearDown() {
        md = nil
    }
    
    // MARK: Test basic input
    
    // Test a full and proper 1°2'3 build
    func testDMS_Entry_BuildFull() throws {
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        
        try  md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test shortcut building by pressing ° and ' without numbers
    func testDMS_Entry_ShortcutDegreesMinutes() throws {
        try md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("°"))
        XCTAssertEqual(md.currentNumber, "0°")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("°'"))
        XCTAssertEqual(md.currentNumber, "0°0'")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("°'1"))
        XCTAssertEqual(md.currentNumber, "0°0'1")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test shortcut building by pressing ' without numbers or degrees
    func testDMS_Entry_ShortcutMinutes() throws {
        try md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("'"))
        XCTAssertEqual(md.currentNumber, "0°0'")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("'1"))
        XCTAssertEqual(md.currentNumber, "0°0'1")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test shortcut building by ' with a > 60 value
    func testDMS_Entry_ShortcutMinutes_WhenOver60() throws {
        try md.inputString("185'")
        XCTAssertEqual(md.inputStack, Array("185'"))
        XCTAssertEqual(md.currentNumber, "0°185'")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("185'1"))
        XCTAssertEqual(md.currentNumber, "0°185'1")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test adding second ° and ' at various times is a noop
    func testDMS_DoubleDegreeMinuteEntry_IsNoop() throws {
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Immediate repeated degree (°) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Later epeated degree (°) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Immediate repeated minute
        try md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Later repeated minute (') is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "'")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Later repeated degree (°) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "°")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // MARK: Test full HMS expressions
    
    // Test a full and proper 1h2m3 build
    func testHMS_Entry_BuildFull() throws {
        md = makeModel(with: .HMS)
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h"))
        XCTAssertEqual(md.currentNumber, "1h")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1h2"))
        XCTAssertEqual(md.currentNumber, "1h2")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m"))
        XCTAssertEqual(md.currentNumber, "1h2m")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test shortcut building by pressing h and m without numbers
    func testHMS_Entry_ShortcutDegreesMinutes() throws {
        md = makeModel(with: .HMS)
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("h"))
        XCTAssertEqual(md.currentNumber, "0h")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("hm"))
        XCTAssertEqual(md.currentNumber, "0h0m")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("hm1"))
        XCTAssertEqual(md.currentNumber, "0h0m1")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test shortcut building by pressing m without numbers or degrees
    func testHMS_Entry_ShortcutMinutes() throws {
        md = makeModel(with: .HMS)
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("m"))
        XCTAssertEqual(md.currentNumber, "0h0m")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("m1"))
        XCTAssertEqual(md.currentNumber, "0h0m1")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test shortcut building by m with a > 60 value
    func testHMS_Entry_ShortcutMinutes_WhenOver60() throws {
        md = makeModel(with: .HMS)
        
        try md.inputString("185m")
        XCTAssertEqual(md.inputStack, Array("185m"))
        XCTAssertEqual(md.currentNumber, "0h185m")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("185m1"))
        XCTAssertEqual(md.currentNumber, "0h185m1")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // Test adding second h and m at various times is a noop
    func testHMS_DoubleDegreeMinuteEntry_IsNoop() throws {
        md = makeModel(with: .HMS)
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "1")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h"))
        XCTAssertEqual(md.currentNumber, "1h")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Immediate repeated hour (h) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h"))
        XCTAssertEqual(md.currentNumber, "1h")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "2")
        XCTAssertEqual(md.inputStack, Array("1h2"))
        XCTAssertEqual(md.currentNumber, "1h2")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Later epeated hour (h) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h2"))
        XCTAssertEqual(md.currentNumber, "1h2")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m"))
        XCTAssertEqual(md.currentNumber, "1h2m")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Immediate repeated minute
        try md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m"))
        XCTAssertEqual(md.currentNumber, "1h2m")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.ENTRY, label: "3")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Later repeated minute (m) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "m")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Later repeated hour (h) is noop
        try md.callFunction(CalculatorFunction.ENTRY, label: "h")
        XCTAssertEqual(md.inputStack, Array("1h2m3"))
        XCTAssertEqual(md.currentNumber, "1h2m3")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // MARK: Test full expressions
    
    func testUnterminatedOperators() throws {
        try md.inputString("1°2'3 +")
        XCTAssertEqual(md.inputStack, Array("1°2'3+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.inputString("4°5'6 +")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    func testHMS_Entry_in_DMS_Mode_IsNoop() throws {
        md = makeModel(with: .DMS)
        try md.inputString("hm")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }

    func testDMS_Entry_in_HMS_Mode_IsNoop() throws {
        md = makeModel(with: .HMS)
        try md.inputString("°'")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }

    func testEqual_OnBlank_IsNoop() throws {
        try md.inputString("=")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    func testEqual_OnInput_NoOperator_IsNoop() throws {
        try md.inputString("1°2'3")
        try md.inputString("=")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
    }

    func testEqual_OnInput_Operator_CancelsOperator() throws {
        try md.inputString("1°2'3+4°5'6-")
        try md.inputString("=")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])
    }

    func testAdd_AndEqual() throws {
        try md.inputString("1°2'3 + 4°5'6")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6"))
        XCTAssertEqual(md.currentNumber, "4°5'6")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.EQUAL, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])
    }
    
    func testAdd_AndEqualShortStyle() throws {
        try md.inputString("°4 + 2 =")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 0, minutes: 4.0)),
                        rhs: Expr.value(Value(degrees: 0, minutes: 2.0))),
        ])
    }
    
    func testAdd_OnEmpty_IsNoop() throws {
        try md.inputString("+")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Full expression
        try md.inputString("1°2'3 + 4°5'6 =")
        // Extra +
        try md.inputString("+")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
        ])
    }
    
    func testSubtract_OnEmpty_IsNoop() throws {
        try md.inputString("-")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Full expression
        try md.inputString("1°2'3 + 4°5'6 =")
        // Extra -
        try md.inputString("-")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
        ])
    }
    
    func testDivide_OnEmpty_UsesAns() throws {
        try md.inputString("/")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        
        // Full expression
        try md.inputString("1°2'3 + 4°5'6 =")
        // Extra / on an empty expression uses ans() to start
        try md.inputString("/")
        XCTAssertEqual(md.inputStack, Array("5°07'9/"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])
    }
    
    // MARK: Test functions like clear/del/ans
    
    func testAns_OnEmpty() throws {
        try md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    func testAns_InsertsOnBlank() throws {
        try md.inputString("1°2'3 + 4°5'6 =")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])
        try md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, Array("5°07'9"))
    }
    
    
    func testAns_ReplacesInput() throws {
        try md.inputString("1°2'3 + 4°5'6 = 1°2'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])

        // ANS replaces the current input
        try md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, Array("5°07'9"))
        XCTAssertEqual(md.currentNumber, "5°07'9")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])
    }

    func testAns_AfterOpInput() throws {
        try md.inputString("1°2'3 + 4°5'6 = 1°2'3 + ")
        XCTAssertEqual(md.inputStack, Array("1°2'3+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
        ])
        // ANS adds after the op the current input
        try md.callFunction(CalculatorFunction.ANS, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2'3+5°07'9"))
        XCTAssertEqual(md.currentNumber, "5°07'9")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
        ])

        try md.callFunction(CalculatorFunction.EQUAL, label: "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 5, minutes: 7.9)))

        ])
    }
    
    // Test behaviour of clear, specifically that inputStack is reset and expressions is unchanged.
    func testClear_ErasesCurrentNumber() throws {
        try md.inputString("1°2'3 + 4°5'6 = 1°2'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
        
        try md.callFunction(CalculatorFunction.CLEAR, label: "")
        XCTAssertEqual(md.inputStack, [])
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
    func testAllClear_ErasesAllStatus() throws {
        try md.inputString("1°2'3 + 4°5'6 = 1°2'")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions,
                       [
                        Expr.binary(op: Operator.add,
                                    lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                    rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
                       ]
        )
        
        try md.callFunction(CalculatorFunction.ALL_CLEAR, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    // FIXME: test entering +/- before any numbers
    
    
    func testDelete_OnEmpty() throws {
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    func testDelete_CurrentNumber() throws {
        try md.inputString("1°2'3")
        
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2'"))
        XCTAssertEqual(md.currentNumber, "1°2'")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2"))
        XCTAssertEqual(md.currentNumber, "1°2")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°"))
        XCTAssertEqual(md.currentNumber, "1°")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1"))
        XCTAssertEqual(md.currentNumber, "1")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array(""))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        
        // Delete when it's already empty
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    func testDelete_FirstOperator() throws {
        md = makeModel(with: .DMS)
        
        // Test inputting a partial expressing and deleting
        // reverts as expected
        try md.inputString("1°2'3+")
        XCTAssertEqual(md.inputStack, Array("1°2'3+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2'3"))
        XCTAssertEqual(md.currentNumber, "1°2'3")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Complete expression
        try md.inputString("+4°5'6")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6"))
        XCTAssertEqual(md.currentNumber, "4°5'6")
        try md.inputString("=")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions,[
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 4, minutes: 5.6)))
        ])
    }
    
    func testDelete_SecondOperator() throws {
        md = makeModel(with: .DMS)
        
        try md.inputString("1°2'3 + 4°5'6 -")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6-"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
        
        try md.callFunction(CalculatorFunction.DELETE, label: "")
        XCTAssertEqual(md.inputStack, Array("1°2'3+4°5'6"))
        XCTAssertEqual(md.currentNumber, "4°5'6")
        XCTAssertEqual(md.builtExpressions, [])
        
        // Complete expression
        try md.inputString("-7°8'9=")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions,[
            Expr.binary(op: Operator.subtract,
                        lhs: Expr.binary(op: Operator.add,
                                         lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                                         rhs: Expr.value(Value(degrees: 4, minutes: 5.6))),
                        rhs: Expr.value(Value(degrees: 7, minutes: 8.9)))
        ])
    }
    
    func testMinus360_OnBlankState() throws {
        // Check that Minus 360 adds a subtract operation for 360
        try md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }
    
    func testMinus360_OnNumber() throws {
        try md.inputString("361°2'3")
        // Check that Minus 360 adds a subtract operation for 360
        try md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.subtract,
                        lhs: Expr.value(Value(degrees: 361, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 360, minutes: 0.0))),
        ])
    }
    
    func testMinus360_OnBlankPullInAns() throws {
        try md.inputString("360°+1°2'3=")
        // Check that Minus 360 adds a subtract operation for 360
        try md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(op: Operator.add,
                        lhs: Expr.value(Value(degrees: 360, minutes: 0.0)),
                        rhs: Expr.value(Value(degrees: 1, minutes: 2.3))),
            Expr.binary(op: Operator.subtract,
                        lhs: Expr.value(Value(degrees: 361, minutes: 2.3)),
                        rhs: Expr.value(Value(degrees: 360, minutes: 0.0))),
        ])
    }
    
    func testMinus360_OnOpenExpr() throws {
        try md.inputString("360°+1°2'3")
        
        try md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(
                op: Operator.add,
                lhs: Expr.value(Value(degrees: 360, minutes: 0.0)),
                rhs: Expr.value(Value(degrees: 1, minutes: 2.3))
            ),
            Expr.binary(
                op: Operator.subtract,
                lhs: Expr.value(Value(degrees: 361, minutes: 2.3)),
                rhs: Expr.value(Value(degrees: 360, minutes: 0.0))
            ),
        ])
    }
    
    func testMinus360_OnOpenOperator() throws {
        try md.inputString("361°2'3+")
        // Check that Minus 360 adds a subtract operation for 360
        try md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.inputStack,Array("361°2'3+"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [])
    }

    func testMinus360_HMS_OnOpenExpr() throws {
        md = makeModel(with: .HMS)
        try md.inputString("36h+1h2m3")
        
        try md.callFunction(CalculatorFunction.M360, label: "")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(
                op: Operator.add,
                lhs: Expr.value(Value(hours: 36, minutes: 0, seconds: 0)),
                rhs: Expr.value(Value(hours: 1, minutes: 2, seconds: 3))
            ),
            Expr.binary(
                op: Operator.subtract,
                lhs: Expr.value(Value(hours: 37, minutes: 2, seconds: 3)),
                rhs: Expr.value(Value(hours: 24, minutes: 0, seconds: 0))
            ),
        ])
    }
    
    func testDiv_DMS_BaseCase() throws {
        try md.inputString("2°4'8")
        XCTAssertEqual(md.intOnly, false)
        try md.inputString("/")
        XCTAssertEqual(md.intOnly, true)
        try md.inputString("2")
        XCTAssertEqual(md.inputStack, Array("2°4'8/2"))
        XCTAssertEqual(md.currentNumber, "2")
        XCTAssertEqual(md.builtExpressions, [])
        // DMS/HMS input not accepted
        try md.inputString("°")
        XCTAssertEqual(md.inputStack, Array("2°4'8/2"))
        XCTAssertEqual(md.currentNumber, "2")
        XCTAssertEqual(md.builtExpressions, [])
        try md.inputString("'")
        XCTAssertEqual(md.inputStack, Array("2°4'8/2"))
        XCTAssertEqual(md.currentNumber, "2")
        XCTAssertEqual(md.builtExpressions, [])

        try md.inputString("=")
        XCTAssertEqual(md.intOnly, false) // Ensure we again allow DMS/HMS input
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(
                op: Operator.divide,
                lhs: Expr.value(Value(degrees: 2, minutes: 4.8)),
                rhs: Expr.value(Value(integer: 2))
            ),
        ])
    }
    
    func testDiv_DMS_FromExpr() throws {
        try md.inputString("1°2'3 + 4°5'6")
        // pressing / terminates the expression w/equal and pulls in the answer
        try md.inputString("/")
        XCTAssertEqual(md.intOnly, true)
        XCTAssertEqual(md.inputStack, Array("5°07'9/"))
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(
                op: Operator.add,
                lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                rhs: Expr.value(Value(degrees: 4, minutes: 5.6))
            ),
        ])
        try md.inputString("2=")
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(
                op: Operator.add,
                lhs: Expr.value(Value(degrees: 1, minutes: 2.3)),
                rhs: Expr.value(Value(degrees: 4, minutes: 5.6))
            ),
            Expr.binary(
                op: Operator.divide,
                lhs: Expr.value(Value(degrees: 5, minutes: 7.9)),
                rhs: Expr.value(Value(integer: 2))
            ),
        ])
    }

    
    func testDiv_HMS_BaseCase() throws {
        md = makeModel(with: .HMS)
        try md.inputString("2h4m8")
        XCTAssertEqual(md.intOnly, false)
        try md.inputString("/")
        XCTAssertEqual(md.intOnly, true)
        try md.inputString("2")
        XCTAssertEqual(md.inputStack, Array("2h4m8/2"))
        XCTAssertEqual(md.currentNumber, "2")
        XCTAssertEqual(md.builtExpressions, [])
        // DMS/HMS input not accepted
        try md.inputString("h")
        XCTAssertEqual(md.inputStack, Array("2h4m8/2"))
        XCTAssertEqual(md.currentNumber, "2")
        XCTAssertEqual(md.builtExpressions, [])
        try md.inputString("m")
        XCTAssertEqual(md.inputStack, Array("2h4m8/2"))
        XCTAssertEqual(md.currentNumber, "2")
        XCTAssertEqual(md.builtExpressions, [])

        try md.inputString("=")
        XCTAssertEqual(md.intOnly, false) // Ensure we again allow DMS/HMS input
        XCTAssertEqual(md.inputStack, [])
        XCTAssertEqual(md.currentNumber, "")
        XCTAssertEqual(md.builtExpressions, [
            Expr.binary(
                op: Operator.divide,
                lhs: Expr.value(Value(hours: 2, minutes: 4, seconds: 8)),
                rhs: Expr.value(Value(integer: 2))
            ),
        ])
    }
}
