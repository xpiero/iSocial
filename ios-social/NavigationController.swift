//
//  NavigationController.swift
//  iSocial
//
//  Created by Jean Pierre Matteo on 9/6/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import UIKit
import Firebase

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DataService.ds.REF_CURRENT_USER.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let user = snapshot.value as? [String: AnyObject] {
                if let username = user["\(KEY_USER_NAME)"] as? String {
                    NSUserDefaults.standardUserDefaults().setValue(username, forKey: KEY_USER_NAME)
                } else {
                    self.performSegueWithIdentifier("toProfile", sender: nil)
                }
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
