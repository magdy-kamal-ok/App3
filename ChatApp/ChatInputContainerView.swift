//
//  ChatInputContainerView.swift
//  ChatApp
//
//  Created by magdy on 5/5/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import Foundation
import UIKit
class ChatInputContainerView : UIView,UITextFieldDelegate
{
    
    var chatLogController:ChatLogController?{
        didSet{
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))

        }
        
    }
    
    lazy var inputTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Text Field"
        textField.delegate = self
        return textField
    }()
    let sendButton:UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        return sendButton
    }()
    let uploadImageView:UIImageView =
    {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "image")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        return uploadImageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        

//        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        self.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant:44).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        self.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        
        self.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor , constant:8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        
        let separatorLineView = UIView()
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.backgroundColor = UIColor.gray
        
        self.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: self.leftAnchor, constant:8).isActive = true
        separatorLineView.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLineView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
}
