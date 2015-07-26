//
//  OTMStudent.swift
//  On The Map
//
//  Created by Joshua Gan on 5/07/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import Foundation

struct OTMStudent: Printable {
    
    // Mark:- Properties
    var objectId: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    var registered: Bool? = nil
    
    //Student Object
    init(dictionary: [String: AnyObject]?){
        if let dictionary = dictionary{
            if let objectId = dictionary["objectId"] as? String {
                self.objectId = objectId
            }
            if let uniqueKey = dictionary["uniqueKey"] as? String {
                self.uniqueKey = uniqueKey
            }
            if let firstName = dictionary["firstName"] as? String{
                self.firstName = firstName
            }
            if let lastName = dictionary["lastName"] as? String{
                self.lastName = lastName
            }
            if let mapString = dictionary["mapString"] as? String {
                self.mapString = mapString
            }
            if let mediaURL = dictionary["mediaURL"] as? String {
                self.mediaURL = mediaURL
            }
            if let latitude = dictionary["latitude"] as? Float {
                self.latitude = latitude
            }
            if let longitude = dictionary["longitude"] as? Float{
                self.longitude = longitude
            }
            if let registered = dictionary["registered"] as? Bool{
                self.registered = registered
            }
        }
    }
    
    
    // Print details in readable format
    var description: String {
        let empty = "nil"
        return String("Student [objectId: \((objectId == nil) ? empty : objectId!), uniqueKey: \((uniqueKey == nil) ? empty : uniqueKey!), firstName: \((firstName == nil) ? empty : firstName!), lastName: \((lastName == nil) ? empty : lastName!), mapString: \((mapString == nil) ? empty : mapString!), mediaURL: \((mediaURL == nil) ? empty : mediaURL!), latitude: \((latitude == nil) ? 0 : latitude!), longitude: \((longitude == nil) ? 0 : longitude!)]")
    }
    
}
