//
//  AddLinkViewController.swift
//  On The Map
//
//  Created by Joshua Gan on 5/07/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import UIKit
import MapKit

class AddLinkViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var applicationDelegate: AppDelegate?
    var activeStudent: OTMStudent?
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup field delegate
        linkField.delegate = self
        
        // Retrieve shared data
        applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        activeStudent = applicationDelegate?.activeStudent
        
        activityIndicator.hidesWhenStopped = true
        
        // Add the annotations
        addAnnotationsToMap()
    }
    
    // MARK:- Actions
    
    @IBAction func cancelOperation(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addAnnotationsToMap() {
        dispatch_async(dispatch_get_main_queue()){
            if let student = self.activeStudent {
                if let lon = student.longitude,lat = student.latitude {
                    let lat = CLLocationDegrees(Double((lat)))
                    let long = CLLocationDegrees(Double((lon)))
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    // Here we create the annotation and set its coordiate
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.addAnnotation(annotation)
                    var cammera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 10000.0)
                    self.mapView.setCamera(cammera, animated: true)
                } else {
                    self.displayAlert("Alert", message: "Invalid location.", action: "Dismiss")
                }
            } else {
                self.displayAlert("Error", message: "Unable to retrive student data.", action: "Dismiss")
            }
        }
    }
    
    
    @IBAction func submitLink(sender: AnyObject) {
        self.activityIndicator.startAnimating()
        
        if let urlString = linkField.text{
            if verifyUrl(urlString){
                applicationDelegate?.activeStudent?.mediaURL = "\(urlString)"
                if let appDelegate = applicationDelegate{
                        self.addLocation()
                }
            } else {
                self.displayAlert("Error", message:"Link is invalid", action: "Dismiss")
            }
        } else {
            self.displayAlert("Error", message:"Please enter a link", action: "Dismiss")
        }
        
    }
    
    func addLocation(){
        let parseClient = ParseClient.sharedInstance()
        parseClient.postStudentDetail(applicationDelegate?.activeStudent){
            success, errorString in
            if success {
                self.activityIndicator.stopAnimating()
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                if let errorString = errorString {
                    self.displayAlert("Error", message: errorString, action: "Dismiss")
                }else {
                    self.displayAlert("Error", message:"Failed to add student details", action: "Dismiss")
                }
            }
        }
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
            alert.addAction(UIAlertAction(title: action, style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Verify student url.
    func verifyUrl(urlString: String?) ->Bool{
        if let urlString = urlString{
            let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
            if let match = urlString.rangeOfString(pattern, options: .RegularExpressionSearch){
                if let url = NSURL(string: urlString){
                    if UIApplication.sharedApplication().canOpenURL(url){
                        return true
                    } else { return false }
                } else { return false }
            } else { return false }
        } else { return false }
    }
    
}
