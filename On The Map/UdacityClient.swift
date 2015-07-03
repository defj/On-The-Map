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
    
    /* Authentication state */
    var sessionID : String? = nil
    var userKey : String? = nil

    // MARK: - Authentication
    func authenticateWithViewController(hostViewController: UIViewController, username: String, password: String,  completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* Chain completion handlers for each request so that they run one after the other */
        self.getSessionID(username, password: password) { (success, sessionID, errorString) in
            
            if success {
                /* Success! We have the sessionID! */
                self.sessionID = sessionID
                
                self.getUserID() { (success, userID, errorString) in
                    
                    if success {
                        
                        if let userID = userID {
                            
                            /* And the userID 😄! */
                            self.userID = userID
                        }
                    }
                    
                    completionHandler(success: success, errorString: errorString)
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    func getSessionID(username: String, password: String, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        var parameters : [String:AnyObject]
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity: [UdacityClient.JSONBodyKeys.Username: username,UdacityClient.JSONBodyKeys.Password: password]
        ]
        
        /* Build URL */
        let methodURL = Constants.UdacityBaseURL + Methods.Session
        
        /* Make the request */
        let task = taskForPOSTMethod(methodURL, stripChars: Constants.UdacityStripChars, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account) as? [[String : AnyObject]] {
                    if let sessionID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.AccountKey) as? String {
                        completionHandler(success: true, sessionID: sessionID, errorString: nil)
                    } else {
                        completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                    }
                    if
                } else {
                    completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    func getUserID(completionHandler: (success: Bool, userID: Int?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [TMDBClient.ParameterKeys.SessionID : TMDBClient.sharedInstance().sessionID!]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.Account, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, userID: nil, errorString: "Login Failed (User ID).")
            } else {
                if let userID = JSONResult.valueForKey(TMDBClient.JSONResponseKeys.UserID) as? Int {
                    completionHandler(success: true, userID: userID, errorString: nil)
                } else {
                    completionHandler(success: false, userID: nil, errorString: "Login Failed (User ID).")
                }
            }
        }
    }
    
    
    

    
}
