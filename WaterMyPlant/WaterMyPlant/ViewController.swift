//
//  ViewController.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/26/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var roundedRectView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        
        let videoOption = 5
        switch videoOption {
        case 1: configureTopScreenVideo(named: "watering-house-plant", fileType: "mov")
        case 2: configureFullScreenVideo(named: "green-leaves-in-rain", fileType: "mp4")
        case 3: configureTopScreenVideo(named: "blue-water-droplet", fileType: "mp4")
        case 4: configureTopScreenVideo(named: "water-droplet", fileType: "mp4")
        case 5: configureTopScreenVideo(named: "flowers-blooming", fileType: "mp4")
        default:
            break
        }
    }
    
    // MARK: - Private Methods

    private func configureViews() {
        navigationController?.isNavigationBarHidden = true
        roundedRectView.layer.cornerRadius = 20.0
        signInButton.layer.cornerRadius = 8.0
        createAccountButton.layer.cornerRadius = 8.0
    }
    
    private func configureTopScreenVideo(named fileName: String, fileType: String) {
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: fileType)!)
        let player = AVPlayer(url: path)
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
    
    private func configureFullScreenVideo(named fileName: String, fileType: String) {
        roundedRectView.backgroundColor = UIColor(red: 0.9882352941, green: 0.9921568627, blue: 0.9921568627, alpha: 0.86)
        videoView.isHidden = true
        let videoView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: view.bounds.size))
        view.addSubview(videoView)
        view.sendSubviewToBack(videoView)
        
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: fileType)!)
        let player = AVPlayer(url: path)
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

