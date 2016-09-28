//
//  PostCell.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 27.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseDatabase

class PostCell: UITableViewCell {
    
    static let ID:String = "PostCell"
    
    @IBOutlet weak var profileImage:UIImageView!
    @IBOutlet weak var showcaseImage:UIImageView!
    @IBOutlet weak var likeItImage:UIImageView!
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var likesLabel:UILabel!
    @IBOutlet weak var descriptionText:UITextView!
    @IBOutlet weak var postedOnLabel:UILabel!
    
    weak var post: Post!
    var request: Request?
    var profileRequest:Request?
    
    private var _currentUserLikesRef:FIRDatabaseReference?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        
        likeItImage.userInteractionEnabled = true
        likeItImage.gestureRecognizers = [tap]
    }
    
    override func drawRect(rect: CGRect) {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        self.showcaseImage.clipsToBounds = true
    }
    
    func likeTapped(sender:UITapGestureRecognizer) {
        print("likeTapped")
        
        DataService.instance.togglePostLike(self.post.postKey)
        
        if let l = self.post.userLikedIt where l == true {
            //true
            self.post.userLikedIt = false;
        } else {
            //false or undefined
            self.post.userLikedIt = true;
        }
        self.updateLikeIt(self.post.userLikedIt)
    }
    func updateLikeIt(like:Bool?){
        if let l = like where l == true {
            self.likeItImage.image = UIImage(named:"heart-full")
        } else {
            self.likeItImage.image = UIImage(named:"heart-empty")
        }
    }
    func configure(data:Post, image:UIImage?) {
        //print("configure(data:\(data.imageUrl), image:\(image))")
        
        _currentUserLikesRef = nil;
        post = data;
        
        self.postedOnLabel.text = ""
        if let timestamp = post.getLocalisedTimestamp(nil) {
            self.postedOnLabel.text = "Posted on: \(timestamp)"
            self.postedOnLabel.hidden = false
        } else {
            self.postedOnLabel.hidden = true
        }
        
        updateLikeIt(self.post.userLikedIt)
        
        if let user = DataService.instance.currentUserData {
            _currentUserLikesRef = user.child(DataService.DB_LIKES)
        }
        //current user like
        if let ref = _currentUserLikesRef {
            if let _ = self.post.userLikedIt {
                //user already stored the value - we are handling it locally now
            } else {
                //listen to changes
                //get update from database once
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                    print("value: \(snapshot.value)")
                    if let likes = snapshot.value as? Dictionary<String, Bool>, _ = likes[self.post.postKey] {
                        print("likes: \(likes)")
                        self.post.userLikedIt = true;
                    } else {
                        self.post.userLikedIt = false;
                    }
                    self.updateLikeIt(self.post.userLikedIt)
                })
            }
        }
        //post user name
        self.userNameLabel.text = ""
        if let name = self.post.authorName {
            //we have already retrieved user name
            self.userNameLabel.text = name
        } else {
            //pull it
            DataService.instance.usersHandle.child(self.post.author).observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                print("value: \(snapshot.value)")
                if let user = snapshot.value as? Dictionary<String, AnyObject> {
                    if let name = user["username"] as? String {
                        print("user: \(name)")
                        self.userNameLabel.text = name
                        self.post.authorName = name
                    }
                    if let profile = user["photo"] as? String {
                        print("profile photo: \(profile)")
                        self.post.authorPicUrl = profile
                    }
                }
            })
        }
        //
        likesLabel.text = "\(data.likes)"
        descriptionText.text = data.postDescription
        
        self.profileImage.image = UIImage(named:"default-user")
        if let profileUrl = post.authorPicUrl {
            if let profile = FeedVC.imageCache.objectForKey(profileUrl) as? UIImage {
                self.profileImage.image = profile
            } else {
                profileRequest = Alamofire.request(.GET, profileUrl).validate(contentType: ["image/*"]).response(completionHandler: { (request:NSURLRequest?, response:NSHTTPURLResponse?, data:NSData?, error:NSError?) in
                    //
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.profileImage.image = img
                        //cache?
                        FeedVC.imageCache.setObject(img, forKey: profileUrl)
                    } else {
                        print(error.debugDescription)
                        self.profileImage.image = UIImage(named:"default-user")
                    }
                })
            }
        }
        
        self.showcaseImage.hidden = false
        if let url = post.imageUrl where !url.isEmpty {
            if image != nil {
                self.showcaseImage.image = image
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request:NSURLRequest?, response:NSHTTPURLResponse?, data:NSData?, error:NSError?) in
                    //
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImage.image = img
                        //cache?
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    } else {
                        print(error.debugDescription)
                        self.showcaseImage.hidden = true
                    }
                })
            }
        } else {
            self.showcaseImage.hidden = true
        }
    }
    
}
