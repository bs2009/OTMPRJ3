//
//  TableViewController.swift
//  P4
//
//  Created by William Song on 6/22/15.
//  Copyright (c) 2015 Bill Song. All rights reserved.
//


import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var appDelegate: AppDelegate!
    var studentList: [Student]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //manually install two button on navigation bar
        var rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refresh:")
        var rightLocateButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "locateStudent:")
        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem, rightLocateButtonItem], animated: true)
        
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        studentList = appDelegate?.allStudents        
        tableView.delegate = self
        self.reloadTableData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()

    }
    
    // 3 table view routines
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentList!.count
    }
    // display table view cell contents
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! UITableViewCell
        let studentCell = studentList![indexPath.row]
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = "\(studentCell.firstName!) \(studentCell.lastName!)"
        cell.detailTextLabel?.text = studentCell.mediaURL
        
        return cell
    }
    
    // open media url
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) {
            if let mediaURL = self.studentList![indexPath.row].mediaURL {
                
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
    

    // Log out of Udacity Session and Return to Login page
    @IBAction func logoutButtonTouchUp(sender: AnyObject) {
        let openSession = Client.sharedInstance()
        openSession.logoutOfUdacity()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // Refresh the data model
    func refresh(sender: AnyObject) {
        let dataClient = Client.sharedInstance()
        
        dataClient.getStudentLocations() {
            students, errorString in
            
            if let students = students {
                
                if let appDelegate = self.appDelegate {
                    var studentsData: [Student] = [Student]()
                    
                    for studentResults in students {
                        studentsData.append(Student(studentData: studentResults))
                    }
                    appDelegate.allStudents = studentsData
                    self.studentList = studentsData
                    self.reloadTableData()
                }
            } else {
                if let error = errorString {
                    println(error)
                }
            }
        }
    }
    
    // Post new student location, checking for existing
    func locateStudent(sender: AnyObject) {
        let client = Client.sharedInstance()
        client.queryForStudentLocation() {
            data, error in
            
            if error == nil { // no error occur
                if let data = data { // access data
                    if data.count > 0 { // there record available
                        // alert the user of the existing location pin
                        var alert = UIAlertController(title: "Pin Exists", message: "You have posted your location.", preferredStyle: UIAlertControllerStyle.ActionSheet)
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                        }))
                        
                        alert.addAction(UIAlertAction(title: "Delete & Post New", style: .Default, handler: { action in
                            client.deleteExistingPosts(data)
                            // Segue to info posting controller
                            self.performSegueWithIdentifier("TableToInfo", sender: self)
                        }))
                        self.reloadTableData()
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else { // send to post info anyway
                        self.performSegueWithIdentifier("TableToInfo", sender: self)
                    }
                }
            } else { // error
                println("unable to query existing posts")
            }
        } //end of query
    }
    
    //  Reload the table cell data
    func reloadTableData() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
       }
    }
}












