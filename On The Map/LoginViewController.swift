//
//  LoginViewController.swift
//  On The Map
//
//  Created by Joshua Gan on 14/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {


    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var debugLabel: UILabel!
    // Label for user messages
  
    @IBOutlet weak var userMessage: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var applicationDelegate: AppDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        activityIndicator.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signUpTouch(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }

    @IBAction func loginButtonTouch(sender: AnyObject) {
        self.loginButton.enabled = false
        //self.debugLabel.text = "Connecting ..."
        self.activityIndicator.startAnimating()
        
        // Check network connection
        if NetworkClient.isConnectedToNetwork() {
            // Error check input
            if (self.usernameField.text == "" ||
                self.passwordField.text == "") {
                    self.displayAlert("Error", message: "Please enter a username and password", action: "Dismiss")
            } else {
                UdacityClient.sharedInstance().authenticateWithViewController(self, username: self.usernameField.text, password: self.passwordField.text) { (success, errorString) in
                    if success {
                        // Store the active student details
                        var studentData = [String: AnyObject]()
                        studentData["uniqueKey"] = UdacityClient.sharedInstance().userKey
                        studentData["firstName"] = UdacityClient.sharedInstance().firstName
                        studentData["lastName"] = UdacityClient.sharedInstance().lastName
                        studentData["registered"] = UdacityClient.sharedInstance().registered
                        studentData["uniqueKey"] = UdacityClient.sharedInstance().userKey
                        if let applicationDelegate = self.applicationDelegate {
                            applicationDelegate.activeStudent = OTMStudent(dictionary: studentData)
                        }
                        self.completeLogin()
                    } else {
                        self.displayAlert("Error", message: errorString, action: "Dismiss")
                    }
                }
            }
        } else {
            self.displayAlert("Error", message: "No network connection available", action: "Dismiss")
        }
    }

    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loginButton.enabled = true
            self.activityIndicator.stopAnimating()
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OTMTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugLabel.text = errorString
            }
        })
        
        // Reset buttons and fields
        self.loginButton.enabled = true
        self.activityIndicator.stopAnimating()
    }
    
    // Display a UIAlert Controller
    func displayAlert(title: String? , message: String?, action: String) {
        dispatch_async(dispatch_get_main_queue()){
            self.activityIndicator.stopAnimating()
            
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: action, style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // Reset buttons and fields
        self.loginButton.enabled = true
        self.debugLabel.text = ""
        self.activityIndicator.stopAnimating()
    }
}

