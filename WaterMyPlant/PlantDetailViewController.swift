//
//  PlantDetailViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {

    // MARK: - Properties

    var plantController: PlantController!
    
    var plant: Plant? {
        didSet {
            updateViews()
        }
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d, yyyy"
        return dateFormatter
    }()
    
    let timeFormatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter
    }()
    
    let defaultImageName = "green-leaf-plant-with-white-pot"
    var imageData: Data?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var speciesTextField: UITextField!
    @IBOutlet weak var h2oFrequencyTextField: UITextField!
    @IBOutlet weak var lastWateredTextField: UITextField!
    @IBOutlet weak var nextWateringTextField: UITextField!
    @IBOutlet weak var enableNotificationsSwitch: UISwitch!
    @IBOutlet weak var notificationTimeTextField: UITextField!
    @IBOutlet weak var plantImageView: UIImageView!
    
    // MARK: - IBActions
    
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
        let image = plantImageView.image?.pngData()
        
        var dateLastWatered: Date?
        if let dateLastWateredString = lastWateredTextField.text {
            dateLastWatered = dateFormatter.date(from: dateLastWateredString)
        }
        
        let plantRepresentation = PlantRepresentation(nickName: nickName,
                                                      species: species,
                                                      h2oFrequency: h2oFrequency,
                                                      image: defaultImageName,
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
    
    private func showDateChooserAlert() {
        let dateChooserAlert = UIAlertController(title: "When was this plant last watered?",
                                                 message: "Select Date",
                                                 preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        dateChooserAlert.view.addSubview(datePicker)
        dateChooserAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
            let selectedDate = datePicker.date
            self.lastWateredTextField.text = self.dateFormatter.string(from: selectedDate)
        }))
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalTo: dateChooserAlert.view.heightAnchor, constant: -40)
        ])
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: dateChooserAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 300)
        dateChooserAlert.view.addConstraint(height)
        
        self.present(dateChooserAlert, animated: true, completion: nil)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        self.lastWateredTextField.text = dateFormatter.string(from: selectedDate)
        view.endEditing(true)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        plantImageView.layer.cornerRadius = plantImageView.bounds.width / 2.0
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        lastWateredTextField.inputView = datePicker
        
        updateViews()
        //showDateChooserAlert()
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
                        }
                    }
                }
                
                if let imageData = self.imageData {
                    self.plantImageView.image = UIImage(data: imageData)
                } else {
                    self.plantImageView.image = UIImage(named: self.defaultImageName)
                }
            }
        }
    }
}

extension PlantDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            plantImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
        return
    }
}
