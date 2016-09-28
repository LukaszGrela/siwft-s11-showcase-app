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
    
    weak var post: Post!
    var request: Request?
    
    private var _postRef:FIRDatabaseReference?
    
    var likeChangeEventId:UInt?
    
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
        
        self.post.userLikedIt = !self.post.userLikedIt;
        self.updateLikeIt(self.post.userLikedIt)
    }
    func updateLikeIt(like:Bool){
        if like {
            self.likeItImage.image = UIImage(named:"heart-full")
        } else {
            self.likeItImage.image = UIImage(named:"heart-empty")
        }
    }
    func configure(data:Post, image:UIImage?) {
        print("configure(data:\(data.imageUrl), image:\(image))")
        
        //get rid of previous observer (if not consumed)
        if let postRef = _postRef, id = likeChangeEventId {
            postRef.removeObserverWithHandle(id)
        }
        
        
        _postRef = nil;
        post = data;
        
        updateLikeIt(self.post.userLikedIt)
        
        //listen to changes
        if let user = DataService.instance.currentUserData {
            _postRef = user.child(DataService.DB_LIKES)
        }
        /*
        if let postRef = _postRef {
            postRef.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
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
        */
        likesLabel.text = "\(data.likes)"
        descriptionText.text = data.postDescription
        
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
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
