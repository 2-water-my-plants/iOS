//
//  PlantController.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/4/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import CoreData

//let baseURL = URL(string: "https://journal-693f9.firebaseio.com/")!
let baseURL = URL(string: "https://webpt9-water-my-plants.herokuapp.com/api")!

class PlantController {
    
    typealias CompletionHandler = (NetworkError?) -> Void
    
    init() {
        fetchPlantsFromServer()
    }
    
    // MARK: - Public CRUD Methods
    
    // Create Plant
    func createPlant(nickName: String) {
        let plant = Plant(nickName: nickName)
        
        sendPlantToServer(plant)
    }
    
    // Update Plant
    func updatePlant(_ plant: Plant, with nickName: String) {
        plant.nickName = nickName
        
        sendPlantToServer(plant)
    }
    
    // Delete Plant
    func deletePlant(_ plant: Plant) {
        deletePlantFromServer(plant) { error in
            guard error == nil else {
                print("Error deleting plant from server: \(error!)")
                return
            }
            
            guard let moc = plant.managedObjectContext else { return }
            
            do {
                moc.delete(plant)
                try CoreDataStack.shared.save(context: moc)
            } catch {
                moc.reset()
                print("Error deleting plant from managed object context: \(error)")
            }
        }
    }
    
    // MARK: - Public Server API Methods
    
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in  }) {
        let requestURL = baseURL.appendingPathComponent("auth/myplants")
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
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
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let plantRepresentations = Array(try jsonDecoder.decode([String : PlantRepresentation].self, from: data).values)
                
                try self.updatePlant(with: plantRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding plant representations: \(error)")
                DispatchQueue.main.async {
                    completion(.decodingError)
                }
            }
        }.resume()
    }
    
    // MARK: - Private Server API Methods
    
    private func sendPlantToServer(_ plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        guard let token = LoginController.shared.token else {
            completion(.noAuth)
            return
        }
        
        guard let representation = plant.plantRepresentation else {
            completion(.otherError)
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("auth/myplants")
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.post.rawValue
        
        do {
            try CoreDataStack.shared.save()
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding plant: \(error)")
            completion(.encodingError)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error POSTing new plant to server: \(error!)")
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
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    private func deletePlantFromServer(_ plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        guard let token = LoginController.shared.token else {
            completion(.noAuth)
            return
        }
        
        guard let id = plant.id else {
            completion(.otherError)
            return
        }
        
        let requestURL = baseURL.appendingPathComponent("auth/myplants")
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            guard error == nil else {
                print("Error deleting plant from server: \(error!)")
                DispatchQueue.main.async {
                    completion(.otherError)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - API Helper Methods
    
    private func updatePlant(with representations: [PlantRepresentation]) throws {
        let representationsWithID = representations.filter { $0.id != nil }
        let identifiersToFetch = representationsWithID.compactMap { $0.id! }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representationsWithID))
        var plantsToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.mainContext
        
        do {
            // Delete existing plants in CoreData not found in server database
            let allExistingPlants = try context.fetch(Plant.fetchRequest()) as? [Plant]
            let plantsToDelete = allExistingPlants!.filter { !identifiersToFetch.contains($0.id!) }
            
            for plant in plantsToDelete {
                context.delete(plant)
            }
            
            // Update existing plants found in server database
            let existingPlants = try context.fetch(fetchRequest)
            
            for plant in existingPlants {
                guard let id = plant.id,
                    let representation = representationsByID[id] else { continue }
                
                self.update(plant, with: representation)
                plantsToCreate.removeValue(forKey: id)
            }
            
            // Create new entries from server database and add to Core Data
            for representation in plantsToCreate.values {
                Plant(plantRepresentation: representation, context: context)
            }
        } catch {
            print("Error fetching plant for id: \(error)")
        }
        
        try CoreDataStack.shared.save(context: context)
    }
    
    private func update(_ plant: Plant, with plantRepresentation: PlantRepresentation) {
        plant.nickName = plantRepresentation.nickName
        plant.species = plantRepresentation.species
        plant.h2oFrequency = plantRepresentation.h2oFrequency
        plant.time = plantRepresentation.time
        plant.image = plantRepresentation.image
        plant.dateLastWatered = plantRepresentation.dateLastWatered
        plant.prevDateLastWatered = plantRepresentation.prevDateLastWatered
    }
}
