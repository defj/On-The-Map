//
//  ParseConstants.swift
//  On The Map
//
//  Created by Joshua Gan on 18/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import Foundation

extension ParseClient {
    // MARK: - Constants
    
    // MARK: - Methods
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let Limit = "limit"
        static let Order = "order"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: - JSON Response Keys {
    struct JSONResponseKeys {
        
        static let ObjectId = "objectId"
        static let Results = "results"

    }
    
}
