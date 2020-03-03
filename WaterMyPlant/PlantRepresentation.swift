//
//  PlantRepresentation.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/2/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation

struct PlantRepresentation: Codable {
    let species: String
    let h2oFrequency: String?
    let time: String?
    let image: String?
    let nickName: String?
    let startingDayOfWeek: String?
    let id: String?
}
