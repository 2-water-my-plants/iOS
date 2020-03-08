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
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var speciesTextField: UITextField!
    @IBOutlet private weak var h2oFrequencyTextField: UITextField!
    @IBOutlet private weak var lastWateredTextField: UITextField!
    @IBOutlet private weak var nextWateringTextField: UITextField!
    @IBOutlet private weak var enableNotificationsSwitch: UISwitch!
    @IBOutlet private weak var notificationTimeTextField: UITextField!
    @IBOutlet private weak var plantImageView: UIImageView!
    
    // MARK: - IBActions
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: - Save Button Tapped

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let nickName = nameTextField.text else { return }
        
        let species = speciesTextField.text
        let h2oFrequency = h2oFrequencyTextField.text
        let notificationsEnabled = enableNotificationsSwitch.isOn
        let notificationTime = notificationTimeTextField.text
        let localImageData = plantImageView.image?.pngData()

        var dateLastWatered: Date?
        if let dateLastWateredString = lastWateredTextField.text {
            dateLastWatered = dateFormatter.date(from: dateLastWateredString)
        }
        
        if let plant = plant {
            // Update existing plant details
            plantController.updatePlant(plant,
                                        withNickName: nickName,
                                        species: species,
                                        h2oFrequency: h2oFrequency,
                                        image: plant.image,
                                        localImageData: localImageData,
                                        notificationsEnabled: notificationsEnabled,
                                        notificationTime: notificationTime,
                                        dateLastWatered: dateLastWatered)
        } else {
            // Create a new plant
            plantController.createPlant(nickName: nickName,
                                        species: species,
                                        h2oFrequency: h2oFrequency,
                                        localImageData: localImageData,
                                        notificationsEnabled: notificationsEnabled,
                                        notificationTime: notificationTime,
                                        dateLastWatered: dateLastWatered)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Date Picker

    // This code commented out below is a second option for displaying the datepicker.
    // I think it will look nicer than what we have now, but but there are still a few bugs
    // that need to be fixed in the code. I'll come back to this later if there is time.
    
    /*
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
    */
    
    private func setupViews() {
        plantImageView.layer.cornerRadius = plantImageView.bounds.width / 2.0
    }
    
    private func setupDatePicker() {
        h2oFrequencyTextField.addTarget(self, action: #selector(updateNextWateringTextField), for: .editingChanged)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        lastWateredTextField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        self.lastWateredTextField.text = dateFormatter.string(from: selectedDate)
        view.endEditing(true)
        updateNextWateringTextField()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDatePicker()
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
                
                if let h2oFrequency = plant.h2oFrequency {
                    self.h2oFrequencyTextField.text = String(h2oFrequency)
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
                    let dateLastWateredString = self.dateFormatter.string(from: dateLastWatered)
                    self.lastWateredTextField.text = dateLastWateredString
                }
                
                self.updateNextWateringTextField()
                self.updateImage()
            }
        }
    }
    
    private func updateImage() {
        if let plant = plant {
            if let imageData = plant.localImageData {
                // Update image with photo previously chosen from the photo library
                self.plantImageView.image = UIImage(data: imageData)
                
            } else if let imageURL = plant.image {
                // Update image with pictureURL if one has been set in the database
                self.updateImage(from: imageURL)
                
            } else {
                // Update image using default plant image
                self.plantImageView.image = UIImage(named: self.defaultImageName)
            }
        }
    }
    
    private func updateImage(from imageURL: String) {
        self.plantController.fetchImage(at: imageURL) { result in
            do {
                self.plantImageView.image = try result.get()
            } catch {
                print("Error loading image from URL: \"\(imageURL)\": \(error)")
                self.plantImageView.image = UIImage(named: self.defaultImageName)
            }
        }
    }
    
    @objc private func updateNextWateringTextField() {
        if let dateLastWateredString = lastWateredTextField.text,
            let dateLastWatered = dateFormatter.date(from: dateLastWateredString),
            let h2oFrequency = h2oFrequencyTextField.text,
            let h2oFrequencyInt = Int(h2oFrequency),
            let nextWateringDate = Calendar.current.date(byAdding: .day, value: h2oFrequencyInt, to: dateLastWatered) {
            
            nextWateringTextField.text = dateFormatter.string(from: nextWateringDate)
            
        } else {
            nextWateringTextField.text = ""
        }
    }
}

extension PlantDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            plantImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
        return
    }
}
