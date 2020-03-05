//
//  MyPlantsTableViewCell.swift
//  WaterMyPlant
//
//  Created by David Wright on 3/3/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

protocol MyPlantsTableViewCellDelegate: class {
    func isWateredCheckBoxWasTapped()
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
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var waterCountdownLabel: UILabel!
    @IBOutlet weak var isWateredCheckBox: UIButton!
    @IBOutlet weak var isWateredLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func isWateredCheckBoxTapped(_ sender: UIButton) {
        if isWateredCheckBox.currentImage == UIImage(systemName: "checkmark.square.fill") {
            isWateredCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            isWateredCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
        delegate?.isWateredCheckBoxWasTapped()
    }
    
    // MARK: - Private Methods
    
    private func updateViews() {
        guard let plant = plant else { return }
        
        nameLabel.text = plant.nickName
        speciesLabel.text = plant.species
        
        var daysTillNextWater: Int
        
        if let h2oFrequencyString = plant.h2oFrequency,
            let h2oFrequencyInt = Int(h2oFrequencyString){
            
            if let dateLastWatered = plant.dateLastWatered {
                let daysSinceLastWatered = Calendar.current.dateComponents([.day], from: dateLastWatered, to: Date()).day!
                
                // Update isWateredCheckBox
                if daysSinceLastWatered == 0 {
                    isWateredCheckBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
                } else {
                    isWateredCheckBox.setImage(UIImage(systemName: "square"), for: .normal)
                }
                
                daysTillNextWater = h2oFrequencyInt - daysSinceLastWatered
            } else {
                daysTillNextWater = 0
            }
            
            // Update waterCountdownLabel
            waterCountdownLabel.text = generatedWaterCountdownString(daysTillNextWater: daysTillNextWater)
        } else {
            waterCountdownLabel.text = "Watering frequency not specified"
        }
    }
    
    internal func generatedWaterCountdownString(daysTillNextWater: Int) -> String {
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
