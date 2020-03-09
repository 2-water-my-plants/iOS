//
//  PlantRepresentation.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/2/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation

struct PlantRepresentation: Codable {
    let nickName: String
    let species: String?
    let h2oFrequency: String?
    let image: String?
    let id: String?
    let notificationEnabled: Bool?
    let notificationTime: String?
    let dateLastWatered: Date?
    let userId: String?
}
