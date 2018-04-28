//
//  LoginControllers+Handlers.swift
//  ChatApp
//
//  Created by magdy on 4/12/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase
extension LoginController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    

    func handleProfileImageView()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.isEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    private func  registerUserIntoDataBaseWithUID(uid:String,values:[String:AnyObject]){
        let ref = Database.database().reference(fromURL: "https://gameofchats-c271d.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)

        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil
            {
                return
            }
            //self.messagesController?.fetchUserAndSetupNavBarTitle()
            let user = UserPerson(dictionary: values)
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func handleRegister()
    {
        // guard statement are useful for forms and validation
        guard let email = emailTextField.text , let password = passwordTextField.text , let name = nameTextField.text else
        {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password){ (user:User?, error) in
            
            if error != nil
            {
                return
            }
            guard let uid = user?.uid else{return}
            
            let imageName = NSUUID().uuidString
            //let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")

            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
            // this png for full resolution of an image but jpeg has ratio
            //if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!)
            {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    {
                       let values = ["name":name,"email":email,"profileImageUrl":profileImageUrl]
                        
                        self.registerUserIntoDataBaseWithUID(uid: uid, values: values as [String : AnyObject])
                        
                    }
                })
            }
            
            
        }
    }
}
