//
//  ModelDisplayTests.swift
//  DegreeCalculatorTests
//
//  Created by Eskil Olsen on 7/23/25.
//

import XCTest
@testable import DegreeCalculator

@MainActor
final class ObservableModelDisplayTests: XCTestCase {
    var md: ObservableModelData! = nil
    
    // MARK: Setup and helpers

    func makeModel(with mode: ModelData.ExprMode) -> ObservableModelData {
        return ObservableModelData(mode: mode)
    }

    func testDisplayLines_SingleNumber() throws {
        md = makeModel(with: .DMS)
        try md.inputString("2'3")

        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "      0°2'3", trailingOperator: nil),
        ]

        XCTAssertEqual(md.displayLines, expectedLines)
    }

    func testDisplayLines_UnterminatedAfterExpression() throws {
        md = makeModel(with: .DMS)
        try md.inputString("1°2'3 + 4°5'6")

        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "      4°5'6", trailingOperator: nil),
        ]

        XCTAssertEqual(md.displayLines, expectedLines)
    }

    func testDisplayLines_UnterminatedAfterExpressions() throws {
        md = makeModel(with: .DMS)
        try md.inputString("1°2'3 + 4°5'6 - 5°7'9")

        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "     4°05'6", trailingOperator: "-"),
            DisplayLine(id: 2, value: "      5°7'9", trailingOperator: nil),
        ]

        XCTAssertEqual(md.displayLines, expectedLines)
    }

    func testDisplayLines_Terminated() throws {
        md = makeModel(with: .DMS)
        try md.inputString("1°2'3 + 4°5'6 =")

        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "     4°05'6", trailingOperator: "="),
            DisplayLine(id: 2, value: "     5°07'9", trailingOperator: "=="),
        ]

        XCTAssertEqual(md.displayLines, expectedLines)
    }

    func testDisplayLines_UnterminatedAfterNumber() throws {
        md = makeModel(with: .DMS)
        try md.inputString("1°2'3 + 4°5'6 = 7°8'9")

        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "     4°05'6", trailingOperator: "="),
            DisplayLine(id: 2, value: "     5°07'9", trailingOperator: "=="),
            DisplayLine(id: 3, value: "      7°8'9", trailingOperator: nil),
        ]

        XCTAssertEqual(md.displayLines, expectedLines)
    }
    
    func testDisplayLines_UnterminatedAfterOperator() throws {
        md = makeModel(with: .DMS)
        try md.inputString("1°2'3 + 4°5'6 = 7°8'9 -")

        let expectedLines: [DisplayLine] = [
            DisplayLine(id: 0, value: "     1°02'3", trailingOperator: "+"),
            DisplayLine(id: 1, value: "     4°05'6", trailingOperator: "="),
            DisplayLine(id: 2, value: "     5°07'9", trailingOperator: "=="),
            DisplayLine(id: 3, value: "     7°08'9", trailingOperator: "-"),
        ]

        XCTAssertEqual(md.displayLines, expectedLines)
    }
}
