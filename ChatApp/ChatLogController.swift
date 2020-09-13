//
//  ChatLogController.swift
//  ChatApp
//
//  Created by magdy on 4/13/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    var user:UserPerson?{
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var containerViewBottomAnchor:NSLayoutConstraint?
    var startingFrame:CGRect?
    var blackBackgroundView:UIView?
    var startingImageView:UIImageView?
    var messages = [Message]()
    private let fileChooser = FileChooser()
    
    lazy var inputContainerView:ChatInputContainerView = {
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 15))
        
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    @objc func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.handleImageSelectedForInfo(info: info)
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForInfo(url:URL)
    {
        let fileName = NSUUID().uuidString+".mov"
        let uploadTask = Storage.storage().reference().child("message_movies").child(fileName).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil
            {
                return
            }
            if let storageUrl = metadata?.downloadURL()?.absoluteString
            {
                if let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl: url)
                {
                    self.uploadToFireBaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        let values = ["messageType": "video", "message": storageUrl] as [String : AnyObject]
                        //                        let values = ["imageUrl":imageUrl, "videoUrl":storageUrl, "imageWidth":thumbnailImage.size.width , "imageHeight":thumbnailImage.size.height] as [String : AnyObject]
                        self.sendMessageWithProperties(properties: values)
                        
                    })
                    
                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            
            if let completedUnitCount = snapshot.progress?.completedUnitCount
            {
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            
            self.navigationItem.title = self.user?.name
        }
    }
    
    @objc func handleUploadFileTap() {
        fileChooser.viewController = self
        fileChooser.selectionCompletion = { [weak self] (name: String, type: String, localURL: String, data: Data?) in
            guard let self = self, let data = data else { return }
            let ref = Storage.storage().reference().child("message_file").child(name)
            ref.putData(data, metadata: nil, completion: { (metadata, error) in
                guard error == nil else { return }
                if let fileURL = metadata?.downloadURL()?.absoluteString {
                    let values = ["messageType": "file", "message": fileURL] as [String: AnyObject]
                    self.sendMessageWithProperties(properties: values)
                }
            })
        }
        fileChooser.chooseFile()
    }
    
    private func thumbnailImageForVideoUrl(videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageAssetGenerator = AVAssetImageGenerator(asset: asset)
        do {
            if let thumbnailCGImage = try? imageAssetGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil) {
                return UIImage(cgImage: thumbnailCGImage)
            }
        }
        return nil
    }
    
    private func handleImageSelectedForInfo(info:[UIImagePickerController.InfoKey: Any])
    {
        var selectedImageFromPicker:UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            //profileImageView.image = selectedImage
            //uploadToFireBaseStorageUsingImage(image: selectedImage)
            uploadToFireBaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image:selectedImage)
                
            })
        }
        
    }
    
    func uploadToFireBaseStorageUsingImage(image:UIImage, completion:@escaping (_ imageUrl:String)->())
    {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_image").child(imageName)
        if let uploadData = image.jpegData(compressionQuality: 0.2)
        {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil
                {
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString
                {
                    completion(imageUrl)
                    //self.sendMessageWithImageUrl(imageUrl: imageUrl, image:image)
                }
            })
        }
    }
    
    override var inputAccessoryView: UIView?{
        get{
            
            return inputContainerView
        }
        
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        collectionView.becomeFirstResponder()
        
        // we will use user accessory view
        //setupInputComponents()
        setupKeyboardObservers()
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // this for memory leak
        NotificationCenter.default.removeObserver(self)
    }
    func setupKeyboardObservers()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        //
    }
    
    @objc func handleKeyboardDidShow(notification:NSNotification)
    {
        if messages.count > 0
        {
            let indexPath = NSIndexPath(item: self.messages.count-1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification:NSNotification)
    {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        // move the input area to top of keyboard height
        containerViewBottomAnchor?.constant = -(keyboardFrame?.height)!
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification:NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        // move the input area to top of keyboard height
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleSend() {
        guard let text = self.inputContainerView.inputTextField.text else { return }
        let values = ["message": text, "messageType": "text"] as [String : AnyObject]
        self.sendMessageWithProperties(properties: values)
    }
    
    func sendMessageWithImageUrl(imageUrl:String, image:UIImage) {
        let values = ["messageType":"image", "message": imageUrl] as [String : AnyObject]
        self.sendMessageWithProperties(properties: values)
    }
    
    private func sendMessageWithProperties(properties:[String:AnyObject])
    {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let receiverId = user?.chatId
        let senderId = Auth.auth().currentUser?.uid
        let time:NSNumber = NSNumber(value: Date().timeIntervalSinceNow)
        var values:[String:AnyObject] = ["receiverId":receiverId, "senderId":senderId, "time":time] as [String: AnyObject]
        properties.forEach ({values[$0] = $1})
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                return
            }
            self.inputContainerView.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(senderId!).child(receiverId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let receiptientUserMessageRef = Database.database().reference().child("user-messages").child(receiverId!).child(senderId!)
            
            receiptientUserMessageRef.updateChildValues([messageId:1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.chatId else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                //potential of crashing if keys don't match
                //message.setValuesForKeys(dictionary)
                
                
                // this check for filtering related data to only this user
                //                if message.chatPartnerId() == self.user?.id {
                self.messages.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    // scroll to last element
                    let indexPath = NSIndexPath(item: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                })
                //                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        cell?.chatLogController = self
        let message = messages[indexPath.item]
        cell?.textView.text = message.message
        cell?.message = message
        self.setupCell(cell: cell!, message: message)
        
        // set bubble width for the cell
        if message.messageType == "text", let text = message.message {
            cell?.textView.isHidden = false
            cell?.bubbleWidthAnchor?.constant = self.estimatedFrameForText(text: text).width + 32
        } else if message.messageType == "image", message.message != nil {
            cell?.textView.isHidden = true
            cell?.bubbleWidthAnchor?.constant = 200
        } else if message.messageType == "file", message.message != nil {
            cell?.textView.isHidden = false
            cell?.textView.text = "Attached File"
            cell?.bubbleWidthAnchor?.constant = self.estimatedFrameForText(text: "Attached File").width + 32
        }
        
        if message.messageType == "video", message.message != nil {
            cell?.playButton.isHidden = false
        } else {
            cell?.playButton.isHidden = true
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        let message = messages[indexPath.item]
        let text = message.messageType == "file" ? "Attached File" : message.message
        if let text = text {
            height = self.estimatedFrameForText(text: text).height + 20
        }
        //        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue
        //        {
        //
        //            // h1/w1 = h2/w2
        //            // h1 = h2 / (w1*w2)
        //            height = CGFloat(imageHeight / imageWidth * 200)
        //
        //        }
        // this width because of the accessairy input
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    
    private func setupCell(cell:ChatMessageCell, message:Message)
    {
        
        if let profileImageUrl = self.user?.imageUrl
        {
            cell.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
        }
        if message.senderId == Auth.auth().currentUser?.uid
        {
            // blue message
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
        }
        else
        {
            cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false 
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        if message.messageType == "image" || message.messageType == "video",
            let messageImageUrl = message.message
        {
            cell.messageImageView.isHidden = false
            cell.messageImageView.loadImageUsingUrlString(urlString: messageImageUrl)
            cell.bubbleView.backgroundColor = .clear
        }
        else{
            cell.messageImageView.isHidden = true
        }
        
    }
    private func estimatedFrameForText(text:String) ->CGRect
    {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    // here is the custom zooming logic 
    func performZoomInForStartingImageView(startingImageView:UIImageView)
    {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutTap)))
        if let keyWindow = UIApplication.shared.keyWindow
        {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = UIColor.black
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { 
                
                self.inputContainerView.alpha = 0
                self.blackBackgroundView?.alpha = 1
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
            
        }
    }
    
    @objc func handleZoomOutTap(tapGesture:UITapGestureRecognizer)
    {
        if let zoomOutImageView = tapGesture.view as? UIImageView{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed:Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
        }
    }
    
}
