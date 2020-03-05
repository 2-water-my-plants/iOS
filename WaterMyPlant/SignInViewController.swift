//
//  SignInViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit


protocol SignInViewControllerDelegate: AnyObject {

    func loginAfterSignup(with logingRequest: LoginRequest)
}


class SignInViewController: UIViewController {
    
    let loginController = LoginController.shared
    
    @IBOutlet private weak var signInUsernameTextField: UITextField!
    
    @IBOutlet private weak var signInPasswordTextField: UITextField!
    
    @IBOutlet private weak var singInButtonTapped: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
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
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(title: "Error Occured", message: "Check your Username and Password and try again!", preferredStyle: .alert)
                    alert.addAction((UIAlertAction(title: "You Got it!", style: .default, handler: nil)))
                    self.present(alert, animated: true, completion: nil)
                    NSLog("Error occured during login: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "SigninToDetailViewController", sender: nil)
                    }

                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignupSegue" {
            guard let vc = segue.destination as? SignUpViewController else { return }
            vc.delegate = self
        }
    }
}

extension SignInViewController: SignInViewControllerDelegate {
    func loginAfterSignup(with logingRequest: LoginRequest) {
        DispatchQueue.main.async {
            self.login(with: logingRequest)
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = self.view.viewWithTag(textField.tag + 1) {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

}
