//
//  LoginController.swift
//  AppChat
//
//  Created by Khoa Nguyen on 3/14/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UITextFieldDelegate {
    
    var messageController: BaseTableViewController?
    let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
    let timeShakeAnim = 0.2
    
    lazy var alert : UIAlertController = {
        let alert = UIAlertController(title: "Sign Up Fail", message: nil, preferredStyle: .alert)
        
        alert.addAction(actionOk)
        
        return alert
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
 
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(Theme.shared.whiteColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = Theme.shared.whiteColor.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
    }

    let nameTextField: UITextField = {
       let tf = UITextField()
        tf.textColor = Theme.shared.whiteColor
        tf.attributedPlaceholder = NSAttributedString(string: "Name",attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email",attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        tf.textColor = Theme.shared.whiteColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .emailAddress

        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password",attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        tf.textColor = Theme.shared.whiteColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Theme.shared.whiteColor.cgColor
        return imageView
    
    }()
    
   
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Login","Register"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = Theme.shared.whiteColor
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        
        return segmentedControl
    }()
    
    @objc func handleLoginRegisterChange(){
        
        var anim: UIViewAnimationOptions
        let timeAnim = 0.3
        var image: UIImage!
        
        if self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            anim = UIViewAnimationOptions.transitionFlipFromRight
            image = UIImage(named: "logo")
            profileImageView.isUserInteractionEnabled = false
            nameSeparatorView.isHidden = true
        }else{
            anim = UIViewAnimationOptions.transitionFlipFromLeft
            profileImageView.isUserInteractionEnabled = true
            image = UIImage(named: "user")
            nameSeparatorView.isHidden = false
        }
        
        UIView.transition(with: profileImageView, duration: timeAnim, options: anim, animations: {
            self.profileImageView.image = image
        }, completion: nil)
        
        UIView.transition(with: self.loginRegisterButton, duration: timeAnim, options: anim, animations: {
            let title = self.loginRegisterSegmentedControl.titleForSegment(at: self.loginRegisterSegmentedControl.selectedSegmentIndex)
            self.loginRegisterButton.setTitle(title, for: .normal)
        }, completion: nil)
        
        UIView.transition(with: inputsContainerView, duration: timeAnim, options: anim, animations: {
            
            self.inputContainerViewHeightAnchor?.constant = self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
            
            //change name textfield height
            self.nameTextfieldHeightAnchor?.isActive = false
            self.nameTextfieldHeightAnchor = self.nameTextField.heightAnchor.constraint(equalTo: self.inputsContainerView.heightAnchor, multiplier: self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
            self.nameTextfieldHeightAnchor?.isActive = true
            
            //change email textfield height
            self.emailTextfieldHeightAnchor?.isActive = false
            self.emailTextfieldHeightAnchor = self.emailTextField.heightAnchor.constraint(equalTo: self.inputsContainerView.heightAnchor, multiplier: self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
            self.emailTextfieldHeightAnchor?.isActive = true
            
            //change password textfield height
            self.passwordTextfieldHeightAnchor?.isActive = false
            self.passwordTextfieldHeightAnchor = self.passwordTextField.heightAnchor.constraint(equalTo: self.inputsContainerView.heightAnchor, multiplier: self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
            self.passwordTextfieldHeightAnchor?.isActive = true
            
            
        }, completion: nil)


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        image.image = UIImage(named: "bg2")
        image.contentMode = .scaleAspectFill
        view.backgroundColor = Theme.shared.secondaryColor
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(image)
        view.addSubview(blurEffectView)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupProfileImageView()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLoginRegisterSegmentedControl()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
    }
    
    func setupLoginRegisterSegmentedControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextfieldHeightAnchor: NSLayoutConstraint?
    var emailTextfieldHeightAnchor: NSLayoutConstraint?
    var passwordTextfieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView(){
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 80).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        inputContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
        inputContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordSeparatorView)
        
        //nameTF constrain
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextfieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
        nameTextfieldHeightAnchor?.isActive = true
        nameSeparatorView.isHidden = true
        
        //nameSeparatorView
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //emailTF constrain
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextfieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        emailTextfieldHeightAnchor?.isActive = true
        
        //emailSeparatorView
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        							                    
        //passwordTF constrain
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextfieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
        passwordTextfieldHeightAnchor?.isActive = true
        
        //passwordSeparatorView
        passwordSeparatorView.bottomAnchor.constraint(equalTo: inputsContainerView.bottomAnchor).isActive = true
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
    }
    
    func setupLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 24).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1/2).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        

    }
    
    func setupProfileImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
}

