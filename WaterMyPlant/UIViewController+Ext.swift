//
//  UIViewController+Ext.swift
//  WaterMyPlant
//
//  Created by Lambda_School_Loaner_201 on 2/28/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
    
    extension UIViewController {
        
        func presentDJAlertOnMainThread(title: String, message: String, buttonTitle: String) {
            DispatchQueue.main.async {
                let alertVC = DJAlertVC(title: title, message: message, buttonTitle: buttonTitle)
                alertVC.modalPresentationStyle = .overFullScreen
                alertVC.modalTransitionStyle = .crossDissolve
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
