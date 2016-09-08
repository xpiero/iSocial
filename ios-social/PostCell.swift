//
//  PostCell.swift
//  ios-social
//
//  Created by Jean Pierre Matteo on 8/29/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseDatabase

class PostCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var requestPostImg: Request?
    var requestUserImg: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        likeImage.bounds = CGRectInset(likeImage.frame, 10, 10);
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        postImage.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?, userImg: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_CURRENT_USER_LIKES.child(post.postKey)
        
        self.descriptionTxt.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        self.postImage.hidden = true
        if post.imageUrl != nil {
            if img != nil {
                self.postImage.image = img
                self.postImage.hidden = false
            } else {
                requestPostImg = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.postImage.image = img
                        self.postImage.hidden = false
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    } else {
                        print("Could not download post img: \(err)")
                    }
                })
            }
        }
        
       DataService.ds.REF_USERS.child(post.publisher).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let user = snapshot.value as? [String: AnyObject] {

                if let username = user["\(KEY_USER_NAME)"] as? String {
                    self.username.text = username
                }
                
                if userImg != nil {
                    self.profileImg.image = userImg
                } else {
                    if let img = user["\(KEY_USER_IMAGE)"] as? String {
                        self.requestUserImg = Alamofire.request(.GET, img).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                            if err == nil {
                                let image = UIImage(data: data!)!
                                self.profileImg.image = image
                                FeedVC.imageCache.setObject(img, forKey: img)
                            } else {
                                print("Could not download profile img: \(err)")
                                self.profileImg.image = UIImage(named: "profile.jpg")
                            }
                        })
                    } else {
                        self.profileImg.image = UIImage(named: "profile.jpg")
                    }
                }
                
            }
        })

        
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if ((snapshot.value as? NSNull) != nil) {
                self.likeImage.image = UIImage(named: "heart-empty-1")
            } else {
                self.likeImage.image = UIImage(named: "heart-full-1")
            }
        })
    }

    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if ((snapshot.value as? NSNull) != nil) {
                self.likeImage.image = UIImage(named: "heart-full-1")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty-1")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
}
