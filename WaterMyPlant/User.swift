//
//  User.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation

struct User: Codable, Equatable {
    let id: Int?
    let username: String?
    let password: String?
    let phoneNumber: String?
    let message: String?
    let token: String?
}
