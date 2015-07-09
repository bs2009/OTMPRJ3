//
//  LoginViewController.swift
//  P4
//
//  Created by William Song on 5/22/15.
//  Copyright (c) 2015 Bill Song. All rights reserved.
//
import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIApplicationDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Get the app delegate and session info
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.debugTextLabel.text = ""
        self.debugTextLabel.backgroundColor = UIColor.clearColor()
    }
    
    
    
    //  Dismiss keyboard if return key pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginToUdacity(sender: AnyObject) {
        let udacityClient = Client()
        debugTextLabel.text = ""
        
        udacityClient.loginToUdacity(usernameTextField.text, password: passwordTextField.text){
            success, data, error in
            if success {
                // update loggedInStudent with returned data
                self.appDelegate.loggedInStudent = Student(studentData: data)
                self.getStudentData(udacityClient)
                
                // go on to tab bar controller
                self.completeLogin()
            } else {
                // login error
                
                if error?.rangeOfString("username") != nil {
                    self.displayError("Please enter an email!")
                } else if error?.rangeOfString("password") != nil {
                    self.displayError("Please enter password!")
                } else {
                    // self.displayError(error)
                    self.loginFailAlert(error)
                }
                
            }
        }
    }
    
    //  Get Students Data from Udacity
    func getStudentData(udacityClient: Client) {
        
        let key = appDelegate.loggedInStudent?.uniqueKey
        udacityClient.getUdacityStudentData(key!){
            data, errorString in
            
            if let studentData = data {
                dispatch_async(dispatch_get_main_queue()) {
                    self.appDelegate.loggedInStudent?.firstName = studentData["firstName"] as? String
                    self.appDelegate.loggedInStudent?.lastName = studentData["lastName"] as? String
                }
            } else {
                self.displayError(errorString)
                
            }
        }
    }
    
    // Login Successful, Move on to Tab Bar Controller
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.passwordTextField.text = "" // remove password
            self.debugTextLabel.text = "Login Success!"
            if (self.debugTextLabel.text != nil)  {
                self.debugTextLabel.backgroundColor = UIColor.greenColor()
            }
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    //  Update Error Label with Message
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.debugTextLabel.text = errorString
                self.debugTextLabel.backgroundColor = UIColor.redColor()
                self.debugTextLabel.textColor = UIColor.whiteColor()
            }
        })
    }
    //  alert error Message
    func loginFailAlert(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                var loginFailureAlert = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                loginFailureAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { action in}))
                
                self.presentViewController(loginFailureAlert, animated: true, completion: nil)
            }
        })
    }
    
    //  Go to Udacity Website Sign Up Page
    @IBAction func signUpUdacity(sender: AnyObject) {
        if let url = NSURL(string: Client.Constants.UdacitySignUpURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}

//class LoginViewController: UIViewController, UITextFieldDelegate, UIApplicationDelegate {
//
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var debugTextLabel: UILabel!
//
//    var appDelegate: AppDelegate!
//    var session: NSURLSession!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        usernameTextField.delegate = self
//        passwordTextField.delegate = self
//
//        // Get the app delegate and session info
//        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        session = NSURLSession.sharedSession()
//
//    }
//
//    override func viewDidAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.debugTextLabel.text = ""
//        self.debugTextLabel.backgroundColor = UIColor.clearColor()
//    }
//
//
//
//    //  Dismiss keyboard if return key pressed
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
//            usernameTextField.resignFirstResponder()
//            passwordTextField.resignFirstResponder()
//        }
//        return true
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//    @IBAction func loginToUdacity(sender: AnyObject) {
//        let udacityClient = Client()
//        debugTextLabel.text = ""
//        var alertMsg : String = ""
//
//        udacityClient.loginToUdacity(usernameTextField.text, password: passwordTextField.text){
//            success, data, error in
//            if success {
//                // update loggedInStudent with returned data
//                self.appDelegate.loggedInStudent = Student(studentData: data)
//                self.getStudentData(udacityClient)
//
//                // go on to tab bar controller
//                self.completeLogin()
//            } else {
//
//                if error?.rangeOfString("username") != nil {
//                    self.displayError("Please enter an email!")
//                } else if error?.rangeOfString("password") != nil {
//                    self.displayError("Please enter password!")
//                } else {
//                    self.displayError(error)
////                   var loginFailureAlert = UIAlertController(title: "Login Failed", message: error, preferredStyle: UIAlertControllerStyle.Alert)
////                    loginFailureAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { action in}))
////
////                    self.presentViewController(loginFailureAlert, animated: true, completion: nil)
//                }
//
//            }
//        }
//    }
//
//    //  Get Students Data from Udacity
//    func getStudentData(udacityClient: Client) {
//
//        let key = appDelegate.loggedInStudent?.uniqueKey
//        udacityClient.getUdacityStudentData(key!){
//            data, errorString in
//
//            if let studentData = data {
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.appDelegate.loggedInStudent?.firstName = studentData["firstName"] as? String
//                    self.appDelegate.loggedInStudent?.lastName = studentData["lastName"] as? String
//                }
//            } else {
//                self.displayError(errorString)
//            }
//        }
//    }
//
//    // Login Successful, Move on to Tab Bar Controller
//    func completeLogin() {
//        dispatch_async(dispatch_get_main_queue(), {
//            self.passwordTextField.text = "" // remove password
//            self.debugTextLabel.text = "Login Success!"
//            if (self.debugTextLabel.text != nil)  {
//                self.debugTextLabel.backgroundColor = UIColor.greenColor()
//            }
//            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
//            self.presentViewController(controller, animated: true, completion: nil)
//        })
//    }
//
//    //  Update Error Label with Message
//    func displayError(errorString: String?) {
//        dispatch_async(dispatch_get_main_queue(), {
//            if let errorString = errorString {
//                self.debugTextLabel.text = errorString
//                self.debugTextLabel.backgroundColor = UIColor.redColor()
//                self.debugTextLabel.textColor = UIColor.whiteColor()
//            }
//        })
//    }
//
//    //  Go to Udacity Website Sign Up Page
//    @IBAction func signUpUdacity(sender: AnyObject) {
//        if let url = NSURL(string: Client.Constants.UdacitySignUpURL) {
//            UIApplication.sharedApplication().openURL(url)
//        }
//    }
//
//}

