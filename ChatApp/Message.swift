//
//  Message.swift
//  ChatApp
//
//  Created by magdy on 4/13/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId:String?
    var toId:String?
    var text:String?
    var timeStamp:NSNumber?
    var imageUrl:String?
    var imageHeight:NSNumber?
    var imageWidth:NSNumber?
    var videoUrl:String?
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timeStamp = dictionary["timeStamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.videoUrl = dictionary["videoUrl"] as? String
    }
    func chatPartnerId()-> String?{
        let chatPartnerId:String?
        if self.fromId == Auth.auth().currentUser?.uid{
            chatPartnerId = self.toId
        }
        else{
            chatPartnerId = self.fromId
        }
        return chatPartnerId
    }
}
