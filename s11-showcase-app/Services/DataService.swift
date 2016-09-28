//
//  DataService.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 22.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let instance = DataService()
    static let DB_USERS = "users"
    static let DB_POSTS = "posts"
    static let DB_LIKES = "likes"
    
    var usersHandle:FIRDatabaseReference {
        return FIRDatabase.database().reference().child(DataService.DB_USERS)
    }
    var postsHandle:FIRDatabaseReference {
        return FIRDatabase.database().reference().child(DataService.DB_POSTS)
    }
    
    var currentUser:FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
    var currentUserId:String? {
        return currentUser?.uid
    }
    
    var currentUserData:FIRDatabaseReference? {
        if let uid = currentUserId {
            return usersHandle.child(uid)
        }
        else
        {
            return nil
        }
    }
    
    func createPost(post:Dictionary<String, AnyObject>) {
        print("createPost(post:\(post))")
        let post = postsHandle.childByAutoId()
            post.setValue(post)
        
        //handle post binding
        if let user = currentUserData {
            user.child(DataService.DB_POSTS).child(post.key).setValue(true)
        }
    }
    
    func togglePostLike(postId:String) {
        if let user = currentUserData {
            let liked = user.child(DataService.DB_LIKES)
            
            print("togglePostLike(\(postId))\n\(user)\n\(liked)")
            liked.runTransactionBlock({ (currentData:FIRMutableData) -> FIRTransactionResult in
                if var likes = currentData.value as? Dictionary<String, Bool> {
                    
                    let countRef = self.postsHandle.child(postId).child(DataService.DB_LIKES)
                    if let _ = likes[postId] {
                        //unlike
                        likes.removeValueForKey(postId)
                        countRef.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                            //unlike                            
                            if var count = snapshot.value as? Int where count > 0 {
                            count -= 1
                            //update
                            countRef.setValue(count)
                        }
                        })
                    } else {
                        //like
                        likes[postId] = true
                        countRef.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                            //like
                            if var count = snapshot.value as? Int {
                                count += 1
                                //update
                                countRef.setValue(count)
                            }
                        })
                    }
                    currentData.value = likes
                }
                return FIRTransactionResult.successWithValue(currentData)
                }, andCompletionBlock: { (error:NSError?, committed:Bool, snapshot:FIRDataSnapshot?) in
                    //
                    if let error = error {
                        print(error.debugDescription)
                    }
            })
        }
    }
    
    func createUser(uid:String, user:Dictionary<String, String>) {
        print("createUser \(uid), \(user)")
        
        usersHandle.child(uid).setValue(user)
    }
}