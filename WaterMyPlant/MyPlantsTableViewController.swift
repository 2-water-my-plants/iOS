//
//  MyPlantsTableViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 3/1/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import CoreData

class MyPlantsTableViewController: UITableViewController {

    // MARK: - Properties

    let plantController = PlantController()
    var user: User?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Plant> = {
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(key: "dateLastWatered", ascending: true),
//            NSSortDescriptor(key: "nickName", ascending: true)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: moc,
                                             sectionNameKeyPath: nil, // "dateLastWatered",
                                             cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error performing fetch for frc: \(error)")
        }
        
        return frc
    }()
    
    // MARK: - Initializers

    override init(style: UITableView.Style) {
        super.init(style: style)
        if let userId = user?.id {
            plantController.userId = String(userId)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if let userId = user?.id {
            plantController.userId = String(userId)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        plantController.fetchPlantsFromServer { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 89
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        //animateTable()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as? MyPlantsTableViewCell else { return UITableViewCell() }

        cell.delegate = self
        cell.plant = fetchedResultsController.object(at: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name.capitalized
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let plant = fetchedResultsController.object(at: indexPath)
            plantController.deletePlant(plant)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            
        case "ShowPlantDetailSegue":
            guard let detailVC = segue.destination as? PlantDetailViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let plant = fetchedResultsController.object(at: indexPath)
            detailVC.plant = plant
            detailVC.title = plant.nickName
            detailVC.plantController = plantController
            
        case "ShowAddPlantSegue":
            guard let detailVC = segue.destination as? PlantDetailViewController else { return }
            detailVC.plantController = plantController
            
        case "ProfileSegue":
            guard let profileVC = segue.destination as? ProfileViewController else { return }
            profileVC.user = user
            
        default:
            break
        }
    }
    
    // MARK: - Animations

    func animateTable() {
        tableView.reloadData()
        let cells = tableView.visibleCells
        
        let tableViewHeight = tableView.bounds.size.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter = 0
        for cell in cells {
            UIView.animate(withDuration: 1.75,
                           delay: Double(delayCounter) * 0.2,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .curveEaseOut,
                           animations: { cell.transform = CGAffineTransform.identity },
                           completion: nil)
            
            delayCounter += 1
        }
    }
}

// MARK: - MyPlantsTVCell Delegate

extension MyPlantsTableViewController: MyPlantsTableViewCellDelegate {
    func isWateredCheckBoxWasChecked(for plant: Plant) {
        plantController.plantWasWateredToday(plant: plant)
    }
    
    func isWateredCheckBoxWasUnchecked(for plant: Plant) {
        plantController.undoPlantWasWateredToday(plant: plant)
    }
}

// MARK: - FRC Delegate

extension MyPlantsTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
            let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
    
    
}
