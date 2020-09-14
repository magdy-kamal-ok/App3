//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by magdy on 4/13/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class ChatMessageCell: UICollectionViewCell {
    
    weak var chatLogController:ChatLogController?
    static let blueColor = #colorLiteral(red: 0.1668872535, green: 0.2896803617, blue: 0.4808027148, alpha: 1)
    static let grayColor = #colorLiteral(red: 0.9638487697, green: 0.9687198997, blue: 0.9772059321, alpha: 1)
    var bubbleWidthAnchor:NSLayoutConstraint?
    var bubbleViewTrailingAnchor:NSLayoutConstraint?
    var bubbleViewLeadingAnchor:NSLayoutConstraint?
    var timeLabelLeadingAnchor:NSLayoutConstraint?
    var timeLabelTrailingAnchor:NSLayoutConstraint?
    var message: Message? {
        didSet {
            textView.isSelectable = message?.messageType != "file"
            fileIconImageView.isHidden = message?.messageType != "file"
        }
    }
    var isSender = false
//    var playerLayer:AVPlayerLayer?
//    var player:AVPlayer?
//
//    let activityIndicator:UIActivityIndicatorView = {
//        let aiv = UIActivityIndicatorView(style: .whiteLarge)
//        aiv.translatesAutoresizingMaskIntoConstraints = false
//        return aiv
//    }()
//
//    lazy var playButton:UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("play", for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
//        return button
//    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [fileIconImageView, textView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        return view
    }()

    let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 16)
        view.backgroundColor = UIColor.clear
        view.textColor = .white
        view.isEditable = false
        return view
    }()
    
    lazy var fileIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "ic-file-picker")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = ChatMessageCell.blueColor
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
       
    let timeLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
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
    
//    @objc func handlePlayButton()
//    {
//        if let messageUrlString = message?.message, let url = URL(string: messageUrlString)
//        {
//            player = AVPlayer(url: url)
//            playerLayer = AVPlayerLayer(player: player)
//            playerLayer?.frame = bubbleView.bounds
//            bubbleView.layer.addSublayer(playerLayer!)
//            activityIndicator.startAnimating()
//            player?.play()
//            playButton.isHidden = true
//        }
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isSender {
            bubbleView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 16)
        } else {
            bubbleView.roundCorners(corners: [.topRight, .bottomRight], radius: 16)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // this because of reusing cell
//        playerLayer?.removeFromSuperlayer()
//        player?.pause()
//        activityIndicator.stopAnimating()
        bubbleView.layer.cornerRadius = 0
    }
    
    @objc func handleZoomTap(tapGesture:UITapGestureRecognizer)
    {
        // Pro Tip do not perform custom logic inside view class
        
        
        if  message?.message == nil
        {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView
        {
            self.chatLogController?.performZoomInForStartingImageView(startingImageView: imageView)
        }
    }
    
    @objc func handleCellTap(tapGesture: UITapGestureRecognizer) {
        guard let message = message, let body = message.message else { return }
        if  message.messageType == "file" {
            if let url = URL(string: body) {
                UIApplication.shared.open(url)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        self.addGestureRecognizer(tap)
        addSubview(bubbleView)
        addSubview(timeLabel)
        bubbleView.addSubview(stackView)
        bubbleView.addSubview(messageImageView)
        setupBubbleView()
        setupTextView()
        setupTimeLabel()
        setupMessageImageView()
        setupFileIconImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFileIconImageView() {
        fileIconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        fileIconImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func setupTextView() {
        stackView.leadingAnchor.constraint(equalTo: self.bubbleView.leadingAnchor, constant:8).isActive = true
        stackView.topAnchor.constraint(equalTo: self.bubbleView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bubbleView.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.bubbleView.trailingAnchor, constant: -8).isActive = true
    }
    
    func setupTimeLabel() {
        timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 8).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true
        timeLabelLeadingAnchor = timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        timeLabelLeadingAnchor?.isActive = false
        timeLabelTrailingAnchor = timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        timeLabelTrailingAnchor?.isActive = false
    }
    
    func setupBubbleView() {
        bubbleViewTrailingAnchor = bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        bubbleViewTrailingAnchor?.isActive = true
        
        bubbleViewLeadingAnchor = bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor)
        bubbleViewLeadingAnchor?.isActive = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 250)
        bubbleWidthAnchor?.isActive = true
    }
        
    func setupMessageImageView(){
        messageImageView.leadingAnchor.constraint(equalTo: self.bubbleView.leadingAnchor, constant:8).isActive = true
        messageImageView.trailingAnchor.constraint(equalTo: self.bubbleView.trailingAnchor, constant:-8).isActive = true
        messageImageView.topAnchor.constraint(equalTo: self.bubbleView.topAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: self.bubbleView.heightAnchor).isActive = true
//        messageImageView.widthAnchor.constraint(equalTo: self.bubbleView.widthAnchor).isActive = true
        
//        bubbleView.addSubview(playButton)
//
//
//        playButton.centerXAnchor.constraint(equalTo: self.bubbleView.centerXAnchor).isActive = true
//        playButton.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
//        playButton.heightAnchor.constraint(equalToConstant:50).isActive = true
//        playButton.widthAnchor.constraint(equalToConstant:50).isActive = true
//
//
//        bubbleView.addSubview(activityIndicator)
//
//
//        activityIndicator.centerXAnchor.constraint(equalTo: self.bubbleView.centerXAnchor).isActive = true
//        activityIndicator.centerYAnchor.constraint(equalTo: self.bubbleView.centerYAnchor).isActive = true
//        activityIndicator.heightAnchor.constraint(equalToConstant:50).isActive = true
//        activityIndicator.widthAnchor.constraint(equalToConstant:50).isActive = true
        
    }
}
