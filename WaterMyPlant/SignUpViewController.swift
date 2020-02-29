//
//  SignUpViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/28/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupViews()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !email.isEmpty,
            !password.isEmpty else {
                self.presentDJAlertOnMainThread(title: "Error Signing Up!", message: DJError.emptyEmailAndPasswordSignUp.rawValue, buttonTitle: "Ok")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!.code) {
                    switch errCode {
                    case .invalidEmail:
                        self.presentDJAlertOnMainThread(title: "Error Signing Up!", message: DJError.invalidEmail.rawValue, buttonTitle: "Ok")
                    case .emailAlreadyInUse:
                        self.presentDJAlertOnMainThread(title: "Error Signing Up!", message: DJError.emailAlreadyInUse.rawValue, buttonTitle: "Ok")
                    case .emailTextField.text = ""
                    default:
                        self.presentDJAlertOnMainThread(title: "Error Signing Up!", message: DJError.generalSignUpError.rawValue, buttonTitle: "Ok")
                    }
                }
            } else {
                Auth.auth().signIn(withEmail: email, password: password) { _, error in
                    if error == nil {
                        guard let PlantsSelectorVC = self.storyboard?.instantiateViewController(identifier: "PlantsSelectorVC") as? PlantsSelectorViewController else { return }
                        self.navigationController?.pushViewController(PlantsSelectorViewController, animated: true)
                        self.view.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
//MARK: Functions:
    
    func setupViews() {
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(usernameTextField)
        Utilities.styleFilledButton(signUpButton)
    }
}
