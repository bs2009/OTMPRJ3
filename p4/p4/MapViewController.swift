//
//  MapViewController.swift
//  P4
//
//  Created by William Song on 5/23/15.
//  Copyright (c) 2015 Bill Song. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var appDelegate: AppDelegate!
    var userKey: String?
    var mapPins = [MKAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // manually add two button on the navigation bar
        var rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        var rightLocateButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "locateStudent:")
        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem, rightLocateButtonItem], animated: true)
        
        //populate application information
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        userKey = appDelegate.loggedInStudent?.uniqueKey
        mapView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        reloadData()
    }
    func reloadData() {
        //get student location info and add pin to the map
        getStudentLocationData()
        addStudentMapPins()
    }
    
    // Get Student Location Data from Parse API and add pins on the map
    func getStudentLocationData() {
        
        let parseDataClient = Client.sharedInstance()
        
        parseDataClient.getStudentLocations() {
            students, errorString in
            
            if let students = students {
                
                if let appDelegate = self.appDelegate {
                    var studentDataArr: [Student] = [Student]()
                    
                    for studentResults in students {
                        studentDataArr.append(Student(studentData: studentResults))
                    }
                    appDelegate.allStudents = studentDataArr
                    
                    self.addStudentMapPins()
                }
            } else {
                if let error = errorString {
                    println(error)
                }
            }
        }
    }
    
    
    //  Add Pins to Map with Student info
    func addStudentMapPins() {
        dispatch_async(dispatch_get_main_queue()) {
            if let studentMapPins = self.appDelegate?.allStudents {
                if studentMapPins.count > 0 {
                    if self.mapView.annotations.count > 0 {
                        // if pins already exist, reset them then load new pin
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.mapPins.removeAll(keepCapacity: false)
                    }
                    
                    for students in studentMapPins {
                        // ensure all data is present before loading pin
                        if let long = students.longitude {
                            if let lat = students.latitude {
                                if let fName = students.firstName {
                                    if let lName = students.lastName {
                                        if let mURL = students.mediaURL{
                                            let lat = CLLocationDegrees(Double((lat)))
                                            let long = CLLocationDegrees(Double((long)))
                                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                            var mapPin = MKPointAnnotation()
                                            mapPin.coordinate = coordinate
                                            mapPin.title = "\(fName) \(lName)"
                                            mapPin.subtitle = "\(mURL)"
                                            self.mapPins.append(mapPin)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if self.mapPins.count == 0 {
                            println("No pins in the array")
                        } else {
                            self.mapView.addAnnotations(self.mapPins)
                        }
                    }
                } else {
                    println("No student data in appDelegate")
                    
                    var failedPostAlert = UIAlertController(title: "No Student Data", message: "Try again?", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    failedPostAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                    }))
                    
                    failedPostAlert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                        self.refreshData()
                    }))
                    
                    self.presentViewController(failedPostAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    //  Get fresh data from API and reload map pins
    
    // func for reloadButton on navigation bar
    func refreshData() {
        getStudentLocationData()
        addStudentMapPins()
    }
    
    
    // Configure annotation view of the student Pins *
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("studentPin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "studentPin")
            pinView?.canShowCallout = true
            pinView?.pinColor = .Red
            pinView?.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    // Open URL when annotation is tapped
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            
            if let mediaURL = view.annotation.subtitle {
                
                if mediaURL.lowercaseString.hasPrefix("http://") || mediaURL.lowercaseString.hasPrefix("https://"){
                    
                    if let url = NSURL(string: mediaURL) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                } else {
                    let updatedURL = "http://\(mediaURL)"
                    
                    if let url = NSURL(string: updatedURL) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        }
    }
    
    
    //  Post new student location, checking for existing
    func locateStudent(sender: AnyObject) {
        
        let myClient = Client.sharedInstance()
        myClient.queryForStudentLocation() {
            data, error in
            
            if error == nil {
                if let data = data { // set data for access
                    if data.count > 0 { // if post existing
                        
                        var lat: Double = data[0]["latitude"] as! Double
                        var long: Double = data[0]["longitude"] as! Double
                        
                        var latCord: CLLocationDegrees = lat
                        var longCord: CLLocationDegrees = long
                        
                        let existingLoc = CLLocationCoordinate2DMake(latCord, longCord)
                        var zoomView = MKMapCamera(lookingAtCenterCoordinate: existingLoc, fromEyeCoordinate: existingLoc, eyeAltitude: 10000.0)
                        self.mapView.setCamera(zoomView, animated: true)
                        
                        
                        // alert the user pin location existing
                        var alert = UIAlertController(title: "Existing Pin", message: "You've already posted your location.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                            //self.defaultZoom()
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                            myClient.deleteExistingPosts(data)
                            // Segue to Location Entry
                            self.performSegueWithIdentifier("MapToInfo", sender: self)
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        self.performSegueWithIdentifier("MapToInfo", sender: self)
                    }
                }
                
            } else {
                // could not locate Student data
                var downloadFailureAlert = UIAlertController(title: "Query Failed", message: "Unable to download student locations.", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(downloadFailureAlert, animated: true, completion: nil)
                println("unable to query existing posts")
            }
        }
    }
    
    //  Log out of Udacity Session and Return to Login
    @IBAction func logoutButtonTouchUp(sender: AnyObject) {
        let openSession = Client.sharedInstance()
        openSession.logoutOfUdacity()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Refresh Map
    func refresh(sender: UIBarButtonItem) {
        Client.sharedInstance().getStudentLocations() {(students, error) in
            if error != nil {
                println("Parsing Error", errorMsg: error!)
            } else {
                self.getStudentLocationData()
                self.addStudentMapPins()
            }
        }
    }
    
    
    // Logout Button Pressed
    @IBAction func loggedoutButtonPressed(sender: AnyObject) {
        //loginManager.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}