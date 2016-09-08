//
//  VC Extension.swift
//  iSocial
//
//  Created by Jean Pierre Matteo on 9/6/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title : String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
