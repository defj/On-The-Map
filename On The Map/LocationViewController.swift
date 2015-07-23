//
//  LocationViewController.swift
//  On The Map
//
//  Created by Joshua Gan on 5/07/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var applicationDelegate: AppDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationField.delegate = self
        applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        activityIndicator.hidesWhenStopped = true
    }
    
    // Find and forward Geocode location
    @IBAction func findLocationTouchUp(sender: AnyObject) {
        
        // Check that location has been entered
        if locationField.text.isEmpty{
            displayAlert("Error", message: "Please enter a location.", action: "OK")
            return
        }
        
        // Geocode location
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationField.text){
            placemark, error in
            if let error = error {
                self.displayAlert("Error", message: error.localizedDescription, action: "OK")
                return
            }
            
            self.activityIndicator.startAnimating()
            
            if let appDelegate = self.applicationDelegate {
                if let placemark = placemark as? [CLPlacemark]{
                    if placemark.count > 0 {
                        let placemark = placemark.first!
                        if let country = placemark.country, state = placemark.administrativeArea{
                            if let city = placemark.locality{
                                appDelegate.activeStudent?.mapString = "\(city), \(state), \(country)"
                                appDelegate.activeStudent?.latitude = Float(placemark.location.coordinate.latitude)
                                appDelegate.activeStudent?.longitude = Float(placemark.location.coordinate.longitude)
                                self.displayView(appDelegate.activeStudent?.mapString,lat: appDelegate.activeStudent?.latitude,lon: appDelegate.activeStudent?.longitude)
                                self.stopActivity()
                            } else {
                                appDelegate.activeStudent?.mapString = "\(state), \(country)"
                                appDelegate.activeStudent?.latitude = Float(placemark.location.coordinate.latitude)
                                appDelegate.activeStudent?.longitude = Float(placemark.location.coordinate.longitude)
                                self.displayView(appDelegate.activeStudent?.mapString,lat: nil,lon: nil)
                                self.stopActivity()
                            }
                        } else {
                            self.displayAlert("Error", message:"Could not find location: Please be more specific", action: "OK")
                        }
                    } else {
                        self.displayAlert("Error", message:"Unable to find location", action: "OK")
                    }
                } else {
                    self.displayAlert("Error", message:"Unable to find locations", action: "OK")
                }
            } else {
                self.displayAlert("Error", message: "Unable to access application delegate", action: "OK")
            }
        }
    }
    
    // Cancel Button Pressed
    @IBAction func cancelLocation(sender: AnyObject) {
        // Dismiss View Controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Unsubscribe
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    

    
    //MARK: - Helper Methods
    
    // Stop Activity Indicator on main thread
    func stopActivity() {
        dispatch_async(dispatch_get_main_queue()){
            self.activityIndicator.stopAnimating()
        }
    }
    
    // Display a UIAlert Controller
    func displayAlert(title: String? , message: String?, action: String) {
        dispatch_async(dispatch_get_main_queue()){
            self.activityIndicator.stopAnimating()
            
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: action, style: .Default, handler: { action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // Display viewController
    func displayView(mapString: String?, lat: Float?, lon: Float?) {
        dispatch_async(dispatch_get_main_queue()){
            if mapString != nil {
                self.performSegueWithIdentifier("showAddLinkViewController", sender: self)
            } else {
                self.displayAlert("Error", message: "Could not find location: Please try again", action: "OK")
            }
        }
    }
    
    // Show location view on map
    func showLocation(mapString: String?, lat: Float?, lon: Float?) {
        dispatch_async(dispatch_get_main_queue()){
            if mapString != nil {
                self.performSegueWithIdentifier("showLinkController", sender: self)
            } else {
                self.displayAlert("Error", message: "Could not find location: Please try again.", action: "OK")
            }
        }
    }
    
    // Notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: - User Interface
    func keyboardWillShow(notification: NSNotification) {
        if locationField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification) - 20
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if locationField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification) - 20
        }
    }
    

    
//    func keyboardDidShow(notification: NSNotification){
//        if self.view.frame.origin.y == 0 {
//            view.frame.origin.y =
//                -(locationField.frame.origin.y - topLayoutGuide.length  )
//        }
//    }
//    
//    func keyboardWillHide(notification: NSNotification){
//        //Move view back in position
//        self.view.frame.origin.y = 0.0
//    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if locationField.isFirstResponder() {
            locationField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if locationField.isFirstResponder() && locationField.text.isEmpty == false {
            locationField.resignFirstResponder()
        }
        
        
        return false
    }
    
}

