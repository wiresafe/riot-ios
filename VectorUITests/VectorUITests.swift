//
//  VectorUITests.swift
//  VectorUITests
//
//  Created by David Baker on 29/04/2016.
//  Copyright © 2016 matrix.org. All rights reserved.
//

import XCTest

class VectorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        //XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        /*
        let elementsQuery = app.scrollViews.otherElements
        let emailOrUserNameTextField = elementsQuery.textFields["Email or user name"]
        emailOrUserNameTextField.tap()
        emailOrUserNameTextField.tap()
        emailOrUserNameTextField.typeText("victor")
        
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("vectordemo")
        elementsQuery.buttons["Log in"].tap()
        app.alerts["\u{201c}Vector\u{201d} Would Like to Send You Notifications"].collectionViews.buttons["OK"].tap()
        */
        
        sleep(5)
        
        snapshot("01Recents")
        
        let label = app.staticTexts["Coffee Break"]
        let exists = NSPredicate(format: "exists == 1")
        
        expectationForPredicate(exists, evaluatedWithObject: label, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
        
        app.tables.staticTexts["Coffee Break"].tap()
        
        sleep(5)
        
        snapshot("02MessageView")
    }
    
}
