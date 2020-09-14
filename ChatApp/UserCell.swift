//
//  UserCell.swift
//  ChatApp
//
//  Created by magdy on 4/13/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase
class UserCell: UITableViewCell {
    
    var message:Message?{
        didSet{
            self.setupNameAndProfile()
            self.lastMessageLabel.text = self.message?.message
            if let seconds = message?.time?.doubleValue
            {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    
    let mainView: UIView={
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.2193653682)
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        return view
    }()
    
    let profileImageView: CustomImageView={
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 29
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    let nameLabel:UILabel={
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: 16)
         label.textColor = UIColor.black
         return label
     }()
    
    let lastMessageLabel:UILabel={
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: 13)
         label.textColor = UIColor.lightGray
         return label
     }()
    
    private func setupNameAndProfile(){
        
        
        
        if let id = message?.chatPartnerId()
        {
            let ref = Database.database().reference().child("users").child(id)
            
            ref.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject]
                {
                    let user = UserPerson(dictionary: dictionary)
                    self.nameLabel.text = user.name
                    self.lastMessageLabel.text = self.message?.message
                    
                    if let profileImageUrl = user.imageUrl {
                        
                        self.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
                    }
                    
                }
                
            }, withCancel: nil)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        addSubview(mainView)
        mainView.addSubview(profileImageView)
        mainView.addSubview(timeLabel)
        mainView.addSubview(nameLabel)
        mainView.addSubview(lastMessageLabel)
        setupMainView()
        setupProfileImageView()
        setupTimeLabel()
        setupNameLabel()
        setupLastMessageLabel()
    }
    
    func setupMainView(){
        mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant:16).isActive = true
        mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant:-16).isActive = true
        mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:16).isActive = true
        mainView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

    }
    
    func setupProfileImageView(){
        profileImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor,constant:8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 58).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 58).isActive = true
    }
    func setupTimeLabel(){
        timeLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor,constant:-8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
        
    }
    
    func setupNameLabel(){
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor,constant:8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant:8).isActive = true
//        timeLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
    }
    
    func setupLastMessageLabel(){
         lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
         lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant:8).isActive = true
         lastMessageLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
         lastMessageLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
