//
//  LoginController.swift
//  ChatApp
//
//  Created by magdy on 4/11/18.
//  Copyright © 2018 magdy. All rights reserved.
//

import UIKit
import Firebase
class LoginController: UIViewController {
    var messagesController:MessagesController?

    let inputContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    lazy var loginRegisterButton:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 80, green: 101, blue: 161, alpha: 1)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    lazy var profileImageView:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "image")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var loginRegisterSegmentedControl:UISegmentedControl = {
        let sc = UISegmentedControl(items: ["login","register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterSegmentChange), for: .valueChanged)
        return sc
    
    }()
    var inputViewControllerHeightAnchor:NSLayoutConstraint?
    var nameTextFieldHeightAnchor:NSLayoutConstraint?
    var emailTextFieldHeightAnchor:NSLayoutConstraint?
    var passwordTextFieldHeightAnchor:NSLayoutConstraint?
    @objc func handleLoginRegisterSegmentChange()
    {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        inputViewControllerHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 :150
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor =  nameTextField.heightAnchor.constraint(equalTo:inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : (1/3))
        nameTextFieldHeightAnchor?.isActive = true
        
    
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor =  emailTextField.heightAnchor.constraint(equalTo:inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? (1/2) : (1/3))
        emailTextFieldHeightAnchor?.isActive = true
        
    
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor =  passwordTextField.heightAnchor.constraint(equalTo:inputContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? (1/2) : (1/3))
        passwordTextFieldHeightAnchor?.isActive = true
        
        
        
    }
    

    
    @objc func handleLoginRegister()
    {
        loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? handleLogin() : handleRegister()
    }
    
    func handleLogin()
    {
        guard let email = emailTextField.text , let password = passwordTextField.text else
        {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user:User?, error) in
            
            if error != nil
            {
                
            }
            self.messagesController?.fetchUserAndSetupNavBarTitle()

            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.rgb(red: 61, green: 91, blue: 151, alpha: 1)
        setupInputContainerView()
        setupLoginRegisterButton()
        setuploginRegisterSegmentedControl()
        setupProfileImageView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupInputContainerView(){
        self.view.addSubview(inputContainerView)
        inputContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor,constant:-24).isActive = true
        inputViewControllerHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputViewControllerHeightAnchor?.isActive = true
        
        // add name input fields
        
        inputContainerView.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor,constant:12).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor,constant:-48).isActive = true
        nameTextFieldHeightAnchor =  nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        
        // add name separator
        inputContainerView.addSubview(nameSeparatorView)
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,constant:2).isActive = true
        nameSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        // add email input fields
        
        inputContainerView.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor,constant:12).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor,constant:-48).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        // add email separator
        inputContainerView.addSubview(emailSeparatorView)
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,constant:2).isActive = true
        emailSeparatorView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // add Password input fields
        
        inputContainerView.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor,constant:12).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor,constant:-48).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    
    }
    func setupLoginRegisterButton(){
        self.view.addSubview(loginRegisterButton)
        loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor,constant:12).isActive = true
        loginRegisterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: self.view.widthAnchor,constant:-24).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupProfileImageView(){
        self.view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor,constant:-12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        

    }
    
    func setuploginRegisterSegmentedControl(){
        self.view.addSubview(loginRegisterSegmentedControl)
        
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor,constant:-12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle{
//        return .lightContent
//    }


}
