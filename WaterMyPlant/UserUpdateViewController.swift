//
//  UserUpdateViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 3/7/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

class UserUpdateViewController: UIViewController {
    
    var user: User?
    
    @IBOutlet private weak var newPasswordField: UITextField!
    
    @IBAction func passwordTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        let alert = UIAlertController(title: "Success", message: "Password has been updated!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done!", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        guard let newPassword = newPasswordField.text else { return }
        updateInformation(with: newPassword) { error in
            
        }
    }
    
    func updateInformation(with password: String, completion: @escaping (Error?) -> Void) {
        
        let baseURL = URL(string: "https://webpt9-water-my-plants.herokuapp.com/api")!
        
        guard let user = user, let id = user.id, let token = LoginController.shared.token?.token else { return }
        let requestURL = baseURL.appendingPathComponent("/auth/\(id)")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        
        let json = """
        {
        "password": "\(password)"
        }
        """
        let jsonData = json.data(using: .utf8)
        guard let unwrapped = jsonData else {
            print("No data!")
            return
        }
        request.httpBody = unwrapped
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                print("Fail")
                
                
            } else {
                print("Success")
                
            }
            
            
        }.resume()
    }
}
