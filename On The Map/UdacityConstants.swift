//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Joshua Gan on 18/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

extension UdacityClient {

    
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
        static let Account = "account"
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        
        // MARK: Session
        static let Session = "session"
        static let SessionId = "id"
        static let SessionExpiration = "expiration"
        
        // MARK: User
        static let UserKey = "key"
    }
}
