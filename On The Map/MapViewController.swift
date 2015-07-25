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
        
        //        var pinButton: UIButton = UIButton()
        //        pinButton.setImage(UIImage(named: "Pin"), forState: .Normal)
        //        pinButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        //        pinButton.targetForAction(Selector("addPin"), withSender: nil)
        //        let addPinButton = UIBarButtonItem()
        //        addPinButton.customView = pinButton
        let addPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addPin"))
        self.navigationItem.rightBarButtonItems?.append(addPinButton)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("logout"))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func viewDidAppear(animated: Bool) {
        // Get the Student details
        getStudents()
    }
    
    func getStudents() {
        activityIndicator.startAnimating()
        
        let client = ParseClient.sharedInstance()
        // Retrieve student data from Parse
        println("Getting student details")
        client.getStudentDetails(){success, students, errorString in
            if success {
                if let students = students {
                    // Store student details in the AppDelegate
                    println("Storing Details")
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
                self.displayAlert("Error", message: errorString, action: "OK")
            }
            
        }
        self.activityIndicator.stopAnimating()
    }
        
    func addAnnotationsToMap() {
        println("Adding Annotations")
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
                    self.displayAlert("Alert", message: "No annotations avaliable", action: "OK")
                } else {
                    self.mapView.addAnnotations(annotations)
                }
            } else {
                self.displayAlert("Error", message: "Unable to retrieve student data", action: "OK")
            }
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
