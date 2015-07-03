//
//  ParseConstants.swift
//  On The Map
//
//  Created by Eden Gan on 18/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import Foundation

extension ParseClient {
    // MARK: - Constants
    struct Constants {
        // MARK: API Key
        static let ParseAppId : String = "Application ID"
        static let ParseRESTApiKey: String = "API_KEY"
        
        // MARK: URLs
        static let ParseBaseURL : String = "https://api.parse.com/1/classes/StudentLocation"
        
    }
    
    // MARK: - Methods
    struct Methods {
        // MARK: Session
        static let Session = "session"
        
        // MARK: User
        static let User = "user"
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let UserId = "user_id"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: - JSON Response Keys {
    struct JSONResponseKeys {
        
        // MARK: Account
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        
        // MARK: Session
        static let SessionId = "id"
        static let SessionExpiration = "expiration"
        
        // MARK: User
        static let UserKey = "key"
    }
    
}
