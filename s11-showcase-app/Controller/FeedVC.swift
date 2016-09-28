//
//  FeedVC.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 27.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//


import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    static var imageCache = NSCache()
    
    var imagePicker:UIImagePickerController!
    var imageSelected = false
    
    @IBOutlet weak var imageSelectorImage: UIImageView!
    
    @IBOutlet weak var postField: MaterialTextField!
    
    @IBOutlet weak var tableView:UITableView!
    var tableData:[Post] = [Post]()
    
    var postsEventChangedHandler:UInt!
    var postsEventAddedHandler:UInt!
    var postsEventMovedHandler:UInt!
    var postsEventRemovedHandler:UInt!
    var postsEventValueChangedHandler:UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 380
        
        postsEventChangedHandler = DataService.instance.postsHandle.observeEventType(FIRDataEventType.ChildChanged) { (snapshot:FIRDataSnapshot) in
            //
            print("ChildChanged, snapshot:\(snapshot)")
            //
            //
            let location = self.tableData.indexOf({ (p:Post) -> Bool in
                //
                return p.postKey == snapshot.key
                //
            })
            //
            if let index = location, let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                let post = self.tableData[index]
                
                post.update(postDict)
                
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        postsEventAddedHandler = DataService.instance.postsHandle.observeEventType(FIRDataEventType.ChildAdded) { (snapshot:FIRDataSnapshot) in
            //
            print("ChildAdded, snapshot:\(snapshot)")
            //
            
            
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.tableData.append(Post(key: snapshot.key, data: postDict))
                
                self.tableView.insertRowsAtIndexPaths([NSIndexPath.init(forRow: self.tableData.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }

        }
        postsEventMovedHandler = DataService.instance.postsHandle.observeEventType(FIRDataEventType.ChildMoved) { (snapshot:FIRDataSnapshot) in
            //
            print("ChildMoved, snapshot:\(snapshot)")
            //
        }
        postsEventRemovedHandler = DataService.instance.postsHandle.observeEventType(FIRDataEventType.ChildRemoved) { (snapshot:FIRDataSnapshot) in
            //
            print("ChildRemoved, snapshot:\(snapshot)")
            //
            let location = self.tableData.indexOf({ (p:Post) -> Bool in
                //
                return p.postKey == snapshot.key
                //
            })
            if let index = location {
                self.tableData.removeAtIndex(index)
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                //not found
            }

        }
 
        /*
        DataService.instance.postsHandle.observeSingleEventOfType(FIRDataEventType.Value) { (snapshot:FIRDataSnapshot) in
            //TODO: not efficient, only for demo purposes, change it
            print("FIRDataEventType.Value")
            //clear first
            self.tableData = [Post]()
            //
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                snapshots.count;
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        self.tableData.append(Post(key: snap.key, data: postDict))
                    }
                }
            }
            
            
            self.tableView.reloadData()
        }
         */
    }
    deinit{
        DataService.instance.postsHandle.removeObserverWithHandle(postsEventChangedHandler)
        DataService.instance.postsHandle.removeObserverWithHandle(postsEventMovedHandler)
        DataService.instance.postsHandle.removeObserverWithHandle(postsEventAddedHandler)
        DataService.instance.postsHandle.removeObserverWithHandle(postsEventRemovedHandler)
        
        DataService.instance.postsHandle.removeObserverWithHandle(postsEventValueChangedHandler)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func resetForm() {
        imageSelected = false
        imageSelectorImage.image = UIImage(named: "take-photo")
        postField.text = ""
        
        self.view.endEditing(true)
    }
    func savePost(body:String, imagePath:String?) {
        print("savePost\n\(body)\n\(imagePath)")
        
        var post:Dictionary<String, AnyObject> = [
            "description":body,
            "likes":0
        ]
        
        if var url = imagePath {
            if let range = url.rangeOfString("://") {
                //get rid of protocol and apply HTTPS
                url = "https://\(url.substringFromIndex(range.endIndex))"
            }
            post["imageUrl"] = url
        }
        
        DataService.instance.createPost(post)
        
        resetForm()
        
        //tableView.reloadData()//??
    }
    func savePost(body:String) {
        self.savePost(body, imagePath: nil)
    }
    // MARK: IBActions
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: UIButton) {
        if let txt = postField.text where txt != "" {
            if imageSelected {
                let path = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: path)!
                let imgData = UIImageJPEGRepresentation(imageSelectorImage.image!, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { (data:MultipartFormData) in
                    //
                    data.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    data.appendBodyPart(data: keyData, name: "key")
                    data.appendBodyPart(data: keyJSON, name: "format")
                    //
                }) {(result:Manager.MultipartFormDataEncodingResult) in
                    //upload completed
                    switch result {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { (response:Response<AnyObject, NSError>) in
                            print(response.result)
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imageLink = links["image_link"] as? String {
                                        print("Stored link: \(imageLink)")
                                        self.savePost(self.postField.text!, imagePath:imageLink)
                                    }
                                }
                            }
                        })
                        break
                    case .Failure(let error):
                        print(error)
                    }
                    //
                }
                
            } else {
                self.savePost(self.postField.text!)
            }
        }
    }
    
    
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }
    /*
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
    }
     */
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = tableData[indexPath.row]
        if post.imageUrl != nil {
            return tableView.estimatedRowHeight
        }
        return tableView.estimatedRowHeight - 198
    }
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:PostCell
        if let _cell = tableView.dequeueReusableCellWithIdentifier(PostCell.ID) as? PostCell {
            cell = _cell
            cell.request?.cancel()
            cell.profileRequest?.cancel()
        } else {
            cell = PostCell()
        }
        let data = tableData[indexPath.row];
        var img: UIImage?
        
        if let url = data.imageUrl {
            /*
            if let imgData = FeedVC.imageCache.objectForKey(url) as? NSData {
                img = UIImage(data: imgData)
            }
            */
            img = FeedVC.imageCache.objectForKey(url) as? UIImage
        }
        
        cell.configure(data, image:img)
        
        return cell
    }

}
