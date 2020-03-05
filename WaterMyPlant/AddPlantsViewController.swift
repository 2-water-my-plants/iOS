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
    
    var imageData: Data?
    
    var plantController: PlantController!
    
    // MARK: - IBOutlets
    
    // TODO: Wire up IBOutlets to Storyboard
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var speciesTextField: UITextField!
    @IBOutlet private weak var h2oFrequencyTextField: UITextField!
    @IBOutlet private weak var lastWateredTextField: UITextField!
    @IBOutlet private weak var nextWateringTextField: UITextField!
    @IBOutlet private weak var notificationTimeTextField: UITextField!
    @IBOutlet private weak var enableNotificationsSwitch: UISwitch!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var addPhotoButton: UIButton!
    
    // MARK: - IBActions
    
    // TODO: Wire up IBActions to Storyboard
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let nickName = nameTextField.text else { return }
        
        let species = speciesTextField.text
        let h2oFrequency = h2oFrequencyTextField.text
        let notificationsEnabled = enableNotificationsSwitch.isOn
        let notificationTime = notificationTimeTextField.text
        let image = photoImageView.image?.pngData()
        
        var dateLastWatered: Date?
        if let dateLastWateredString = lastWateredTextField.text {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, MMM d, yyyy"
            dateLastWatered = dateFormatter.date(from: dateLastWateredString)
        }
        
        let plantRepresentation = PlantRepresentation(nickName: nickName,
                                                      species: species,
                                                      h2oFrequency: h2oFrequency,
                                                      image: "image",
                                                      id: nil,
                                                      notificationsEnabled: notificationsEnabled,
                                                      notificationTime: notificationTime,
                                                      dateLastWatered: dateLastWatered)
        
        if let plant = plant {
            // Update existing plant details
            plantController.updatePlant(plant, with: plantRepresentation)
        } else {
            // Create a new plant
            plantController.createPlant(from: plantRepresentation)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    // MARK: - UpdateViews
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        CoreDataStack.shared.mainContext.perform {
            self.title = self.plant?.nickName ?? "New Plant"
            
            if let plant = self.plant {
                
                self.nameTextField.text = plant.nickName
                self.speciesTextField.text = plant.species
                
                if let h2oFrequency = plant.h2oFrequency {                    self.h2oFrequencyTextField.text = String(h2oFrequency)
                }
                
                self.enableNotificationsSwitch.isOn = plant.notificationsEnabled
                self.notificationTimeTextField.text = plant.notificationTime
                // Use code below if notificationTime gets changed to a Date() object
                /*
                if let notificationTime = plant.notificationTime {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h:mm a"
                    let timeString = formatter.string(from: notificationTime)
                    self.notificationTimeTextField.text = timeString
                }
                */
                
                if let dateLastWatered = plant.dateLastWatered {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E, MMM d, yyyy"
                    let dateLastWateredString = formatter.string(from: dateLastWatered)
                    self.lastWateredTextField.text = dateLastWateredString
                    
                    if let h2oFrequency = plant.h2oFrequency,
                        let h2oFrequencyInt = Int(h2oFrequency) {
                       
                        if let nextWateringDate = Calendar.current.date(byAdding: .day, value: h2oFrequencyInt, to: dateLastWatered) {
                            
                            let nextWateringTextFieldString = formatter.string(from: nextWateringDate)
                            self.nextWateringTextField.text = nextWateringTextFieldString
                            let date = formatter.date(from: nextWateringTextFieldString)
                        }
                    }
                }
                
                if let imageData = self.imageData {
                    self.photoImageView.image = UIImage(data: imageData)
                } else {
                    self.photoImageView.image = UIImage(named: "green-leaf-plant-with-white-pot")
                }
            }
        }
    }
}

extension AddPlantsViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
        return
    }
}
