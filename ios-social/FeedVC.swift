//
//  FeedVC.swift
//  ios-social
//
//  Created by Jean Pierre Matteo on 8/29/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //imagePicker.allowsEditing = true
        
        tableView.estimatedRowHeight = 358
        let query = DataService.ds.REF_POSTS.queryOrderedByChild("date")
        query.observeEventType(.Value, withBlock: { snapshot in
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.posts = self.posts.reverse()
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.requestPostImg?.cancel()
            cell.requestUserImg?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            var userImg: UIImage?
            
            if let url2 = post.userImg {
                userImg = FeedVC.imageCache.objectForKey(url2) as? UIImage
            }
            
            cell.configureCell(post, img: img, userImg: userImg)
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 170
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
        
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        var percentComplete = 0.0
        if let txt = postField.text where txt != "" {
            HUD.show(.Progress)
            progressBar.setProgress(Float(percentComplete), animated: true)
            progressBar.hidden = false
            if let img = imageSelectorImage.image where imageSelected {
                if let uploadData = UIImageJPEGRepresentation(img, 0.9){
                    let imagesRef = DataService.ds.REF_IMAGES.child("posts").child("\(NSUUID().UUIDString).jpg")
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
            } else {
                print("post without image")
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: NSURL?){
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "date": NSDate().description,
            "publisher" : NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl?.absoluteString
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectorImage.image = UIImage(named: "uploadFile")
        imageSelected = false
        
        tableView.reloadData()
        progressBar.hidden = true
        HUD.hide(afterDelay: 2.0)
        HUD.flash(.Success, delay: 1.0)
    }
    
    @IBAction func signOut(sender: UIBarButtonItem) {
        //performSegueWithIdentifier("signOut", sender: nil)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_UID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_USER_NAME)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(KEY_USER_IMAGE)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signOut" {
            if let mainVC = segue.destinationViewController as? ViewController {
                self.dismissViewControllerAnimated(true, completion: nil)
                mainVC.signOut()
            }
        }
    }
}
