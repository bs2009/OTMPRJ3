//
//  SubmissionInfoViewController.swift
//  P4
//
//  Created by William Song on 6/19/15.
//  Copyright (c) 2015 Bill Song. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SubmissionInfoViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mediaURLtextField: UITextField!
    
    var mapString: String?
    var geolocation: CLPlacemark!
    var latCLD:CLLocationDegrees?
    var longCLD:CLLocationDegrees?
    
    override func viewDidLoad() {
        submitButton.layer.borderColor = UIColor.grayColor().CGColor
        submitButton.backgroundColor = UIColor.whiteColor()
        mediaURLtextField.backgroundColor = UIColor.darkGrayColor()
        mediaURLtextField.textColor = UIColor.whiteColor()
        
        mapView.delegate = self
        mediaURLtextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.mapView.addAnnotation(MKPlacemark(placemark: geolocation))
        self.latCLD = geolocation.location.coordinate.latitude
        self.longCLD = geolocation.location.coordinate.longitude
        
        let mapPin = CLLocationCoordinate2DMake(latCLD!, longCLD!)
        
        // set zoom view
        var zoomView =
        MKMapCamera(lookingAtCenterCoordinate: mapPin, fromEyeCoordinate: mapPin, eyeAltitude: 10000.0)
        self.mapView.setCamera(zoomView, animated: true)
    }
 
    // Submit location and url to OTMclient for posting 
    @IBAction func SubmitInfo(sender: AnyObject) {
        var finalURL: String?
        var canBeDismissed: Bool = false
        var urlInput = mediaURLtextField.text
        
        if validateUrl(urlInput) == false {
            var invalidUrl = UIAlertView()
            invalidUrl.title = "Invalid URL"
            invalidUrl.message = "Please enter a valid url"
            invalidUrl.addButtonWithTitle("OK")
            invalidUrl.show()
        } else {
            
            if mediaURLtextField.text.lowercaseString.hasPrefix("http://") || mediaURLtextField.text.lowercaseString.hasPrefix("https://") {
                finalURL = mediaURLtextField.text
            } else {
                finalURL = "http://\(mediaURLtextField.text)"
            }
            
            let udacityClient = Client()
            var appDelegate:AppDelegate!
            appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            
            udacityClient.postStudentLocation(finalURL!, lat: latCLD!, long: longCLD!, mapString: finalURL!) { success in
                
                if let success = success {
                    if success {
                        canBeDismissed = true
                        
                        let updateLat = self.geolocation.location.coordinate.latitude as Double
                        
                        let updateLong = self.geolocation.location.coordinate.longitude as Double
                        
                        appDelegate.loggedInStudent?.latitude = updateLat
                        appDelegate.loggedInStudent?.longitude = updateLong
                        appDelegate.loggedInStudent?.mediaURL = finalURL
                    } else {
                        println("unsuccessful post")
                        var failedPostAlert = UIAlertController(title: "Unable to Post", message: "Retry?", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        failedPostAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                        }))
                        
                        failedPostAlert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
                            self.SubmitInfo(self)
                        }))
                        
                        self.presentViewController(failedPostAlert, animated: true, completion: nil)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    if canBeDismissed == true {
                        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }
    
    // Return to location selection screen to update
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Return to original tabbed view (map/table view)
    @IBAction func cancel(sender: AnyObject) {
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // Allows user to test the URL they've entered before submitting
    @IBAction func afterUrlEditing(sender: AnyObject) {
        var urlInput = mediaURLtextField.text
        if validateUrl(urlInput) == false {
            var invalidUrl = UIAlertView()
            invalidUrl.title = "Invalid URL"
            invalidUrl.message = "Please enter a valid url"
            invalidUrl.addButtonWithTitle("OK")
            invalidUrl.show()
        }
    }
    // validate url
    func validateUrl (stringURL : NSString) -> Bool {
    
        var urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        var urlTest = NSPredicate.predicateWithSubstitutionVariables(predicate)
    
        return predicate.evaluateWithObject(stringURL)
    }

    //  Dismiss keyboard if tap is registered outside of field
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        mediaURLtextField.resignFirstResponder()
    }
    
    //  Dismiss keyboard if return key pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if mediaURLtextField.isFirstResponder() {
            mediaURLtextField.resignFirstResponder()
        }
        return true
    }
    

}