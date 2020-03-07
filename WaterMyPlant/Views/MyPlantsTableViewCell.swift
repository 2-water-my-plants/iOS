//
//  MyPlantsTableViewCell.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/3/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

protocol MyPlantsTableViewCellDelegate: class {
    func isWateredCheckBoxWasChecked(for plant: Plant)
    func isWateredCheckBoxWasUnchecked(for plant: Plant)
}

class MyPlantsTableViewCell: UITableViewCell {

    // MARK: - Properties

    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    weak var delegate: MyPlantsTableViewCellDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var plantImageView: UIImageView!
    @IBOutlet private weak var speciesLabel: UILabel!
    @IBOutlet private weak var waterCountdownLabel: UILabel!
    @IBOutlet private weak var isWateredCheckBox: UIButton!
    @IBOutlet private weak var isWateredLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func isWateredCheckBoxTapped(_ sender: UIButton) {
        guard let plant = plant else { return }
        
        if isWateredCheckBox.currentImage == UIImage(systemName: "checkmark.square.fill") {
            isWateredCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
            delegate?.isWateredCheckBoxWasUnchecked(for: plant)
        } else {
            isWateredCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            delegate?.isWateredCheckBoxWasChecked(for: plant)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateViews() {
        guard let plant = plant else { return }
        
        nameLabel.text = plant.nickName
        speciesLabel.text = plant.species
        
        guard let daysSinceLastWatered = plant.daysSinceLastWatered else { return }
                
        // Update isWateredCheckBox
        if daysSinceLastWatered == 0 {
            isWateredCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            isWateredCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        // Update waterCountdownLabel
        let daysTillNextWater = plant.daysTillNextWater ?? 0
        
        if plant.h2oFrequency == nil {
            waterCountdownLabel.text = "Watering frequency not specified"
        } else {
            waterCountdownLabel.text = generatedWaterCountdownString(daysTillNextWater: daysTillNextWater)
        }
    }
    
    func generatedWaterCountdownString(daysTillNextWater: Int) -> String {
        switch daysTillNextWater {
        case 0:
            return "Water today"
        case 1:
            return "Water tomorrow"
        case -1:
            return "Water overdue by \(-daysTillNextWater) day"
        default:
            if daysTillNextWater > 1 {
                return "Water in \(daysTillNextWater) days"
            } else {
                return "Water overdue by \(-daysTillNextWater) days"
            }
        }
    }
}
