//
//  Client.swift
//  On The Map
//
//  Created by Joshua Gan on 18/05/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import Foundation

class Client : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(methodURL:String, stripChars: Int, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* Build the URL and configure the request */
        let urlString = methodURL + Client.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        /* Add Parse API details if required, use stripChars to identify (5 = Udacity, 0 = Parse), should probably use flag. */
        if stripChars == 0 {
            request.addValue(Client.Constants.ParseAppId,
                forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Client.Constants.ParseRESTApiKey,
                forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        request.HTTPMethod = "GET"
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = Client.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                /* Strip leading characters if required */
                let modData = data.subdataWithRange(NSMakeRange(stripChars, data.length - stripChars))
                /* Complete parse */
                Client.parseJSONWithCompletionHandler(modData, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    // MARK: - POST
    
    func taskForPOSTMethod(methodURL: String, stripChars: Int, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = methodURL + Client.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        /* Add Parse API details if required, use stripChars to identify (5 = Udacity, 0 = Parse), should probably use flag. */
        if stripChars == 0 {
            request.addValue(Client.Constants.ParseAppId,
                forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Client.Constants.ParseRESTApiKey,
                forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = Client.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                /* Strip leading characters if required */
                let modData = data.subdataWithRange(NSMakeRange(stripChars, data.length - stripChars))
                /* Complete parse */
                Client.parseJSONWithCompletionHandler(modData, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[Client.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Client Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}