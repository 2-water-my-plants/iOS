//
//  ProfileViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 3/7/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var user: User?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

        // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToChangePassword" {
            guard let changePasswordVC = segue.destination as? UserUpdateViewController else { return }
            
            changePasswordVC.user = user
        }
    }
}
