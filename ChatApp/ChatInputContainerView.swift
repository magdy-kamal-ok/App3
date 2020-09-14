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
    
    weak var chatLogController:ChatLogController?{
        didSet{
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            galleryButton.addTarget(chatLogController, action: #selector(ChatLogController.handleUploadTap), for: .touchUpInside)
            cameraButton.addTarget(chatLogController, action: #selector(ChatLogController.handleUploadTap), for: .touchUpInside)
            fileButton.addTarget(chatLogController, action: #selector(ChatLogController.handleUploadFileTap), for: .touchUpInside)
            animateChatInputContainerView()
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
        let sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named: "ic-send"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        return sendButton
    }()
    
    lazy var inputTextFieldContainderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let addButton:UIButton = {
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "ic-plus"), for: .normal)
        addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    
    let cameraButton:UIButton = {
        let cameraButton = UIButton(type: .custom)
        cameraButton.setImage(UIImage(named: "ic-camera-picker"), for: .normal)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        return cameraButton
    }()
    
    let galleryButton:UIButton = {
        let galleryButton = UIButton(type: .custom)
        galleryButton.setImage(UIImage(named: "ic-gallery-picker"), for: .normal)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        return galleryButton
    }()
    
    let fileButton:UIButton = {
        let fileButton = UIButton(type: .custom)
        fileButton.setImage(UIImage(named: "ic-file-picker"), for: .normal)
        fileButton.translatesAutoresizingMaskIntoConstraints = false
        return fileButton
    }()
    
    lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "chatContainerColor")
        return view
    }()
    
    lazy var topContainerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(named: "chatAdditionalFunctions")
        return view
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .gray
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 24
        return stackView
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(topContainerView)
        verticalStackView.addArrangedSubview(bottomContainerView)
        addBottomContainer()
        addTopContainer()
    }
    
    func addTopContainer () {
        topContainerView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(cameraButton)
        horizontalStackView.addArrangedSubview(galleryButton)
        horizontalStackView.addArrangedSubview(fileButton)
        self.horizontalStackView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 8).isActive = true
        self.horizontalStackView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 8).isActive = true
        self.horizontalStackView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -8).isActive = true

    }
    func addBottomContainer () {
        self.verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.verticalStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.bottomContainerView.addSubview(addButton)
        addButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16).isActive = true
        addButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant:34).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        
        addSubview(inputTextFieldContainderView)
        self.inputTextFieldContainderView.leadingAnchor.constraint(equalTo: addButton.trailingAnchor , constant:16).isActive = true
        self.inputTextFieldContainderView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -16).isActive = true
        self.inputTextFieldContainderView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.inputTextFieldContainderView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16).isActive = true
        self.inputTextFieldContainderView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16).isActive = true
        
        self.inputTextFieldContainderView.addSubview(sendButton)
        sendButton.trailingAnchor.constraint(equalTo: self.inputTextFieldContainderView.trailingAnchor, constant: -8).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: self.inputTextFieldContainderView.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        self.inputTextFieldContainderView.addSubview(self.inputTextField)
        
        self.inputTextField.leadingAnchor.constraint(equalTo: inputTextFieldContainderView.leadingAnchor, constant:8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: self.inputTextFieldContainderView.centerYAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: self.inputTextFieldContainderView.heightAnchor).isActive = true
        self.inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextFieldContainderView.invalidateIntrinsicContentSize()
        chatLogController?.handleSend()
        return true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: chatLogController?.collectionView.frame.width ?? 100, height: 55)
    }
    
    func animateChatInputContainerView() {
        UIView.animate(withDuration: 0.1) {
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
    @objc func handleAddButton() {
        topContainerView.isHidden = !topContainerView.isHidden
        if topContainerView.isHidden {
            addButton.setImage(UIImage(named: "ic-plus"), for: .normal)
        } else {
            addButton.setImage(UIImage(named: "ic-close"), for: .normal)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        inputTextFieldContainderView.layer.cornerRadius = inputTextFieldContainderView.frame.height/2
        
    }
    
}
