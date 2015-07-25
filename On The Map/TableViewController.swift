//
//  TableViewController.swift
//  On The Map
//
//  Created by Joshua Gan on 5/07/2015.
//  Copyright (c) 2015 Threefold Global Pty Ltd. All rights reserved.
//
import UIKit

class TableViewController: UITableViewController {

    var applicationDelegate: AppDelegate?
    var students: [OTMStudent]!
    var onTheMap: Bool = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: Selector("logout"))
        self.navigationItem.leftBarButtonItem? = cancelButton
 
    }
    
//    override func viewDidAppear(animated: Bool) {
//        students = applicationDelegate?.students
//        println("viewDidAppear")
//    
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve stored student information
        println("viewWillAppear")
        applicationDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        students = applicationDelegate?.students
        let rows = students?.count
        println("viewWillAppear count: \(rows)")
        onTheMap = applicationDelegate!.studentOnTheMap
        
        // Reload Data
        self.tableView?.reloadData()
    }
    
    // MARK: - Helpers
    
    // Adds a pin to the Student List
    func addPin() {
        if onTheMap {
            // Already posted a location, in current session only
            var alert = UIAlertController(title: "", message: "You have already posted a student location. Would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action) -> Void in
                self.performSegueWithIdentifier("showAddSegue", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Allow pin to be added
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            var infoPost = storyboard.instantiateViewControllerWithIdentifier("InfoPostingController") as? UINavigationController
            self.presentViewController(infoPost!, animated: true, completion: nil)
        }
    }
    
 
    // Logs the user out and returns to the login screen.
    func logout(){
        let logoutController = presentingViewController as? LoginViewController
        logoutController?.passwordField.text = ""
        applicationDelegate?.students = nil
        applicationDelegate?.activeStudent = nil
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil )
    }
    
    ///
    /// Populates the OTMStudent data source for the view by getting student locations from Parse
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
                            
                            // Refresh TableView
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
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
    
    //MARK: - TableView Data Source Methods
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =
        tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        if let allStudents = self.students {
            let student = allStudents[indexPath.row]
            if let firstName = student.firstName, lastName = student.lastName {
                cell.textLabel?.text = "\(firstName) \(lastName)"
            }
            if let location = student.mapString {
                cell.detailTextLabel?.text = location
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let urlString = self.students![indexPath.row].mediaURL, cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.detailTextLabel?.text = urlString
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let allStudents = self.students {
            if let mapString = allStudents[indexPath.row].mapString, cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.detailTextLabel?.text = mapString
            }
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if let allStudents = self.students {
            if let urlString = allStudents[indexPath.row].mediaURL{
                let app = UIApplication.sharedApplication()
                if let url = NSURL(string: urlString){
                    if app.canOpenURL(url){
                        app.openURL(url)
                    }
                }
            }
        }
    }
    
}

