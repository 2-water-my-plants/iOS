//
//  PlantController.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/4/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import CoreData

//let baseURL = URL(string: "https://journal-693f9.firebaseio.com/")!
let baseURL = URL(string: "https://webpt9-water-my-plants.herokuapp.com/api")!

class PlantController {
    
    typealias CompletionHandler = (NetworkError?) -> Void
    
    var userId: String?
    
    init() {
        fetchPlantsFromServer()
    }
    
    // MARK: - CRUD: Public
    // CREATE, UPDATE, and DELETE functionality for Plant model object persistence
    // using Core Data.
    
    // MARK: - CREATE
    
    @discardableResult func createPlant(nickName: String,
                                        species: String? = nil,
                                        h2oFrequency: String? = nil,
                                        image: String? = nil,
                                        localImageData: Data? = nil,
                                        notificationEnabled: Bool = false,
                                        notificationTime: Date? = nil,
                                        dateLastWatered: Date? = nil) -> Plant {
        
        let plant = Plant(nickName: nickName,
                          species: species,
                          h2oFrequency: h2oFrequency,
                          image: image,
                          localImageData: localImageData,
                          notificationEnabled: notificationEnabled,
                          notificationTime: notificationTime,
                          dateLastWatered: dateLastWatered,
                          userId: userId)
        
        do {
            try CoreDataStack.shared.save()
            postPlantToServer(plant)
        } catch {
            print("Error saving new plant (id: \"\(plant.id ?? "")\") to persistent store: \(error)")
        }
        
        return plant
    }
    
    @discardableResult func createPlant(from plantRepresentation: PlantRepresentation) -> Plant {
        let notificationTime = date(from: plantRepresentation.notificationTime)
        let plant = createPlant(nickName: plantRepresentation.nickName,
                                species: plantRepresentation.species,
                                h2oFrequency: plantRepresentation.h2oFrequency,
                                image: plantRepresentation.image,
                                notificationEnabled: plantRepresentation.notificationEnabled ?? false,
                                notificationTime: notificationTime,
                                dateLastWatered: plantRepresentation.dateLastWatered)
        return plant
    }
    
    // MARK: - UPDATE
    // swiftlint:disable all
    func updatePlant(_ plant: Plant,
                     withNickName nickName: String,
                     species: String?,
                     h2oFrequency: String?,
                     image: String?,
                     localImageData: Data?,
                     notificationEnabled: Bool,
                     notificationTime: Date?,
                     dateLastWatered: Date?) {

        plant.nickName = nickName
        plant.species = species
        plant.h2oFrequency = h2oFrequency
        plant.image = image
        plant.localImageData = localImageData
        plant.notificationEnabled = notificationEnabled
        plant.notificationTime = notificationTime
        plant.dateLastWatered = dateLastWatered

        do {
            try CoreDataStack.shared.save()
            postPlantToServer(plant)
        } catch {
            print("Error saving updated plant (id: \"\(plant.id ?? "")\") to persistent store: \(error)")
        }
    }
  // swiftlint:enable all
    func updatePlant(_ plant: Plant, with plantRepresentation: PlantRepresentation) {
        let notificationTime = date(from: plantRepresentation.notificationTime)
        updatePlant(plant,
                    withNickName: plantRepresentation.nickName,
                    species: plantRepresentation.species,
                    h2oFrequency: plantRepresentation.h2oFrequency,
                    image: plantRepresentation.image,
                    localImageData: plant.localImageData,
                    notificationEnabled: plantRepresentation.notificationEnabled ?? false,
                    notificationTime: notificationTime,
                    dateLastWatered: plantRepresentation.dateLastWatered)
    }
    
    func plantWasWateredToday(plant: Plant) {
        plant.prevDateLastWatered = plant.dateLastWatered
        plant.dateLastWatered = Date()
        
        do {
            try CoreDataStack.shared.save()
            postPlantToServer(plant)
        } catch {
            print("Error saving updated plant (id: \"\(plant.id ?? "")\") to persistent store: \(error)")
        }
    }
    
    func undoPlantWasWateredToday(plant: Plant) {
        plant.dateLastWatered = plant.prevDateLastWatered
        plant.prevDateLastWatered = nil
        
        do {
            try CoreDataStack.shared.save()
            postPlantToServer(plant)
        } catch {
            print("Error saving updated plant (id: \"\(plant.id ?? "")\") to persistent store: \(error)")
        }
    }
    
    // MARK: - DELETE
    
