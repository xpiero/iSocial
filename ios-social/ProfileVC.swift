//
//  ProfileVC.swift
//  iSocial
//
//  Created by Jean Pierre Matteo on 9/2/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg : UIImageView!
    @IBOutlet weak var usernameTextField: MaterialTextField!
    @IBOutlet weak var progressBar: UIProgressView!
    var imagePicker: UIImagePickerController!
    var imagePicked = false
    var uid: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImg.image = image
        imagePicked = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer)
    {
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func save(sender: UIButton) {
        if let username = usernameTextField.text where username != "" {
            
            /* SAVING USERNAME */
            
            DataService.ds.REF_USERNAMES.child(username.lowercaseString).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
                if let user = currentData.value as? String {
                    print(">>>>>>>>>>>> Username already exists: \(user)")
                    return FIRTransactionResult.abort()
                }else{
                    currentData.value = self.uid
                    return FIRTransactionResult.successWithValue(currentData)
                }
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                    self.showAlert("Error", msg: error.localizedDescription)
                } else if (committed) {
                    if let previousUsername = NSUserDefaults.standardUserDefaults().valueForKey(KEY_USER_NAME) as? String {
                        DataService.ds.REF_USERNAMES.child(previousUsername).removeValue()
                    }
                    DataService.ds.REF_CURRENT_USER.child(KEY_USER_NAME).setValue(username.lowercaseString)
                    NSUserDefaults.standardUserDefaults().setValue(username, forKey: KEY_USER_NAME)
                    if !self.imagePicked {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                }
            }
            
            /* SAVING PICTURE */
            uploadImage()
            
        } else {
            showAlert("Username Required", msg: "Please input a valid username")
        }
    }
    
    func uploadImage() {
        if let img = profileImg.image where imagePicked {
            HUD.show(.Progress)
            var percentComplete = 0.0
            progressBar.setProgress(Float(percentComplete), animated: true)
            progressBar.hidden = false
            
            if let uploadData = UIImageJPEGRepresentation(img, 0.9){
                let imagesRef = DataService.ds.REF_IMAGES.child("profiles").child("\(uid).jpg")
                print("Starting to upload!")
                let uploadTask = imagesRef.putData(uploadData, metadata: nil) { metadata, err in
                    if err != nil {
                        print("Error uploading image")
                        HUD.hide(afterDelay: 2.0)
                        HUD.flash(.Error, delay: 1.0)
                    } else {
                        print("Image uploaded: \(metadata?.downloadURL())")
                        let downloadURL = (metadata?.downloadURL())!
                        self.postToFirebase(downloadURL)
                    }
                }
                uploadTask.observeStatus(.Progress) { snapshot in
                    //print(snapshot.progress)
                    percentComplete = (snapshot.progress?.fractionCompleted)!
                    print(percentComplete)
                    self.progressBar.setProgress(Float(percentComplete), animated: true)
                }
            }
        }

    }
    
    func postToFirebase(imgUrl: NSURL?){
        var user = Dictionary<String, AnyObject>()
        
        if imgUrl != nil {
            user["\(KEY_USER_IMAGE)"] = imgUrl?.absoluteString
        }
        
        let currentUser = DataService.ds.REF_CURRENT_USER
        currentUser.updateChildValues(user)
        
        imagePicked = false
        let imgPath = DataService.ds.saveImageAndCreatePath(profileImg.image!)
        NSUserDefaults.standardUserDefaults().setValue(imgPath, forKey: KEY_USER_IMAGE)
        progressBar.hidden = true
        HUD.hide(afterDelay: 2.0)
        HUD.flash(.Success, delay: 1.0)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            if NSUserDefaults.standardUserDefaults().valueForKey(KEY_USER_NAME) != nil {
                super.willMoveToParentViewController(parent)
            } else {
                showAlert("Username Required", msg: "Please input a valid username")
            }

        }
    }
    
    func loadData() {
        uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        if let username = NSUserDefaults.standardUserDefaults().valueForKey(KEY_USER_NAME) as? String {
            usernameTextField.text = username
        } else {
            self.navigationItem.hidesBackButton = true
        }
        
        if let imagePath = NSUserDefaults.standardUserDefaults().valueForKey(KEY_USER_IMAGE) as? String {
            if let image = DataService.ds.imageForPath(imagePath) {
                profileImg.image = image
            }
        }
    }
}
