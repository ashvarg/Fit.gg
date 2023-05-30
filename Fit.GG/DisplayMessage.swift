//
//  DisplayMessage.swift
//  Fit.GG
//
//  Created by Ashwin George on 24/5/2023.
//

import Foundation

import UIKit

extension UIViewController{
    
    func displayMessage(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
