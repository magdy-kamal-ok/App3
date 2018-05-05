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

    lazy var inputContainerView:ChatInputContainerView = {
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        
        chatInputContainerView.chatLogController = self
        
        return chatInputContainerView
        
//        let containerView = UIView()
//        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
//        
//        return containerView
        
    }()
    
    func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL
        {
            self.handleVideoSelectedForInfo(url: videoUrl)
        }
        else
        {
            self.handleImageSelectedForInfo(info: info)
        }
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
                        
                        let values = ["imageUrl":imageUrl, "videoUrl":storageUrl, "imageWidth":thumbnailImage.size.width , "imageHeight":thumbnailImage.size.height] as [String : AnyObject]
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
    
    private func thumbnailImageForVideoUrl(videoUrl:URL) -> UIImage?
    {
        let asset = AVAsset(url: videoUrl)
        let imageAssetGenerator = AVAssetImageGenerator(asset: asset)
        
        do
        {
            
            let thumbnailCGImage = try imageAssetGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
            
        }
        catch let err
        {
            
        }
        return nil
    }
    
    private func handleImageSelectedForInfo(info:[String:Any])
    {
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
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
        if let uploadData = UIImageJPEGRepresentation(image, 0.2)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
//        
    }
    
    func handleKeyboardDidShow(notification:NSNotification)
    {
        if messages.count > 0
        {
            let indexPath = NSIndexPath(item: self.messages.count-1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func handleKeyboardWillShow(notification:NSNotification)
    {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        // move the input area to top of keyboard height
        containerViewBottomAnchor?.constant = -(keyboardFrame?.height)!
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification:NSNotification)
    {
        
        
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        // move the input area to top of keyboard height
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
//    func setupInputComponents()
//    {
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(containerView)
//        
//        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
//        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        containerViewBottomAnchor?.isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    
//        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
//        
//        containerView.addSubview(sendButton)
//        
//        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//    
//
//        
//        containerView.addSubview(inputTextField)
//        
//        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:8).isActive = true
//        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
//        
//        
//        let separatorLineView = UIView()
//        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
//        separatorLineView.backgroundColor = UIColor.gray
//        
//        containerView.addSubview(separatorLineView)
//        
//        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:8).isActive = true
//        separatorLineView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//        separatorLineView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//    }
    
    func handleSend()
    {
        let values = ["text":self.inputContainerView.inputTextField.text] as [String : AnyObject]
        self.sendMessageWithProperties(properties: values)
    }
    
    func sendMessageWithImageUrl(imageUrl:String, image:UIImage)
    {
        let values = ["imageUrl":imageUrl, "imageWidth":image.size.width , "imageHeight":image.size.height] as [String : AnyObject]
        self.sendMessageWithProperties(properties: values)
    }

    private func sendMessageWithProperties(properties:[String:AnyObject])
    {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        let timeStamp:NSNumber = NSNumber(value: Date().timeIntervalSinceNow)
        var values:[String:AnyObject] = ["toId":toId, "fromId":fromId, "timeStamp":timeStamp] as [String : AnyObject]
        //childRef.updateChildValues(values)
        
        // append properties dictionary onto values somehow??
        // $0 is key $1 is value
        
        properties.forEach ({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil
            {
                return
            }
            self.inputContainerView.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!).child(toId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let receiptientUserMessageRef = Database.database().reference().child("user-messages").child(toId!).child(fromId!)
            
            receiptientUserMessageRef.updateChildValues([messageId:1])
        }

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
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
                message.setValuesForKeys(dictionary)
                
                
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
        return messages.count ?? 0
    }

     override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        cell?.chatLogController = self
        let message = messages[indexPath.item]
        cell?.textView.text = message.text
        cell?.message = message
        self.setupCell(cell: cell!, message: message)

        // set bubble width for the cell
        if let text = message.text
        {
            cell?.textView.isHidden = false
            cell?.bubbleWidthAnchor?.constant = self.estimatedFrameForText(text: text).width + 32
        }
        else if message.imageUrl != nil
        {
            cell?.textView.isHidden = true
            cell?.bubbleWidthAnchor?.constant = 200
        }
        if message.videoUrl != nil
        {
            cell?.playButton.isHidden = false
        }
        else
        {
            cell?.playButton.isHidden = true
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height:CGFloat = 80
        let message = messages[indexPath.item]
        
        if let text = message.text{
            height = self.estimatedFrameForText(text: text).height + 20
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue
        {
            
            // h1/w1 = h2/w2
            // h1 = h2 / (w1*w2)
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        // this width because of the accessairy input
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    
    private func setupCell(cell:ChatMessageCell, message:Message)
    {

        if let profileImageUrl = self.user?.profileImageUrl
        {
            cell.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
        }
        if message.fromId == Auth.auth().currentUser?.uid
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
        if let messageImageUrl = message.imageUrl
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
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
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
    
    func handleZoomOutTap(tapGesture:UITapGestureRecognizer)
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
