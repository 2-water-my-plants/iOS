//
//  Request.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation

struct SignupRequest: Codable, Equatable {
    let username: String
    let password: String
    let phoneNumber: String
}

struct LoginRequest: Codable, Equatable {
    let username: String
    let password: String
}
