//
//  ModelDisplayTests.swift
//  DegreeCalculatorTests
//
//  Created by Eskil Olsen on 7/23/25.
//

import XCTest
@testable import DegreeCalculator

final class ModelDisplayTests: XCTestCase {
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

    func testDisplayLines_1() {
        md = makeModel(with: .DMS)
        inputString("1°2'3 + 4°5'6 = 7°8'9")

        let lines = md.displayLines()
        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "     4°05'6", trailingOperator: "="),
            DisplayLine(id: 2, value: "     5°07'9", trailingOperator: "=="),
            DisplayLine(id: 3, value: "      7°8'9", trailingOperator: nil),
        ]

        XCTAssertEqual(lines, expectedLines)
    }
    
    func testDisplayLines_2() {
        md = makeModel(with: .DMS)
        inputString("1°2'3 + 4°5'6 = 7°8'9 -")

        let lines = md.displayLines()
        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "     4°05'6", trailingOperator: "="),
            DisplayLine(id: 2, value: "     5°07'9", trailingOperator: "=="),
            DisplayLine(id: 3, value: "     7°08'9", trailingOperator: "-"),
        ]

        XCTAssertEqual(lines, expectedLines)
    }
}
