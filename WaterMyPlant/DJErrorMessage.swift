//
//  DJErrorMessage.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/28/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation

enum DJError: String, Error {
    case emptyEmailAndPassword = "Please provide your email and password before trying to sign in."
    case incorrectEmail = "The email you entered was not correct. Please try again."
    case incorrectPassword = "The password you entered was not correct. Please try again."
    case generalWrongInfo = "The information you entered was not correct. Please enter your email and password."
    case emptyEmailAndPasswordSignUp = "Please provide your email address and a password before trying to sign up."
    case invalidEmail = "The email you entered is not valid. Please try again."
    case emailAlreadyInUse = "The email you entered is already in use. Please use a different email address."
    case generalSignUpError = "There was an issue trying to sign up. Please try again."
    case publicCantViewPunchline = "Please create an account or sign in to view the joke punchline."
    case errorSigningOut = "There was an error signing out. Please try again."
}
