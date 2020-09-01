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
            self.detailTextLabel?.text = self.message?.text
            if let seconds = message?.timeStamp?.doubleValue
            {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                self.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    let profileImageView:CustomImageView={
        let imageView = CustomImageView()
        //        imageView.image = UIImage(named: "image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
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
//                    user.id = id
                   // user.setValuesForKeys(dictionary)
                    self.textLabel?.text = user.name
                    self.detailTextLabel?.text = self.message?.text
                    
                    if let profileImageUrl = user.profileImageUrl{
                        
                        self.profileImageView.loadImageUsingUrlString(urlString: profileImageUrl)
                    }
                    
                }
                
            }, withCancel: nil)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y+2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        setupProfileImageView()
        setupTimeLabel()
    }
    func setupProfileImageView(){
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor,constant:8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    func setupTimeLabel(){
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
    
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
