//
//  ViewController.swift
//  s11-showcase-app
//
//  Created by Lukasz Grela on 22.09.2016.
//  Copyright © 2016 Commelius Solutions Ltd. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {

    
    
    @IBOutlet weak var loginSignupBtn: UIButton!
    @IBOutlet weak var emailLabel: MaterialTextField!
    @IBOutlet weak var passLabel: MaterialTextField!
    @IBOutlet weak var content:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if (NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil) {
            self.performSegueWithIdentifier(SEGUE_ID_LOGGED_IN, sender: nil)
        }
    }
    
    func keyboardWillShow(n:NSNotification) {
        if let userInfo = n.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                if let constraint = self.content.constraints.filter({ (c:NSLayoutConstraint) -> Bool in
                    return c.identifier == "contentHeight"
                }).first {
                    constraint.constant = UIScreen.mainScreen().bounds.height + keyboardHeight
                }
            }
        }
    }
    func keyboardWillHide(n:NSNotification) {
        if let constraint = self.content.constraints.filter({ (c:NSLayoutConstraint) -> Bool in
            return c.identifier == "contentHeight"
        }).first {
            
            constraint.constant = UIScreen.mainScreen().bounds.height
            
        }

    }
    
    
    @IBAction func fbBtnPressed(sender:UIButton!) {
        let fbLogin = FBSDKLoginManager()
        fbLogin.logInWithReadPermissions(["email"], fromViewController: self) { (fbResult:FBSDKLoginManagerLoginResult!, fbError:NSError!) in
            //
            if fbError != nil {
                print("Facebook login failed. Error \(fbError.debugDescription)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged-in with Facebook. Token: \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                
                FIRAuth.auth()?.signInWithCredential(credential) { (authData, error) in
                    
                    if error != nil {
                        print("Login failed! \(error.debugDescription)")
                        
                    } else {
                        print("Logged In! \(authData)")
                        let user:Dictionary<String,String> = ["provider": (authData?.providerID)!, "username":(authData?.displayName)!, "photo":(authData?.photoURL?.absoluteString)!]
                        
                        //store in DB
                        DataService.instance.createUser((authData?.uid)!, user: user)
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_ID_LOGGED_IN, sender: nil)
                    }
                    
                }
                
            }
            //
        }
        /*
        fbLogin.logInWithReadPermissions(["email"]) { (fbResult:FBSDKLoginManagerLoginResult!, fbError:NSError!) in
            if fbError != nil {
                print("Facebook login failed. Error \(fbError.debugDescription)")
            } else {
                let acces sToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged-in with Facebook. Token: \(accessToken)")
            }
        }
         */
        
        

    }
    @IBAction func attemptLogin(sender:UIButton!) {
        print("ViewController.attemptLogin()")
        if let email = emailLabel.text where !email.isEmpty, let pwd = passLabel.text where !pwd.isEmpty {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user:FIRUser?, error:NSError?) in
                if error != nil {
                    //ERROR!
                    print("code:\(error?.code), description: \(error.debugDescription)")
                    print(FIRAuthErrorCode.ErrorCodeWrongPassword.rawValue)
                    
                    switch(error!.code) {
                    case FIRAuthErrorCode.ErrorCodeWrongPassword.rawValue:
                        self.showErrorAlert("Authorisation", msg: "Password incorrect or not set")
                        break
                    case FIRAuthErrorCode.ErrorCodeUserNotFound.rawValue:
                        self.createUser(email, password: pwd)
                        break
                    case FIRAuthErrorCode.ErrorCodeUserDisabled.rawValue:
                        //clear previous stored user
                        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
                        self.showErrorAlert("Authorisation", msg: "Your user was disabled by the admin.")
                        break
                    default:
                        self.showErrorAlert("Authorisation", msg: "Uknown error")
                    }
                    
                    
                } else {
                    //correct
                    NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                    
                    //already logged in
                    self.performSegueWithIdentifier(SEGUE_ID_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must fill the email and/or password fields.")
            
        }
    }
    func createUser(email:String, password:String) {
        print("ViewController.createUser(email, password)")
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (authData:FIRUser?, error:NSError?) in
            //
            if error != nil {
                print(error)
                self.showErrorAlert("User Creation", msg: "Could not create an account for the user \(email)")
            } else {
                
                let user:Dictionary<String,String> = ["provider": (authData?.providerID)!, "username":(authData?.displayName)!, "photo":(authData?.photoURL?.absoluteString)!]
                
                //store in DB
                DataService.instance.createUser((authData?.uid)!, user: user)
                
                NSUserDefaults.standardUserDefaults().setValue(authData?.uid, forKey: KEY_UID)
                
                //already logged in
                self.performSegueWithIdentifier(SEGUE_ID_LOGGED_IN, sender: nil)
            }
            //
        })
    }
    func showErrorAlert(title:String, msg:String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil);
        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

