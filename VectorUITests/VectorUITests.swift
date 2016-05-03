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
        
        XCUIDevice.sharedDevice().orientation = .Portrait
        
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
        
        sleep(2)
        
        snapshot("p01Recents")
        
        let label = app.staticTexts["Coffee Break"]
        let exists = NSPredicate(format: "exists == 1")
        
        expectationForPredicate(exists, evaluatedWithObject: label, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
        
        app.tables.staticTexts["Coffee Break"].tap()
        
        sleep(2)
        
        snapshot("p02RoomView")
        
        //let foo = app.debugDescription
        //print(app.debugDescription)
        
        var recentsNavigationBar = app.navigationBars["Recents"]
        if (!recentsNavigationBar.exists) {
            recentsNavigationBar = app.navigationBars["RoomNav"]
        }
        //let recentsNavigationBar = app.navigationBars["RoomNav"]
        //recentsNavigationBar.buttons["Coffee Break"].tap()
        recentsNavigationBar.tap()
        
        sleep(1)
        
        snapshot("p03RoomViewHeader")
        
        
        
        //app.staticTexts["1/7 active member"].tap()
        //app.staticTexts["RoomAvatar"].tap()
        app.staticTexts["Member Count"].tap()
        
        //app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).tap()
        
        sleep(1)
        app.staticTexts["Settings"].tap()
        
        snapshot("p04RoomSettings")
        
        app.staticTexts["Members"].tap()
        
        snapshot("p05RoomMembers")
        
        app.navigationBars.containingType(.StaticText, identifier:"Room Details").buttons["Back"].tap()
        
        
        
        
        //app.navigationBars.matchingIdentifier("Room Details").buttons["Cancel"].tap()
        app.buttons["upload icon"].tap()
        
        snapshot("p06MediaPicker")
        
        app.scrollViews.otherElements.containingType(.Image, identifier:"remove_icon.png").childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        
        if (app.navigationBars["Recents"].exists) {
            recentsNavigationBar.buttons["Back"].tap()
        }
        app.navigationBars["Messages"].buttons["settings icon"].tap()
        
        snapshot("p07Settings")
        
        app.navigationBars["Settings"].buttons["Back"].tap()
        
        
        XCUIDevice.sharedDevice().orientation = .LandscapeLeft
        
        snapshot("l01Recents")
        
        
        expectationForPredicate(exists, evaluatedWithObject: label, handler: nil)
        waitForExpectationsWithTimeout(30, handler: nil)
        
        app.tables.staticTexts["Coffee Break"].tap()
        
        sleep(2)
        
        snapshot("l02RoomView")
        
        if (!recentsNavigationBar.exists) {
            recentsNavigationBar = app.navigationBars["RoomNav"]
        }
        recentsNavigationBar.tap()
        
        
        /*let app = XCUIApplication()
        app.tables.cells.containingType(.StaticText, identifier:"SUNDAY").childrenMatchingType(.TextView).element.tap()
        app.navigationBars["Recents"].childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        XCUIApplication().tables.staticTexts["SUNDAY"].tap()*/
        
        
        //recentsNavigationBar.buttons["Coffee Break"].tap()
        //let recentsNavigationBar2 = app.navigationBars["Coffee Break"]
        //recentsNavigationBar2.tap()
        
        
        
        
        
        
        snapshot("l03RoomViewHeader")
        
        app.staticTexts["Member Count"].tap()
        
        sleep(1)
        
        
        //app.staticTexts["1/7 active member"].tap()
        //XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).tap()
        
        
        app.staticTexts["Settings"].tap()
        
        snapshot("l04RoomSettings")
        
        app.staticTexts["Members"].tap()
        
        snapshot("l05RoomMembers")
        
        
        app.navigationBars.containingType(.StaticText, identifier:"Room Details").buttons["Back"].tap()
        //app.navigationBars.matchingIdentifier("Room Details").buttons["Cancel"].tap()
        app.buttons["upload icon"].tap()
        
        snapshot("l06MediaPicker")
        
        app.scrollViews.otherElements.containingType(.Image, identifier:"remove_icon.png").childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        if (app.navigationBars["Recents"].exists) {
            app.navigationBars["Recents"].buttons["Back"].tap()
        }
        app.navigationBars["Messages"].buttons["settings icon"].tap()
        
        snapshot("l07Settings")
        
        app.navigationBars["Settings"].buttons["Back"].tap()
    }
    
}
