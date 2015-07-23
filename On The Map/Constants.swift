//
//  Constants.swift
//  On The Map
//
//  Created by Joshua Gan on 18/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

extension Client {
    
    // MARK: - Constants
    struct Constants {
        // MARK: API Key
        static let ParseAppId : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let UdacityBaseURL : String = "https://www.udacity.com/api/"
        static let ParseBaseURL : String = "https://api.parse.com/1/classes/StudentLocation"
        
        // MARK: Strip Char
        static let UdacityStripChars : Int = 5
        static let ParseStripChars : Int = 0
    }
    
    // MARK: - JSON Response Keys {
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
    }
    
}
