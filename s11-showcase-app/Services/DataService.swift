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
        let postHandle = postsHandle.childByAutoId()
            postHandle.setValue(post)
        
        //handle post binding
        if let user = currentUserData {
            user.child(DataService.DB_POSTS).child(postHandle.key).setValue(true)
        }
    }
    
    func togglePostLike(postId:String) {
        if let user = currentUserData {
            let liked = user.child(DataService.DB_LIKES)
            
            print("togglePostLike(\(postId))\n\(user)\n\(liked)")
            liked.runTransactionBlock({ (currentData:FIRMutableData) -> FIRTransactionResult in
                print("transactionBlock:\(currentData.value)")
                if var likes = currentData.value as? Dictionary<String, Bool> {
                    
                    
                    if let _ = likes[postId] {
                        //unlike
                        likes.removeValueForKey(postId)
                        
                    } else {
                        //like
                        likes[postId] = true
                                            }
                    currentData.value = likes
                } else {
                    //NULL
                    let likes:Dictionary<String, Bool> = [postId:true]
                    
                    currentData.value = likes
                }
                return FIRTransactionResult.successWithValue(currentData)
                }, andCompletionBlock: { (error:NSError?, committed:Bool, snapshot:FIRDataSnapshot?) in
                    //
                    print("transactionCompletion:\(committed), \(snapshot!.value)")
                    if let error = error {
                        print(error.debugDescription)
                    } else {
                        if committed {
                            let value = snapshot!.value
                            let dict = snapshot!.value as? Dictionary<String, Bool>
                            let countRef = self.postsHandle.child(postId).child(DataService.DB_LIKES)
                            countRef.observeSingleEventOfType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                                //like
                                if var count = snapshot.value as? Int {
                                    print("likes count: \(count)")
                                    if !self.isNotNull(value) || (self.isNotNull(dict) && dict![postId] == nil) {
                                        //removed
                                        count -= 1
                                    } else {
                                        //added
                                        count += 1
                                    }
                                    //update
                                    print("updated count: \(count)")
                                    countRef.setValue(count)
                                }
                            })
                        }
                    }
            })
        }
    }
    
    func createUser(uid:String, user:Dictionary<String, String>) {
        print("createUser \(uid), \(user)")
        
        usersHandle.child(uid).setValue(user)
    }
    
    
    
    func isNotNull(object:AnyObject?) -> Bool {
        guard let object = object else {
            return false
        }
        return (isNotNSNull(object) && isNotStringNull(object))
    }
    
    func isNotNSNull(object:AnyObject) -> Bool {
        return object.classForCoder != NSNull.classForCoder()
    }
    
    func isNotStringNull(object:AnyObject) -> Bool {
        if let object = object as? String where object.uppercaseString == "NULL" {
            return false
        }
        return true
    }
}