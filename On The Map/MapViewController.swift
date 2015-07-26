//
//  MapViewController.swift
//  On The Map
//
//  Created by Joshua Gan on 5/07/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    var applicationDelegate: AppDelegate?
    var uniqueKey: String?
    var onTheMap: Bool = false
    
    override func viewDidLoad() {
        applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        // Get the logged in student
        uniqueKey = applicationDelegate?.activeStudent?.uniqueKey
        
        activityIndicator.hidesWhenStopped = true
        mapView.delegate = self
        
        // Setup Navigation Bar
        self.navigationItem.title = "On The Map"
        self.hidesBottomBarWhenPushed = false
        
        // Setup Buttons
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: Selector("getStudents"))
        self.navigationItem.rightBarButtonItem = refreshButton
        
        var pinImage = UIImage(named: "Pin")
        pinImage = pinImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let addPinButton = UIBarButtonItem(image: pinImage, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("addPin"))
        self.navigationItem.rightBarButtonItems?.append(addPinButton)
        
        let cancelButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logout"))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func viewDidAppear(animated: Bool) {
        // Get the Student details
        getStudents()
    }
    
    // MARK: - Helpers
    
    // Adds a pin to the Student List
    func addPin() {
        // Allow pin to be added
        onTheMap = true
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var infoPost = storyboard.instantiateViewControllerWithIdentifier("InfoPostingController") as? UINavigationController
        self.presentViewController(infoPost!, animated: true, completion: nil)
    }
    
    // Logs the user out and returns to the login screen.
    func logout(){
        // Delete current sesssion
        UdacityClient.sharedInstance().logout() { (success, errorString) in
            if success {
                // Dismiss view and clear shared values
                let logoutController = self.presentingViewController as? LoginViewController
                logoutController?.passwordField.text = ""
                self.applicationDelegate?.students = nil
                self.applicationDelegate?.activeStudent = nil
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil )
            } else {
                self.displayAlert("Error", message: errorString, action: "Dismiss")
            }
        }
    }
    
    
    func getStudents() {
        // Let the user know we are doing something
        activityIndicator.startAnimating()
        
        let client = ParseClient.sharedInstance()
        // Retrieve student data from Parse
        client.getStudentDetails(){success, students, errorString in
            if success {
                if let students = students {
                    // Store student details in the AppDelegate
                    if let applicationDelegate = self.applicationDelegate{
                        var allStudents: [OTMStudent] = [OTMStudent]()
                        for student in students {
                            allStudents.append(OTMStudent(dictionary: student))
                        }
                        if allStudents.count > 0 {
                            // Store new student array
                            applicationDelegate.students = allStudents
                            if self.mapView.annotations.count > 0 {
                                // Remove existing annotations if any
                                self.mapView.removeAnnotations(self.mapView.annotations)
                                
                                self.addAnnotationsToMap()
                            } else {
                                self.addAnnotationsToMap()
                            }
                        } else {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            } else {
                self.displayAlert("Error", message: errorString, action: "Dismiss")
            }
            
        }
        self.activityIndicator.stopAnimating()
    }
        
    func addAnnotationsToMap() {
        dispatch_async(dispatch_get_main_queue()){
            if let allStudents = self.applicationDelegate?.students{
                var annotations = [MKAnnotation]()
                for student in allStudents {
                    if let lon = student.longitude,lat = student.latitude, first = student.firstName, last = student.lastName, media = student.mediaURL {
                        let lat = CLLocationDegrees(Double((lat)))
                        let long = CLLocationDegrees(Double((lon)))
                        
                        // The lat and long are used to create a CLLocationCoordinates2D instance.
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        var annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = media
                        
                        // Finally we place the annotation in an array of annotations.
                        annotations.append(annotation)
                    }
                }
                // When the array is complete, we add the annotations to the map.
                if annotations.count <= 0 {
                    self.displayAlert("Alert", message: "No annotations avaliable", action: "Dismiss")
                } else {
                    self.mapView.addAnnotations(annotations)
                }
            } else {
                self.displayAlert("Error", message: "Unable to retrieve student data", action: "Dismiss")
            }
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
        
    
    // MARK: - MKMapViewDelegate
    
    //Configures pin
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let url = NSURL(string: annotationView.annotation.subtitle!){
                if app.canOpenURL(url){
                    app.openURL(url)
                }
            }
        }
    }
    
}
