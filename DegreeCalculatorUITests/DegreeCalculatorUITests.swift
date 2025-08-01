//
//  DegreeCalculatorUITests.swift
//  DegreeCalculatorUITests
//
//  Created by Eskil Olsen on 5/19/23.
//

import XCTest

final class DegreeCalculatorUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTripleTap_DMS_Minus360() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Helper function to tap buttons by label
        func tapButton(_ label: String, times: Int = 1) {
            let button = app.buttons["button_\(label)"]
            XCTAssertTrue(button.exists, "Button \(label) should exist")
            for _ in 0..<times {
                button.tap()
            }
        }
        
        // Enter 300° + 100° =
        tapButton("3")
        tapButton("0")
        tapButton("0")
        tapButton("°")
        tapButton("+")
        tapButton("1")
        tapButton("0")
        tapButton("0")
        tapButton("°")
        tapButton("=")

        // ANS
        tapButton("ANS")

        // Triple-tap minus for -360°
        let minusButton = app.buttons["button_-"]
        XCTAssertTrue(minusButton.exists, "Minus button should exist")

        minusButton.tap(withNumberOfTaps: 3, numberOfTouches: 1)

        // Find the line showing -360°
        XCTContext.runActivity(named: "Dump staticTexts") { _ in
            for element in app.staticTexts.allElementsBoundByIndex {
                print("Text: '\(element.label)', Identifier: '\(element.identifier)'")
            }
        }

        for element in app.staticTexts.allElementsBoundByIndex {
            print("Text: '\(element.label)', Identifier: '\(element.identifier)'")
        }
        
        print(app.debugDescription)
        
        let minus360Line = app.staticTexts["result_line_=_   360°00'0"]
        XCTAssertTrue(minus360Line.waitForExistence(timeout: 2), "Expected result '-360°' not found")
        let resultLine = app.staticTexts["result_line_==_    40°00'0"]
        XCTAssertTrue(resultLine.waitForExistence(timeout: 2), "Expected result '-360°' not found")
    }

    func testLaunchPerformance() throws {
        if #available(iOS 18.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
