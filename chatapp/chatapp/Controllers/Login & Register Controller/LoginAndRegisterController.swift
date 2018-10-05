//
//  LoginController.swift
//  AppChat
//
//  Created by Khoa Nguyen on 3/14/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class LoginAndRegisterController: UIViewController {
    
    //MARK: - CONSTANT
    struct Constants {
        static let actionOk = "Ok"
        static let actionFileTypeDescription = "Choose a filetype to add..."
        
        static let alertSignUpErrorTitle = "Sign Up Fail"
        static let loginTitle = "Login"
        static let emailTitle = "Email"
        static let passwordTitle = "Password"
        static let registerTitle = "Register"
        static let nameTitle = "Nickname"
        

        static let height3Part: CGFloat = 150.0
        static let height2Part: CGFloat = 100.0
        static let typeImage = ".jpg"
        
        static let connectionErrorMessage = "Please check your connection!"
        static let invalidEmailMessage = "Invalid email address!"
        static let existEmailMessage = "Email is already have registered!"
        static let invalidPasswordMessage = "Password should be at least 6 characters!"
    }
    
    //MARK: - PROPERTIES
    var messageController: BaseTableViewController?
    
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextfieldHeightAnchor: NSLayoutConstraint?
    var emailTextfieldHeightAnchor: NSLayoutConstraint?
    var passwordTextfieldHeightAnchor: NSLayoutConstraint?
    
    //MARK: - UI
    lazy var alert : UIAlertController = {
        let actionOk = UIAlertAction(title: Constants.actionOk, style: .default, handler: nil)
        let alert = UIAlertController(title: Constants.alertSignUpErrorTitle, message: nil, preferredStyle: .alert)
        
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
        let button = UIButton(type: UIButton.ButtonType.system)
 
        button.setTitle(Constants.loginTitle, for: .normal)
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
  
    let nameTextField: UITextField = {
       let tf = UITextField()
        tf.textColor = Theme.shared.whiteColor
        tf.attributedPlaceholder = NSAttributedString(string: Constants.nameTitle, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
       let view = UIView()
        view.backgroundColor = Theme.shared.lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: Constants.emailTitle, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        tf.textColor = Theme.shared.whiteColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .emailAddress

        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.shared.lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: Constants.passwordTitle, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        tf.textColor = Theme.shared.whiteColor
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.shared.lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ASSETS.IMAGE.LOGO)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = Theme.shared.whiteColor.cgColor
        return imageView
    
    }()
 
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [Constants.loginTitle,Constants.registerTitle])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = Theme.shared.whiteColor
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        
        return segmentedControl
    }()
    
    let imageViewBackground: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: Dimension.shared.widthScreen, height: Dimension.shared.heightScreen))
        image.image = UIImage(named: ASSETS.IMAGE.BACKGROUND)
        image.contentMode = .scaleAspectFill
        
        return image
    }()
    
    let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = Dimension.shared.screenBounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurEffectView
    }()


    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupViews()
        setDelegate()
        
    }
    
    //MARK: - SET DELEGATE
    private func setDelegate(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
    }
    
    //MARK: - SETUP UI
    private func setupViews(){
        view.backgroundColor = Theme.shared.secondaryColor
        view.addSubview(imageViewBackground)
        view.addSubview(blurEffectView)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        //setupBackground()
        setupProfileImageView()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLoginRegisterSegmentedControl()
    }
    
    private func setupLoginRegisterSegmentedControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    private func setupInputsContainerView(){
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
        emailTextfieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: RATIO.TWO_PART)
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
    
    private func setupLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 24).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1/2).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }
    
    private func setupProfileImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
}

extension LoginAndRegisterController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
    }
}
