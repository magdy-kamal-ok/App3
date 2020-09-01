//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by magdy on 4/13/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    
    var chatLogController:ChatLogController?
    static let blueColor = UIColor.rgb(red: 0, green: 137, blue: 249, alpha: 1)
    static let grayColor = UIColor.rgb(red: 240, green: 240, blue: 240, alpha: 1)
    var bubbleWidthAnchor:NSLayoutConstraint?
    var bubbleViewRightAnchor:NSLayoutConstraint?
    var bubbleViewLeftAnchor:NSLayoutConstraint?
    var message:Message?
    var playerLayer:AVPlayerLayer?
    var player:AVPlayer?
    
    let activityIndicator:UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    lazy var playButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("play", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
        return button
    }()
    let textView:UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 16)
        view.backgroundColor = UIColor.clear
        view.textColor = .white
        view.isEditable = false
        return view
    }()
    let bubbleView:UIView = {
        let view = UIView()
        view.backgroundColor = ChatMessageCell.blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView:CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImageView:CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    @objc func handlePlayButton()
    {
        if let messageUrlString = message?.videoUrl, let url = URL(string: messageUrlString)
        {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            activityIndicator.startAnimating()
            player?.play()
            playButton.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // this because of reusing cell
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    
    @objc func handleZoomTap(tapGesture:UITapGestureRecognizer)
    {
        // Pro Tip do not perform custom logic inside view class
        
        
        if  message?.videoUrl != nil
        {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView
        {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        setupBubbleView()
        setupTextView()
        setupProfileImageView()
        setupMessageImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextView(){
        textView.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor, constant:8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.rightAnchor.constraint(equalTo: self.bubbleView.rightAnchor).isActive = true

    }
    
    func setupBubbleView(){
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant:-8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant:8)
        bubbleViewLeftAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
    }
    
    func setupProfileImageView(){
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant:8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func setupMessageImageView(){
        messageImageView.leftAnchor.constraint(equalTo: self.bubbleView.leftAnchor, constant:8).isActive = true
        messageImageView.topAnchor.constraint(equalTo: self.bubbleView.topAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: self.bubbleView.heightAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: self.bubbleView.widthAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        
        
        playButton.centerXAnchor.constraint(equalTo: self.bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant:50).isActive = true
        playButton.widthAnchor.constraint(equalToConstant:50).isActive = true
        
        
        bubbleView.addSubview(activityIndicator)
        
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.bubbleView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant:50).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant:50).isActive = true
        
    }
}
