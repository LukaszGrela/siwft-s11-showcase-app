//
//  Post.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 28.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//

import Foundation

class Post {
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _userLikedIt:Bool = false
    
    var postDescription:String {
        return _postDescription
    }
    var imageUrl:String? {
        return _imageUrl
    }
    var likes:Int {
        return _likes
    }
    var userName:String {
        return _username
    }
    var postKey:String {
        return _postKey
    }
    
    var userLikedIt:Bool {
        get {
            return _userLikedIt
        }
        set {
            _userLikedIt = newValue
        }
    }
    
    init(description:String, imageUrl:String?, username:String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = username
        
    }
    init(key:String, data:Dictionary<String, AnyObject>) {
        self._postKey = key
        if let likes = data["likes"] as? Int {
            self._likes = likes
        }
        if let imgUrl = data["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        if let desc = data["description"] as? String {
            self._postDescription = desc
        }
    }
}