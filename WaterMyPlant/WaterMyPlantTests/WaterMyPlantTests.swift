//
//  WaterMyPlantTests.swift
//  WaterMyPlantTests
//
//  Created by Lambda_School_Loaner_201 on 3/3/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import XCTest
@testable import WaterMyPlant

class WaterMyPlantTests: XCTestCase {

    func testLoginCorrectUsernameAndPassword() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let loginController = LoginController()
        let loginRequest = LoginRequest(username: "John Smith", password: "myprecious")
        loginController.login(with: loginRequest) { error in
            XCTAssertNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testLoginIncorrectUsernameAndPassword() {
        let loginExpectation = XCTestExpectation(description: "Incorrect Login")
        
        let loginController = LoginController()
        let loginRequest = LoginRequest(username: "chris1", password: "wow1")
        loginController.login(with: loginRequest) { error in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testLoginNoUsername() {
        let loginExpectation = XCTestExpectation(description: "Incorrect Login")
        
        let loginController = LoginController()
        let loginRequest = LoginRequest(username: "", password: "test1")
        loginController.login(with: loginRequest) { error in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    
    func testGeneratedWaterCountdownString() {
        
        let dummyMyPlantsTableViewCell = MyPlantsTableViewCell()
        
        XCTAssertEqual(dummyMyPlantsTableViewCell.generatedWaterCountdownString(daysTillNextWater: 1), "Water tomorrow")
        XCTAssertEqual(dummyMyPlantsTableViewCell.generatedWaterCountdownString(daysTillNextWater: 0), "Water today")
        XCTAssertEqual(dummyMyPlantsTableViewCell.generatedWaterCountdownString(daysTillNextWater: -1), "Water overdue by 1 day")
        XCTAssertEqual(dummyMyPlantsTableViewCell.generatedWaterCountdownString(daysTillNextWater: 2), "Water in 2 days")
        XCTAssertEqual(dummyMyPlantsTableViewCell.generatedWaterCountdownString(daysTillNextWater: 3), "Water in 3 days")
        XCTAssertEqual(dummyMyPlantsTableViewCell.generatedWaterCountdownString(daysTillNextWater: -2), "Water overdue by 2 days")
    }
    
    func testSignupSuccessful() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let signupNetworking = SignupNetworking()
        let signupRequest = SignupRequest(username: UUID().uuidString, password: "test1", phoneNumber: "12345")
        signupNetworking.signUp(with: signupRequest) { error in
            XCTAssertNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testSignupFailNoUsername() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let signupNetworking = SignupNetworking()
        let signupRequest = SignupRequest(username: "", password: "test1", phoneNumber: "12345")
        signupNetworking.signUp(with: signupRequest) { error in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testSignupFailNoPassword() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let signupNetworking = SignupNetworking()
        let signupRequest = SignupRequest(username: UUID().uuidString, password: "", phoneNumber: "12345")
        signupNetworking.signUp(with: signupRequest) { error in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testSignupFailNoPhone() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let signupNetworking = SignupNetworking()
        let signupRequest = SignupRequest(username: UUID().uuidString, password: "test1", phoneNumber: "")
        signupNetworking.signUp(with: signupRequest) { error in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testSignupFailNoPhoneNoPassword() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let signupNetworking = SignupNetworking()
        let signupRequest = SignupRequest(username: UUID().uuidString, password: "", phoneNumber: "")
        signupNetworking.signUp(with: signupRequest) { (error) in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
    
    func testSignupFailSameUsername() {
        let loginExpectation = XCTestExpectation(description: "Login expectation")
        
        let signupNetworking = SignupNetworking()
        let signupRequest = SignupRequest(username: "chris2", password: "test1", phoneNumber: "12345")
        signupNetworking.signUp(with: signupRequest) { (error) in
            XCTAssertNotNil(error)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10.0)
    }
}





