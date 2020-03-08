//
//  SignInViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/29/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import AVKit


protocol SignInViewControllerDelegate: AnyObject {

    func loginAfterSignup(with logingRequest: LoginRequest)
}


class SignInViewController: UIViewController {
    
    // MARK: - Properties

    let cornerRadius: CGFloat = 20.0
    let bgVideoName = "green-leaves-in-rain"
    let bgVideoFileType = "mp4"
    let backupBGImageName = "green-leafed-plant-background"
    let signInBGSheetColor = UIColor(red: 0.9882352941, green: 0.9921568627, blue: 0.9921568627, alpha: 0.86)
    
    let loginController = LoginController.shared
    
    @IBOutlet private weak var signInUsernameTextField: UITextField!
    @IBOutlet private weak var signInPasswordTextField: UITextField!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var createAccountButton: UIButton!
    @IBOutlet private weak var signInBGSheetView: UIView!
    
    // Can this outlet be deleted? I created a new outlet to this button above.
    // This one didn't appear to be connected to anything, but I wasn't sure...
    @IBOutlet private weak var singInButtonTapped: UIButton!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureFullScreenVideo(named: bgVideoName, fileType: bgVideoFileType)
    }
    
    // MARK: - Methods

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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignupSegue" {
            guard let vc = segue.destination as? SignUpViewController else { return }
            vc.delegate = self
        } else if segue.identifier == "SigninToDetailViewController" {
            guard let navController = segue.destination as? UINavigationController,
                let plantsTableVC = navController.topViewController as? MyPlantsTableViewController else { return }
            plantsTableVC.user = loginController.user
        } else if segue.identifier == "SigninToDetailViewController" {
            guard let navController2 = segue.destination as? UINavigationController,
            let plantsTableVC2 = navController2.topViewController as? MyPlantsTableViewController else { return }
            plantsTableVC2.user = loginController.user
        }
    }
    
    // MARK: - Configure Views

    private func configureViews() {
        navigationController?.isNavigationBarHidden = true
        signInBGSheetView.layer.cornerRadius = 20.0
        signInButton.layer.cornerRadius = 8.0
        createAccountButton.layer.cornerRadius = 8.0
    }
    
    private func configureFullScreenVideo(named fileName: String, fileType: String) {
        signInBGSheetView.backgroundColor = signInBGSheetColor.withAlphaComponent(0.86)
        //videoView.isHidden = true
        let videoView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size))
        view.addSubview(videoView)
        view.sendSubviewToBack(videoView)
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("Error: could not find \(fileName).\(fileType) in Bundle.main.")
            setupBackupBGImage()
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        player.isMuted = true
        
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = videoView.frame
        videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        player.play()
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.videoDidPlayToEnd(_:)),
                                               name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"),
                                               object: player.currentItem)
    }
    
    @objc func videoDidPlayToEnd(_ notification: Notification) {
        guard let player: AVPlayerItem = notification.object as? AVPlayerItem else { return }
        player.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    private func setupBackupBGImage() {
        signInBGSheetView.backgroundColor = signInBGSheetColor.withAlphaComponent(1.0)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size))
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: backupBGImageName)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
}

// MARK: - Delegate Extensions

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
