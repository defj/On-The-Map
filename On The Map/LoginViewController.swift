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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func loginButtonTouch(sender: AnyObject) {
        self.loginButton.enabled = false
        self.debugLabel.text = "Connecting ..."
        
        // Error check input
        if (self.usernameField.text == "" ||
            self.passwordField.text == "") {
                displayError(("Enter your username and password"))
        } else {
            UdacityClient.sharedInstance().authenticateWithViewController(self, username: self.usernameField.text, password: self.passwordField.text) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }

    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugLabel.text = "Login Success"
            self.loginButton.enabled = true
            
//            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
//            self.presentViewController(controller, animated: true, completion: nil)
        })
        println("login success")
        
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugLabel.text = errorString
            }
        })
        
        // Reset buttons and fields
        self.loginButton.enabled = true
    }
}

