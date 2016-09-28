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
    private var _authorName: String?
    private var _authorPicUrl: String?
    private var _author: String!
    private var _postKey: String!
    private var _userLikedIt:Bool?
    private var _timestamp:Double?
    
    var postDescription:String {
        return _postDescription
    }
    var imageUrl:String? {
        return _imageUrl
    }
    var likes:Int {
        return _likes
    }
    /// retrieved author name
    var authorName:String? {
        get {
            return _authorName
        }
        set {
            _authorName = newValue
        }
    }
    /// retrieved author pic url
    var authorPicUrl:String? {
        get {
            return _authorPicUrl
        }
        set {
            _authorPicUrl = newValue
        }
    }
    /// author key
    var author:String {
        return _author
    }
    var postKey:String {
        return _postKey
    }
    
    var userLikedIt:Bool? {
        get {
            return _userLikedIt
        }
        set {
            _userLikedIt = newValue
        }
    }
    
    var timestamp:Double? {
        return _timestamp
    }
    
    func getLocalisedTimestamp(format:String?) -> String? {
        print("getLocalisedTimestamp(format:String?)")
        if let t = timestamp {
            let dateFormat = NSDateFormatter()
            if let f = format {
                dateFormat.dateFormat = f
            } else {
                dateFormat.timeStyle = .ShortStyle
                dateFormat.dateStyle = .ShortStyle
            }
            dateFormat.timeZone = NSTimeZone.localTimeZone()
            dateFormat.locale = NSLocale.currentLocale();
            let date = NSDate(timeIntervalSince1970: t)
            let strDate =  dateFormat.stringFromDate(date);
            return strDate
        }
        else {
            return nil
        }
    }
    
    func update(data:Dictionary<String, AnyObject>) {
        
        if let likes = data["likes"] as? Int {
            self._likes = likes
        }
        if let imgUrl = data["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        if let desc = data["description"] as? String {
            self._postDescription = desc
        }
        if let author = data["author"] as? String {
            if author != _author {
                //changed? - clear name
                _authorName = nil;
            }
            _author = author
        } else {
            _authorName = nil;
        }
        if let stamp = data["timestamp"] as? Double {
            _timestamp = stamp
        }
        
    }
    
    init(description:String, imageUrl:String?, username:String) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._authorName = username
        
    }
    init(key:String, data:Dictionary<String, AnyObject>) {
        self._postKey = key
        update(data)
    }
}