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

struct GetPlants: Codable, Equatable {
    var id: String?
    var nickname: String?
    var species: String?
    var h2oFrequency: String?
    var image: String?
    var user_id: String?
}
