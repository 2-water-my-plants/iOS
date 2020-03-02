//
//  Plant+Convenience.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/1/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import CoreData

enum StartingDayOfWeek: String, CaseIterable, Codable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}

extension Plant {
    
    @discardableResult
    convenience init(species: String,
                     image: String? = nil,
                     nickName: String? = nil,
                     id: String = UUID().uuidString,
                     startingDayOfWeek: StartingDayOfWeek = .sunday,
                     h2oFrequency: String,
                     time: String,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.species = species
        self.id = id
        self.image = image
        self.nickName = nickName
        self.startingDayOfWeek = startingDayOfWeek.rawValue
        self.h2oFrequency = h2oFrequency
        self.time = time
    }
}
