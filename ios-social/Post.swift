//
//  Post.swift
//  iSocial
//
//  Created by Jean Pierre Matteo on 8/30/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit
import Alamofire

class Post {
    private var _postDescription : String!
    private var _imageUrl: String?
    private var _likes : Int!
    private var _publisher: String!
    private var _postKey: String!
    private var _date: String!
    private var _postRef: FIRDatabaseReference!
    private var _username: String!
    private var _userImg: String?
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var publisher: String {
        return _publisher
    }
    
    var date: String {
        return _date
    }
    
    var username: String {
        return _username
    }
    
    var userImg: String? {
        return _userImg
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._publisher = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        if let date = dictionary["dictionary"] as? String {
            self._date = date
        }
        
        if let publisher = dictionary["publisher"] as? String {
            self._publisher = publisher
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
}