//
//  WaterMyPlantUITests.swift
//  WaterMyPlantUITests
//
//  Created by Lambda_School_Loaner_201 on 3/8/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import XCTest

class WaterMyPlantUITests: XCTestCase {
    // swiftlint:disable all
    //This is one way of doing it.
    func testLogin() {
        let app = XCUIApplication()
        app.launch()
        
        let textFieldUsername = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .textField).element
        textFieldUsername.tap()
        textFieldUsername.typeText("chris")
        
        
        let passwordTextField = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .secureTextField).element
        passwordTextField.tap()
        passwordTextField.typeText("wow")
        app.buttons["Sign In"].tap()
        
        sleep(3)
        XCTAssertTrue(app.navigationBars["My Plants"].exists)
        
        //sleep(3)
        
    }
    
    
    func testloginWithWrongPassword() {
        
        //The other way of doing this kind of tests.
        let app = XCUIApplication()
        app.launch()
        
        let username = app.textFields["usernameTextField"]
        username.tap()
        username.typeText("chris")
        
        let password = app.secureTextFields["passwordTextField"]
        password.tap()
        password.typeText("wow1")
        
        app.buttons["Sign In"].tap()
        
        sleep(2)
        //This is one way to handle app alerts on UI tests.
        addUIInterruptionMonitor(withDescription: "") { (alert) -> Bool in
            let alertText = "Error Occured"
            if alert.label.contains(alertText) {
                XCTAssertTrue(alert.exists)
            }
            return true
        }
    }
    
    
    func testSignUp() {
        
        let app = XCUIApplication()
        app.launch()
        
        //Make sure to try with a different username and password before this test is going to be ran
        app.buttons["Create Account"].tap()
        let newUsername = app/*@START_MENU_TOKEN@*/.textFields["newUserNameTextField"]/*[[".textFields[\"username\"]",".textFields[\"newUserNameTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newUsername.tap()
        newUsername.typeText("chris3")
        
        let newPassword = app/*@START_MENU_TOKEN@*/.secureTextFields["newPasswordTextField"]/*[[".secureTextFields[\"password\"]",".secureTextFields[\"newPasswordTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newPassword.tap()
        newPassword.typeText("wow3")
        
        let newPhoneN = app.textFields["newPhoneNumberTextField"]
        newPhoneN.tap()
        newPhoneN.typeText("12345")
        
        app.buttons["Sign Up"].tap()
        
        sleep(3)
        
        XCTAssertTrue(app.navigationBars["My Plants"].exists)
        
    }
    
    func testSignUpWithoutPhoneNumber() {
        
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Create Account"].tap()
        let newUsername = app/*@START_MENU_TOKEN@*/.textFields["newUserNameTextField"]/*[[".textFields[\"username\"]",".textFields[\"newUserNameTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newUsername.tap()
        newUsername.typeText("chris3")
        
        let newPassword = app/*@START_MENU_TOKEN@*/.secureTextFields["newPasswordTextField"]/*[[".secureTextFields[\"password\"]",".secureTextFields[\"newPasswordTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        newPassword.tap()
        newPassword.typeText("wow3")
        
        let newPhoneN = app.textFields["newPhoneNumberTextField"]
        newPhoneN.tap()
        newPhoneN.typeText("")
        
        app.buttons["Sign Up"].tap()
        
        addUIInterruptionMonitor(withDescription: "") { (alert) -> Bool in
            let alertText = "Missing some fields"
            if alert.label.contains(alertText) {
                XCTAssertTrue(alert.exists)
            }
            return true
        }
        
    }
    
    func testNewPlant() {
        
        let app = XCUIApplication()
        app.launch()
        
        let username = app.textFields["usernameTextField"]
        username.tap()
        username.typeText("chris")
        
        let password = app.secureTextFields["passwordTextField"]
        password.tap()
        password.typeText("wow")
        
        app.buttons["Sign In"].tap()
        
        sleep(3)
        
        
        app.navigationBars["My Plants"].buttons["Add"].tap()
        let plantName = app.textFields["Enter a plant name"]
        plantName.tap()
        plantName.typeText("Chris's plant")
        app.navigationBars["New Plant"].buttons["Save"].tap()
        
        sleep(2)
        
        XCTAssertTrue(app.tables.cells.containing(.staticText, identifier:"Chris's plant").staticTexts["Species: "].exists)
        
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    // swiftlint:enable all
}
