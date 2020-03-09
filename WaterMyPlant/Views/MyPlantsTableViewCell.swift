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
        
        plantImageView.layer.cornerRadius = plantImageView.bounds.width / 2.0
        if let imageData = plant.localImageData,
            let image = UIImage(data: imageData) {
            plantImageView.image = image
        }
        
        nameLabel.text = plant.nickName
        speciesLabel.text = "Species: \(plant.species ?? "not specified")"
        
        guard let daysSinceLastWatered = plant.daysSinceLastWatered else { return }
                
        // Update isWateredCheckBox
        if daysSinceLastWatered == 0 {
            isWateredCheckBox.tintColor = #colorLiteral(red: 0.009934567846, green: 0.56351161, blue: 0.3181376457, alpha: 1)
            isWateredCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            isWateredCheckBox.tintColor = #colorLiteral(red: 0.3215686275, green: 0.3411764706, blue: 0.3803921569, alpha: 1)
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
            waterCountdownLabel.textColor = #colorLiteral(red: 0.009934567846, green: 0.56351161, blue: 0.3181376457, alpha: 1)
            return "Water today"
        case 1:
            waterCountdownLabel.textColor = #colorLiteral(red: 0.3215686275, green: 0.3411764706, blue: 0.3803921569, alpha: 1)
            return "Water tomorrow"
        case -1:
            waterCountdownLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            return "Water overdue by 1 day"
        default:
            if daysTillNextWater > 1 {
                waterCountdownLabel.textColor = #colorLiteral(red: 0.3215686275, green: 0.3411764706, blue: 0.3803921569, alpha: 1)
                return "Water in \(daysTillNextWater) days"
            } else {
                waterCountdownLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                return "Water overdue by \(-daysTillNextWater) days"
            }
        }
    }
}
