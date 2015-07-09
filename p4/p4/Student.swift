//
//  Student.swift
//  P4
//
//  Created by William Song on 5/22/15.
//  Copyright (c) 2015 Bill Song. All rights reserved.
//

import Foundation

struct Student {
    
    var firstName:  String!
    var lastName:   String!
    var uniqueKey:  String!
    var mediaURL:   String!
    var latitude:   Double!
    var longitude:  Double!
    
    init(studentData: [String: AnyObject]?) {
        
        if let studentData = studentData {
            if let uniqueKey = studentData["uniqueKey"] as? String {
                self.uniqueKey = uniqueKey
            }
            
            if let firstName = studentData["firstName"] as? String {
                self.firstName = firstName
            }
            
            if let lastName = studentData["lastName"] as? String {
                self.lastName = lastName
            }
            
            if let mediaURL = studentData["mediaURL"] as? String {
                self.mediaURL = mediaURL
            }
            
            if let latitude = studentData["latitude"] as? Double {
                self.latitude = latitude
            }
            
            if let longitude = studentData["longitude"] as? Double {
                self.longitude = longitude
            }
        }
    }
}