//
//  ViewController.swift
//  ChatApp
//
//  Created by magdy on 4/11/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase
class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    var timer:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "new message", style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        
        tableView.allowsSelectionDuringEditing = true
        
        checkIfUserIsLoggedIn()
        //observeMessages()
   }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func observeUserMessages()
    {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key

                self.fetchMessageWithMessageID(messageId: messageId)
            }, withCancel: nil)
                
            
                
            }, withCancel: nil)
            
            ref.observe(.childRemoved, with: { (snapshot) in
                
                self.messagesDictionary.removeValue(forKey: snapshot.key)
                self.attemptReloadOfTable()
                
            }, withCancel: nil)
            
 
    }
    
    private func fetchMessageWithMessageID(messageId:String)
    {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
    
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
    
        if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
    
                if let chatPartnerId = message.chatPartnerId() {
                self.messagesDictionary[chatPartnerId] = message
    
    
                }
    
        //this will crash because of background thread, so lets call this on dispatch_async main thread
    
                self.attemptReloadOfTable()
            }
    
        }, withCancel: nil)
    }
//    func observeMessages()
//    {
//        let ref = Database.database().reference().child("messages")
//
//        ref.observe(.childAdded, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String:AnyObject]{
//                let message = Message()
//
//                message.setValuesForKeys(dictionary)
//               // self.messages.append(message)
//                if let toId = message.toId{
//                    self.messagesDictionary[toId] = message
//                    self.messages = Array(self.messagesDictionary.values)
//                    self.messages.sort(by: { (m1, m2) -> Bool in
//                        return (m1.timeStamp?.intValue)! > (m2.timeStamp?.intValue)!
//                    })
//                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()    
//                }
//                
//            }
//        }, withCancel: nil)
//    }
    
    func checkIfUserIsLoggedIn()
    {
        // check if user is loggedin or not
        if Auth.auth().currentUser?.uid == nil{
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            //handleLogout()
        }
        else{
            fetchUserAndSetupNavBarTitle()
        
        }
        
    }
    private func attemptReloadOfTable()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    @objc func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timeStamp?.int32Value)! > (message2.timeStamp?.int32Value)!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]
            {
//                self.navigationItem.title = dictionary["name"] as? String
                let user = UserPerson(dictionary: dictionary)
                //user.setValuesForKeys(dictionary)
        
                self.setupNavBarWithUser(user: user)
                
            }
        }, withCancel: nil)
        
        
    }
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        self.present(UINavigationController(rootViewController:newMessageController), animated: true, completion: nil)
    }
    
    @objc func handleLogout(){
        do
        {
            try Auth.auth().signOut()
        }
        catch let logoutError
        {
            
        }
        let loginController = LoginController()
        loginController.messagesController = self
        self.present(loginController, animated: true, completion: nil)
    }
    
    func setupNavBarWithUser(user:UserPerson)
    {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()

        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        
        let profileImageView = CustomImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        if let profileImageUrl = user.profileImageUrl
        {
            profileImageView.loadImageUsingUrlString(urlString:profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        // constraints ios 9 
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.text = user.name
        
        containerView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant:8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        

       // titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatControllerForUser)))
        self.navigationItem.titleView = titleView
    }
    
    func showChatControllerForUser(user:UserPerson)
    {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String:AnyObject] else {return}
            
            let user = UserPerson(dictionary: dictionary)
            user.id = chatPartnerId
            //user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId()
        {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil
                {
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                //                self.messages.remove(at: indexPath.row)
                //                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    
}

