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
    
    @IBOutlet private weak var roundedRectView: UIView!
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var createAccountButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        
        // Comment out the following line to replace the video
        // with the still photo per the original design
        configureVideo()
    }
    
    // MARK: - Private Methods

    private func configureViews() {
        navigationController?.isNavigationBarHidden = true
        roundedRectView.layer.cornerRadius = 20.0
        signInButton.layer.cornerRadius = 8.0
        createAccountButton.layer.cornerRadius = 8.0
    }
    
    private func configureVideo() {
        // Video source: https://vimeo.com/209497584
        // This video is for testing only
        // We did not obtain legal permission to use this video in our app
        let videoView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 264))
        videoView.contentMode = .scaleAspectFit
        view.addSubview(videoView)
        
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "716971753", ofType: "mp4")!)
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
    
    override var prefersStatusBarHidden: Bool { true }
    
}
