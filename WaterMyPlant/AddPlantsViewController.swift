//
//  AddPlantsViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

class AddPlantsViewController: UIViewController {

    // MARK: - Properties

    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    var plantController: PlantController!
    
    // MARK: - IBOutlets
    
    // Need to add IBOutlets here
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    // MARK: - UpdateViews
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        CoreDataStack.shared.mainContext.perform {
            if let plant = self.plant {
//                self.nickName = plant.nickName
//                self.species = plant.species
//                self.h2oFrequency = plant.h2oFrequency
//                self.time = plant.time
//                self.image = plant.image
//                self.dateLastWatered = plant.dateLastWatered
//                self.prevDateLastWatered = plant.prevDateLastWatered
            } else {
                self.title = self.plant?.nickName ?? "New Plant"
            }
        }
    }
}
