//
//  User.swift
//  Swift_Course_Egorov_VKFriends
//
//  Created by Илья Егоров on 17.11.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

import UIKit

class User {
    var userId: NSNumber?
    var firstName: String?
    var lastName: String?
    var fullName: String {
        get {
            guard let name = firstName else {
                return lastName ?? ""
            }
            return name + " " + (lastName ?? "")
        }
    }
    var avatarImageURLString: String?
    
    convenience init(_ dictionary: [String: AnyObject]) {
        self.init()
        
        userId = dictionary["uid"] as? NSNumber
        firstName = dictionary["first_name"] as? String
        lastName = dictionary["last_name"] as? String
        avatarImageURLString = dictionary["photo_50"] as? String
    }
}
