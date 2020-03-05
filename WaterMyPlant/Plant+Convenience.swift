//
//  Plant+Convenience.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/1/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import CoreData

extension Plant {
    
    // MARK: - Properties

    var plantRepresentation: PlantRepresentation? {
        guard let nickName = nickName else { return nil }
        
        if id == nil {
            id = UUID().uuidString
        }
        
        return PlantRepresentation(nickName: nickName,
                                   species: species,
                                   h2oFrequency: h2oFrequency,
                                   image: image,
                                   id: id,
                                   notificationsEnabled: notificationsEnabled,
                                   notificationTime: notificationTime,
                                   dateLastWatered: dateLastWatered)
    }
    
    var daysSinceLastWatered: Int? {
        guard let dateLastWatered = dateLastWatered else { return nil }
        return Calendar.current.dateComponents([.day], from: dateLastWatered, to: Date()).day!
    }
    
    var daysTillNextWater: Int? {
        guard let daysSinceLastWatered = daysSinceLastWatered,
        let h2oFrequency = h2oFrequency,
        let h2oFrequencyInt = Int(h2oFrequency) else { return nil }
        return h2oFrequencyInt - daysSinceLastWatered
    }
    
    var wasWateredToday: Bool {
        guard let dateLastWatered = dateLastWatered else { return false }
        let dayLastWatered = Calendar.current.dateComponents([.day], from: dateLastWatered)
        let today = Calendar.current.dateComponents([.day], from: Date())
        return dayLastWatered == today
    }
    
    // MARK: - Initializers
    
    @discardableResult
    convenience init(nickName: String,
                     species: String? = nil,
                     h2oFrequency: String? = nil,
                     image: String? = nil,
                     id: String = UUID().uuidString,
                     notificationsEnabled: Bool = false,
                     notificationTime: String? = nil,
                     dateLastWatered: Date? = nil,
                     prevDateLastWatered: Date? = nil,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.nickName = nickName
        self.species = species
        self.h2oFrequency = h2oFrequency
        self.image = image
        self.id = id
        self.notificationsEnabled = notificationsEnabled
        self.notificationTime = notificationTime
        self.dateLastWatered = dateLastWatered
        self.prevDateLastWatered = prevDateLastWatered
    }
    
    @discardableResult
    convenience init?(plantRepresentation: PlantRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(nickName: plantRepresentation.nickName,
                  species: plantRepresentation.species,
                  h2oFrequency: plantRepresentation.h2oFrequency,
                  image: plantRepresentation.image,
                  id: plantRepresentation.id ?? UUID().uuidString,
                  notificationsEnabled: plantRepresentation.notificationsEnabled ?? false,
                  notificationTime: plantRepresentation.notificationTime,
                  dateLastWatered: plantRepresentation.dateLastWatered,
                  prevDateLastWatered: nil,
                  context: context)
    }
}
