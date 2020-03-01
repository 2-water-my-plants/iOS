//
//  SignInViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func loginAfterSignup(with logingRequest: LoginRequest)
}


class SignInViewController: UIViewController {
    
    let loginController = LoginController.shared
    
    @IBOutlet weak var signInUsernameTextField: UITextField!
    
    @IBOutlet weak var signInPasswordTextField: UITextField!
    
    @IBOutlet weak var singInButtonTapped: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func login(_ sender: UIButton) {
        guard let username = self.signInUsernameTextField.text, !username.isEmpty,
            let password = self.signInPasswordTextField.text, !password.isEmpty else { return }
        
        //Create login request
        
        let loginRequest = LoginRequest(username: username, password: password)
        self.login(with: loginRequest)
    }
    
    func login(with loginRequest: LoginRequest) {
        loginController.login(with: loginRequest) { error in
            if let error = error {
                NSLog("Error occured during login: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SigninToDetailViewController", sender: nil)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
