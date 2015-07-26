//
//  UdacityClient.swift
//  On The Map
//
//  Created by Joshua Gan on 14/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import UIKit
import Foundation

class UdacityClient : Client {
    
    /* Authentication details */
    var sessionID : String? = nil
    var userKey : String? = nil
    var firstName : String? = nil
    var lastName : String? = nil
    var registered : Bool? = false

    // MARK: - Authentication
    func authenticateWithViewController(hostViewController: UIViewController, username: String, password: String,  completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* Chain completion handlers for each request so that they run one after the other */
        self.getSessionAndUser(username, password: password) { (success, sessionID, userKey, registered, errorString) in
            
            if success {
                /* Login successful */
                self.sessionID = sessionID
                self.userKey = userKey
                self.registered = registered
                
                /* Get First and Last Name */
                self.getUserDetails() { (success, firstName, lastName, errorString) in
                    if success {
                        self.lastName = lastName
                        self.firstName = firstName
                    }
                    
                    completionHandler(success: success, errorString: errorString)
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func getSessionAndUser(username: String, password: String, completionHandler: (success: Bool, sessionID: String?, userKey: String?, registered: Bool?, errorString: String?) -> Void) {
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity: [UdacityClient.JSONBodyKeys.Username: username, UdacityClient.JSONBodyKeys.Password: password]
        ]
        
        /* Build URL */
        let methodURL = Constants.UdacityBaseURL + Methods.Session
        
        /* Make the request */
        let task = taskForPOSTMethod(methodURL, stripChars: Constants.UdacityStripChars, parameters: [String : AnyObject](), jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, sessionID: nil, userKey: nil, registered: nil, errorString: "Login Failed")
            } else {
                /* Get the Session Id */
                if let sessionDetails = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? NSDictionary {
                    if let sessionID = sessionDetails[UdacityClient.JSONResponseKeys.SessionId] as? String {
                        /* Now get the user key */
                        if let userDetails = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? NSDictionary {
                            if let registered = userDetails[UdacityClient.JSONResponseKeys.AccountRegistered] as? Bool {
                                if registered {
                                    if let userKey = userDetails[UdacityClient.JSONResponseKeys.AccountKey] as? String {
                                        completionHandler(success: true, sessionID: sessionID, userKey: userKey, registered: registered, errorString: nil)
                                    } else {
                                        completionHandler(success: true, sessionID: sessionID, userKey: nil, registered: registered, errorString: "Login Failed (User Key Not Found).")
                                    }
                                } else {
                                    completionHandler(success: true, sessionID: sessionID, userKey: nil, registered: nil, errorString: "Login Failed (User Not Registered.")
                                }
                            } else {
                                completionHandler(success: true, sessionID: sessionID, userKey: nil, registered: nil, errorString: "Login Failed (User Registration Not Found).")
                            }
                        } else {
                            completionHandler(success: true, sessionID: sessionID, userKey: nil, registered: nil, errorString: "Login Failed (Account Details Not Found).")
                        }
                    } else {
                        completionHandler(success: false, sessionID: nil, userKey: nil, registered: nil, errorString: "Login Failed (Invalid Session).")
                    }
                } else {
                    completionHandler(success: false, sessionID: nil, userKey:nil, registered: nil, errorString: "Login Failed (Invalid Username or Password).")
                }
            }
        }
    }
    
    func getUserDetails(completionHandler: (success: Bool, firstName: String?, lastName: String?, errorString: String?) -> Void) {
        /* Build URL */
        let methodURL = Constants.UdacityBaseURL + Methods.Users + "/" + self.userKey!
        
        /* Make the request */
        let task = taskForGETMethod(methodURL, stripChars: Constants.UdacityStripChars, parameters: [String : AnyObject]()) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (Retrieving user details).")
            } else {
                /* Get the First Name */
                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? NSDictionary {
                    if let firstName = results[UdacityClient.JSONResponseKeys.UserFirstName] as? String {
                        /* Now get the Last Name */
                        if let lastName = results[UdacityClient.JSONResponseKeys.UserLastName] as? String {
                            completionHandler(success: true, firstName: firstName, lastName: lastName, errorString: nil)
                        } else {
                            completionHandler(success: false, firstName: firstName, lastName: nil, errorString: "Login Failed (Retrieving User Details - Last Name).")
                        }
                    } else {
                        completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (Retrieving User Details - First Name).")
                    }
                } else {
                   completionHandler(success: false, firstName: nil, lastName: nil, errorString: "Login Failed (Retrieving User Details - User).")
                }
            }
        }

    }
    
    
    // Mark: - Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }

    
}
