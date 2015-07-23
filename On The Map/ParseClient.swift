//
//  ParseClient.swift
//  On The Map
//
//  Created by Joshua Gan on 18/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import Foundation

class ParseClient : Client {

    // GET student details from Parse
    func getStudentDetails(completionHandler: (success: Bool, data: [[String: AnyObject]]?, errorString: String?) -> Void) {
        /* Specify Parameters */
        let parameters = [
            ParseClient.ParameterKeys.Order: "-createdAt,-updatedAt",
            ParseClient.ParameterKeys.Limit: 100
        ]
        
        /* Build URL */
        let methodURL = Constants.ParseBaseURL
        
        /* Make the request */
        let task = taskForGETMethod(methodURL, stripChars: Constants.ParseStripChars, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, data: nil, errorString: "Failed to retrive student data.")
            } else {
                /* Get the First Name */
                if let results = JSONResult.valueForKey(ParseClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
                    completionHandler(success: true, data: results, errorString: nil)
                } else {
                    completionHandler(success: false, data: nil, errorString: "Failed to parse retrieved student data")
                }
            }
        }
    }
    
    // POST a students details
    func postStudentDetail(student: OTMStudent?, completionHandler: (success: Bool, errorString: String?) -> Void) {
        // Check we have all the student details
        if let student = student {
            if let uniqueKey = student.uniqueKey, firstName = student.firstName, lastName = student.lastName, mapString = student.mapString, mediaURL = student.mediaURL, latitude = student.latitude, longitude = student.longitude {
        
                    let jsonBody : [String:AnyObject] = [
                        ParseClient.JSONBodyKeys.UniqueKey: uniqueKey,
                        ParseClient.JSONBodyKeys.FirstName: firstName,
                        ParseClient.JSONBodyKeys.LastName: lastName,
                        ParseClient.JSONBodyKeys.MapString: mapString,
                        ParseClient.JSONBodyKeys.MediaURL: mediaURL,
                        ParseClient.JSONBodyKeys.Latitude: latitude,
                        ParseClient.JSONBodyKeys.Longitude: longitude
                    ]
        
                    /* Build URL */
                    let methodURL = Constants.ParseBaseURL
        
                    /* Make the request */
                    let task = taskForPOSTMethod(methodURL, stripChars: Constants.ParseStripChars, parameters: [String : AnyObject](), jsonBody: jsonBody) { JSONResult, error in
            
                        /* 3. Send the desired value(s) to completion handler */
                        if let error = error {
                            completionHandler(success: false, errorString: "Failed to add details.")
                        } else {
                            /* Get the Object Id */
                            if let objectId = JSONResult.valueForKey(ParseClient.JSONResponseKeys.ObjectId) as? String {
                                completionHandler(success: true, errorString: nil)
                            } else {
                                completionHandler(success: false, errorString: "Failed to add details (Object ID).")
                            }
                        }
                    }
            } else {
                    completionHandler(success: false, errorString: "Incomplete student details. Failed to add details.")
            }
        }
    }
    
    
    // Mark: - Shared Instance
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}

