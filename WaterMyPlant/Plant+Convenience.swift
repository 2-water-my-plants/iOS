//
//  Plant+Convenience.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/1/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import CoreData

/*
enum StartingDayOfWeek: String, CaseIterable, Codable {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
}
*/

extension Plant {
    
    @discardableResult
    convenience init(nickName: String,
                     species: String?,
                     h2oFrequency: String? = nil,
                     time: String? = nil,
                     image: String? = nil,
                     dateLastWatered: Date? = nil,
                     prevDateLastWatered: Date? = nil,
                     id: String = UUID().uuidString,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.nickName = nickName
        self.species = species
        self.id = id
        self.image = image
        self.dateLastWatered = dateLastWatered
        self.prevDateLastWatered = prevDateLastWatered
        self.h2oFrequency = h2oFrequency
        self.time = time
    }
    
    @discardableResult
    convenience init?(plantRepresentation: PlantRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let id = plantRepresentation.id else { return nil }
        
        self.init(nickName: plantRepresentation.nickName,
                  species: plantRepresentation.species,
                  h2oFrequency: plantRepresentation.h2oFrequency,
                  time: plantRepresentation.time,
                  image: plantRepresentation.image,
                  dateLastWatered: plantRepresentation.dateLastWatered,
                  prevDateLastWatered: plantRepresentation.prevDateLastWatered,
                  id: id,
                  context: context)
    }
}
