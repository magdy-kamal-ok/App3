//
//  User.swift
//  ChatApp
//
//  Created by magdy on 4/12/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit

class UserPerson: NSObject {
    var id:String?
    var name:String?
    var email:String?
    var profileImageUrl:String?
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }

}