    func deletePlant(_ plant: Plant) {
        let moc = CoreDataStack.shared.mainContext
        
        do {
            moc.delete(plant)
            try CoreDataStack.shared.save()
        } catch {
            moc.reset()
            print("Error deleting plant (id: \"\(plant.id ?? "")\") from persistent store: \(error)")
        }
        
        deletePlantFromServer(plant) { error in
            if let error = error {
                print("Plant (id: \"\(plant.id ?? "")\") successfully deleted from persistent store.")
                print("Error deleting plant (id: \"\(plant.id ?? "")\") from server: \(error)")
                return
            }
        }
    }
}

// MARK: - Helper Methods

func date(from notificationTimeRepresentation: String?) -> Date? {
    if let notificationTimeString = notificationTimeRepresentation {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        return timeFormatter.date(from: notificationTimeString)
    }
    return nil
}

// MARK: - Networking

extension PlantController {
    
    // MARK: - Server API: Public
    
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        guard let userId = userId else { return }
        
        let requestURL = baseURL
            .appendingPathComponent("auth/users/\(userId)/plants")
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            guard error == nil else {
                print("Error fetching plants from server: \(error!)")
                DispatchQueue.main.async {
                    completion(.otherError)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task.")
                DispatchQueue.main.async {
                    completion(.badData)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Status Code: 200 OK; Successful GET!")
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                //let plantRepresentations = Array(try jsonDecoder.decode([String: PlantRepresentation].self, from: data).values)
                let plantRepresentations = try jsonDecoder.decode([PlantRepresentation].self, from: data)
                
                try self.updatePlants(with: plantRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding and updating plant representations from the server: \(error)")
                DispatchQueue.main.async {
                    completion(.decodingError)
                }
            }
        }.resume()
    }
    
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let imageUrl = URL(string: urlString) else {
            completion(.failure(.otherError))
            return
        }
        
        var request = URLRequest(url: imageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.badData))
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }
    
    // MARK: - Server API: Private
    
    private func postPlantToServer(_ plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
//        guard let token = LoginController.shared.token else {
//            completion(.noAuth)
//            return
//        }
        
        guard let representation = plant.plantRepresentation else {
            completion(.otherError)
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent("auth/myplants")
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.post.rawValue
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .secondsSince1970
        
        do {
            request.httpBody = try jsonEncoder.encode(representation)
        } catch {
            print("Error encoding plant (id: \"\(plant.id ?? "")\"): \(error)")
            completion(.encodingError)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print("Error POSTing new plant (id: \"\(plant.id ?? "")\") to server: \(error!)")
                DispatchQueue.main.async {
                    completion(.otherError)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                DispatchQueue.main.async {
                    completion(.badAuth)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 201 {
                print("Status Code: 201 Created; Successful POST!")
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    private func deletePlantFromServer(_ plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
//        guard let token = LoginController.shared.token else {
//            completion(.noAuth)
//            return
//        }
        
        guard let plantId = plant.id else {
            completion(.otherError)
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent("plants")
            .appendingPathComponent(plantId)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print("Error deleting plant (id: \"\(plant.id ?? "")\") from server: \(error!)")
                DispatchQueue.main.async {
                    completion(.otherError)
                }
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Status Code: 200 OK; Successful DELETE!")
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Server API: Helpers
    
    private func updatePlants(with representations: [PlantRepresentation]) throws {
        let representationsWithID = representations.filter { $0.id != nil }
        let identifiersToFetch = representationsWithID.compactMap { $0.id! }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representationsWithID))
        var plantsToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            // Delete any plants (in persistent store) that do not exist in the server database
            let allExistingPlants = try context.fetch(Plant.fetchRequest()) as? [Plant]
            let plantsToDelete = allExistingPlants!.filter { !identifiersToFetch.contains($0.id!) }
            
            for plant in plantsToDelete {
                context.delete(plant)
            }
            
            // Update any plants (in persistent store) that also exist in the server database
            let existingPlants = try context.fetch(fetchRequest)
            
            for plant in existingPlants {
                guard let id = plant.id,
                    let representation = representationsByID[id] else { continue }
                
                self.updatePlant(plant, with: representation)
                plantsToCreate.removeValue(forKey: id)
            }
            
            // Create new plants (in persistent store) that only exist in the server database
            for representation in plantsToCreate.values {
                Plant(plantRepresentation: representation, context: context)
            }
        } catch {
            print("Error fetching plants from persistent store: \(error)")
        }
        
        try CoreDataStack.shared.save(context: context)
    }
}
