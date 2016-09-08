//
//  DataService.swift
//  ios-social
//
//  Created by Jean Pierre Matteo on 8/29/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import Alamofire

class DataService {
    static let ds = DataService()
    
    private var _DB = FIRDatabase.database().reference()
    private var _STORAGE = FIRStorage.storage().reference()
    
    var DB: FIRDatabaseReference {
        return _DB
    }
    
    var STORAGE: FIRStorageReference {
        return _STORAGE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _DB.child("users")
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _DB.child("posts")
    }
    
    var REF_IMAGES: FIRStorageReference {
        return _STORAGE.child("images")
    }
    
    var REF_CURRENT_USER: FIRDatabaseReference {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        return REF_USERS.child(uid)
    }
    
    var REF_CURRENT_USER_LIKES: FIRDatabaseReference {
        return REF_CURRENT_USER.child("likes")
    }
    
    var REF_USERNAMES: FIRDatabaseReference {
        return _DB.child("usernames")
    }
    
    var PROFILE_PICTURE: UIImage? {
        get {
            if let imgPath = NSUserDefaults.standardUserDefaults().valueForKey(KEY_USER_IMAGE) as? String {
                return imageForPath(imgPath)
            }
            return nil
        }
        
        set(img) {
            NSUserDefaults.standardUserDefaults().setValue(saveImageAndCreatePath(img!), forKey: KEY_USER_IMAGE)
        }
    }
    
    func createUserIfDoNotExist(uid: String, providerData: [FIRUserInfo]) {
        REF_USERS.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in

            if !snapshot.hasChild(uid) {
                self.createFirebaseUser(uid, providerData: providerData)
            }
        })
    }
    
    func createFirebaseUser(uid: String, providerData: [FIRUserInfo]){
        var data = [String: String]()
        
        for profile in providerData {
            data["provider"] = profile.providerID
            if let email = profile.email {
                data["email"] = email
            }
        }
        REF_USERS.child("\(uid)").updateChildValues(data)
        print(">>>>>>>>>>>>>>>>>>>>> User \(uid) created.")
        
    }
    
    func saveImageAndCreatePath(image: UIImage) -> String {
        let imgData = UIImagePNGRepresentation(image)
        let imgPath = "image\(NSDate.timeIntervalSinceReferenceDate()).png"
        let fullPath = documentsPathForFileName(imgPath)
        imgData?.writeToFile(fullPath, atomically: true)
        return imgPath
    }
    
    func imageForPath(path: String) -> UIImage? {
        let fullPath = documentsPathForFileName(path)
        let image = UIImage(named: fullPath)
        return image
    }
    
    func documentsPathForFileName(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fullPath = paths[0] as NSString
        return fullPath.stringByAppendingPathComponent(name)
    }
    
    
}