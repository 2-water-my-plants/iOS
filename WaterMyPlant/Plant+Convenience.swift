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
        
        var notificationTimeRep: String?
        
        if let notificationTime = self.notificationTime {
            let timeRepFormatter = DateFormatter()
            timeRepFormatter.dateFormat = "HH:mm:ss"
            notificationTimeRep = timeRepFormatter.string(from: notificationTime)
        }
        
        return PlantRepresentation(nickName: nickName,
                                   species: species,
                                   h2oFrequency: h2oFrequency,
                                   image: image,
                                   id: id,
                                   notificationEnabled: notificationEnabled,
                                   notificationTime: notificationTimeRep,
                                   dateLastWatered: dateLastWatered,
                                   userId: userId)
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
    
    var notificationTimeString: String? {
        guard let notificationTime = notificationTime else { return nil }
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: notificationTime)
    }
    
    // MARK: - Initializers
    
    @discardableResult
    convenience init(nickName: String,
                     species: String? = nil,
                     h2oFrequency: String? = nil,
                     image: String? = nil,
                     localImageData: Data? = nil,
                     id: String = UUID().uuidString,
                     notificationEnabled: Bool = false,
                     notificationTime: Date? = nil,
                     dateLastWatered: Date? = nil,
                     prevDateLastWatered: Date? = nil,
                     userId: String? = nil,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.nickName = nickName
        self.species = species
        self.h2oFrequency = h2oFrequency
        self.image = image
        self.localImageData = localImageData
        self.id = id
        self.notificationEnabled = notificationEnabled
        self.notificationTime = notificationTime
        self.dateLastWatered = dateLastWatered
        self.prevDateLastWatered = prevDateLastWatered
        self.userId = userId
    }
    
    @discardableResult
    convenience init?(plantRepresentation: PlantRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        var notificationTime: Date?
        
        if let notificationTimeRep = plantRepresentation.notificationTime {
            let timeRepFormatter = DateFormatter()
            timeRepFormatter.dateFormat = "HH:mm:ss"
            notificationTime = timeRepFormatter.date(from: notificationTimeRep)
        }
        
        self.init(nickName: plantRepresentation.nickName,
                  species: plantRepresentation.species,
                  h2oFrequency: plantRepresentation.h2oFrequency,
                  image: plantRepresentation.image,
                  id: plantRepresentation.id ?? UUID().uuidString,
                  notificationEnabled: plantRepresentation.notificationEnabled ?? false,
                  notificationTime: notificationTime,
                  dateLastWatered: plantRepresentation.dateLastWatered,
                  userId: plantRepresentation.userId,
                  context: context)
    }
}
