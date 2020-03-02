//
//  SignUpViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/28/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let signupController = SignupNetworking()
    weak var delegate: SignInViewControllerDelegate?
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.phoneNumberTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        guard let username = self.usernameTextField.text, !username.isEmpty,
            let password = self.passwordTextField.text, !password.isEmpty,
            let phoneNumber = self.phoneNumberTextField.text, !phoneNumber.isEmpty else {
                let alert = UIAlertController(title: "Missing some fields", message: "Please try again!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
        
//        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
//            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
//            let phoneNumber = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
//            !phoneNumber.isEmpty,
//            !username.isEmpty,
//            !password.isEmpty else {
//                let alert = UIAlertController(title: "Error Signing up!", message: "Please try again!", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
        }
        
        //Create a signup form
        
        let signupRequest = SignupRequest(username: username, password: password, phoneNumber: phoneNumber)
        
        //disable the signup button after the signup request is created
        
        self.signUpButton.isEnabled = false
        signupController.signUp(with: signupRequest) { (error) in
            DispatchQueue.main.async {
                if let _ = error {
                    let alert = UIAlertController(title: "Houston we have a problem!", message: "Please try again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    //Enable the signup button if there was an error
                    
                    self.signUpButton.isEnabled = true
                    return
                } else {
                    self.delegate?.loginAfterSignup(with: LoginRequest(username: username, password: password))
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
//MARK: Functions:
    
    func setupViews() {
        Utilities.styleTextField(phoneNumberTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleTextField(usernameTextField)
        Utilities.styleFilledButton(signUpButton)
    }
}


extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = self.view.viewWithTag(textField.tag + 1) {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
