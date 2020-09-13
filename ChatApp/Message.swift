//
//  Message.swift
//  ChatApp
//
//  Created by magdy on 4/13/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase

//class Message: NSObject {
//    var fromId:String?
//    var toId:String?
//    var text:String?
//    var timeStamp:NSNumber?
//    var imageUrl:String?
//    var imageHeight:NSNumber?
//    var imageWidth:NSNumber?
//    var videoUrl:String?
//    init(dictionary: [String: Any]) {
//        self.fromId = dictionary["fromId"] as? String
//        self.text = dictionary["text"] as? String
//        self.toId = dictionary["toId"] as? String
//        self.timeStamp = dictionary["timeStamp"] as? NSNumber
//        self.imageUrl = dictionary["imageUrl"] as? String
//        self.imageWidth = dictionary["imageWidth"] as? NSNumber
//        self.imageHeight = dictionary["imageHeight"] as? NSNumber
//        self.videoUrl = dictionary["videoUrl"] as? String
//    }
//    func chatPartnerId()-> String?{
//        let chatPartnerId:String?
//        if self.fromId == Auth.auth().currentUser?.uid{
//            chatPartnerId = self.toId
//        }
//        else{
//            chatPartnerId = self.fromId
//        }
//        return chatPartnerId
//    }
//}

class Message: NSObject {
    var message:String?
    var messageType: String?
    var read: Bool?
    var receiverId:String?
    var senderId:String?
    var time:NSNumber?
    
    init(dictionary: [String: Any]) {
        self.message = dictionary["message"] as? String
        self.messageType = dictionary["messageType"] as? String
        self.read = dictionary["read"] as? Bool
        self.receiverId = dictionary["receiverId"] as? String
        self.senderId = dictionary["senderId"] as? String
        self.time = dictionary["time"] as? NSNumber
    }
    
    func chatPartnerId()-> String?{
        let chatPartnerId:String?
        if self.senderId == Auth.auth().currentUser?.uid{
            chatPartnerId = self.receiverId
        } else {
            chatPartnerId = self.senderId
        }
        return chatPartnerId
    }
}
