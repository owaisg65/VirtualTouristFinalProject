//
//  Alerts.swift
//  VirtualTourist
//
//  Created by Owais Gaffas on 05/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

extension UIViewController {

    func alerts(errorMessage: String?) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
