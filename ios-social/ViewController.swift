//
//  ViewController.swift
//  ios-social
//
//  Created by Jean Pierre Matteo on 8/26/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseAuth
import PKHUD
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField : UITextField!
    @IBOutlet weak var passField : UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) -> Void in
            if error != nil {
                print("Facebook login failed. Error \(error.localizedDescription)")
                return
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                //print("Successfully logged in with Facebook. \(accessToken)")
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(user)")
                        for profile in (user?.providerData)! {
                            print(profile.uid)
                            print(profile.displayName)
                            print(profile.email)
                            print(profile.providerID)
                        }
                        DataService.ds.createUserIfDoNotExist(user!.uid, providerData: user!.providerData)
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func attempLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passField.text where pwd != "" {
            FIRAuth.auth()?.signInWithEmail(email, password: pwd){ (user, error) in
                if error != nil {
                    if error!.code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd) { (user, error) in
                            if(error != nil) {
                                print(error)
                                self.showAlert("Could not create account", msg: "Problem creating account. Try again")
                            } else {
                                //print(user)
                                FIRAuth.auth()?.signInWithEmail(email, password: pwd) { (user, error) in
                                
                                    if error == nil {
                                        DataService.ds.createUserIfDoNotExist(user!.uid, providerData: user!.providerData)
                                        NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                    }
                                }
                                
                            }
                        }
                    } else {
                        self.showAlert("Could not sign in", msg: "Please check your email and password")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            }
        } else {
            showAlert("Email and Password Required", msg: "You must enter a valid email and a password")
        }
        
    }
    
    func signOut() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_USER_NAME)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_USER_IMAGE)
    }
    

}

