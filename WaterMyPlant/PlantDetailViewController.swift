//
//  PlantDetailViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import UserNotifications

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
    @IBOutlet private weak var enableNotificationSwitch: UISwitch!
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
        let notificationEnabled = enableNotificationSwitch.isOn
        let localImageData = plantImageView.image?.pngData()

        var notificationTime: Date?
        if let notificationTimeString = notificationTimeTextField.text {
            notificationTime = timeFormatter.date(from: notificationTimeString)
        }
        
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
                                        notificationEnabled: notificationEnabled,
                                        notificationTime: notificationTime,
                                        dateLastWatered: dateLastWatered)
            
            scheduleWaterNotification(for: plant)
            
        } else {
            // Create a new plant
            let plant = plantController.createPlant(nickName: nickName,
                                        species: species,
                                        h2oFrequency: h2oFrequency,
                                        localImageData: localImageData,
                                        notificationEnabled: notificationEnabled,
                                        notificationTime: notificationTime,
                                        dateLastWatered: dateLastWatered)
            
            scheduleWaterNotification(for: plant)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func scheduleWaterNotification(for plant: Plant) {
        // Determine whether a notification should be scheduled
        guard plant.notificationEnabled == true,
            let daysTillNextWater = plant.daysTillNextWater,
            let notificationTimeInSeconds = plant.notificationTimeInSeconds else { return }
        
        let secondsTillNotification = (daysTillNextWater * 86400) + notificationTimeInSeconds - currentTimeInSeconds()
        guard secondsTillNotification > 0 else { return }
        
        // Schedule notification
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let plantName = plant.nickName ?? "plant"
        content.title = "Reminder"
        content.body = "It's time to water your \(plantName)!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsTillNotification), repeats: false)
        
        let request = UNNotificationRequest(identifier: "Reminder", content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("Error = \(error?.localizedDescription ?? "error local notification")")
            } else {
                print("Notification scheduled for \(secondsTillNotification) seconds from now.")
            }
        }
    }
    
    private func currentTimeInSeconds() -> Int {
        let currentDate = Date()
        let beginningOfDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate)!
        return Int(currentDate.timeIntervalSince(beginningOfDay))
    }
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateViews()
        //showDateChooserAlert()
    }
    
    // MARK: - Setup Views

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
        h2oFrequencyTextField.addTarget(self, action: #selector(updateNextWateringTextField), for: .editingChanged)
        setupLastWateredDatePicker()
        setupNotificationTimePicker()
    }
    
    // LastWateredDate Picker
    private func setupLastWateredDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(lastWateredDateChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        lastWateredTextField.inputView = datePicker
    }
    
    @objc func lastWateredDateChanged(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        self.lastWateredTextField.text = dateFormatter.string(from: selectedDate)
        updateNextWateringTextField()
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
        updateNextWateringTextField()
    }
    
    // NotificationTime Picker
    private func setupNotificationTimePicker() {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(notificationTimeChanged), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        notificationTimeTextField.inputView = timePicker
    }
    
    @objc func notificationTimeChanged(timePicker: UIDatePicker) {
        let selectedTime = timePicker.date
        self.notificationTimeTextField.text = timeFormatter.string(from: selectedTime)
    }

    // MARK: - Update Views
    
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
                
                self.enableNotificationSwitch.isOn = plant.notificationEnabled
                self.notificationTimeTextField.text = plant.notificationTimeString
                
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
