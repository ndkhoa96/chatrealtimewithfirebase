//
//  LoginController.swift
//  AppChat
//
//  Created by Khoa Nguyen on 3/14/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//  Document file CHAT_APPLICATION_TLPT_01_LoginAndRegister

import UIKit

class LoginAndRegisterController: UIViewController {
    
    //MARK: - CONSTANT
    struct Constants {
        static let loginTitle = "Login"
        static let emailTitle = "Email"
        static let passwordTitle = "Password"
        static let registerTitle = "Register"
        static let nameTitle = "Nickname"
        static let maxLenghtInputName = 12
        //height of inputContainerView will change for login or register
        static let height3Part: CGFloat = 150.0
        static let height2Part: CGFloat = 100.0
    }
    
    //MARK: - PROPERTIES
    var messageController: BaseTableViewController?
    
    //height constraint of inputContainerView will change for login or register
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextfieldHeightAnchor: NSLayoutConstraint?
    var emailTextfieldHeightAnchor: NSLayoutConstraint?
    var passwordTextfieldHeightAnchor: NSLayoutConstraint?
    
    //Ratio height of inputContainerView change with SegmentIndex
    var ratioWithLoginRegisterSegmentedControl: CGFloat {
        return self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? RATIO.TWO_PART : RATIO.THREE_PART
    }
    //check input Register is empty
    var isEmptyInputRegister: Bool {
        if (emailTextField.text?.isReallyEmpty)! || (passwordTextField.text?.isReallyEmpty)! || (nameTextField.text?.isReallyEmpty)! {
            return true
        }
        return false
    }
    //check input Login is empty
    var isEmptyInputLogin: Bool {
        if (emailTextField.text?.isReallyEmpty)! || (passwordTextField.text?.isReallyEmpty)! {
            return true
        }
        return false
    }
    
    //MARK: - UI PROPERTIES
    let inputsContainerView: UIView = {
        let inputsContainerView = UIView()
        inputsContainerView.backgroundColor = UIColor.clear
        inputsContainerView.translatesAutoresizingMaskIntoConstraints = false
        return inputsContainerView
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let loginRegisterButton = UIButton(type: UIButton.ButtonType.system)
        loginRegisterButton.setTitle(Constants.loginTitle, for: .normal)
        loginRegisterButton.translatesAutoresizingMaskIntoConstraints = false
        loginRegisterButton.setTitleColor(Theme.shared.whiteColor, for: .normal)
        loginRegisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginRegisterButton.layer.cornerRadius = 8
        loginRegisterButton.layer.masksToBounds = true
        loginRegisterButton.backgroundColor = UIColor.clear
        loginRegisterButton.layer.borderColor = Theme.shared.whiteColor.cgColor
        loginRegisterButton.layer.borderWidth = 1
        loginRegisterButton.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return loginRegisterButton
    }()
  
    let nameTextField: UITextField = {
       let nameTextField = UITextField()
        nameTextField.textColor = Theme.shared.whiteColor
        nameTextField.attributedPlaceholder = NSAttributedString(string: Constants.nameTitle,
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        return nameTextField
    }()
    
    let nameSeparatorView: UIView = {
       let nameSeparatorView = UIView()
        nameSeparatorView.backgroundColor = Theme.shared.lightGrayColor
        nameSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        return nameSeparatorView
    }()
    
    let emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.attributedPlaceholder = NSAttributedString(string: Constants.emailTitle,
                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        emailTextField.textColor = Theme.shared.whiteColor
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.keyboardType = .emailAddress
        return emailTextField
    }()
    
    let emailSeparatorView: UIView = {
        let emailSeparatorView = UIView()
        emailSeparatorView.backgroundColor = Theme.shared.lightGrayColor
        emailSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        return emailSeparatorView
    }()
    
    let passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: Constants.passwordTitle,
                                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        passwordTextField.textColor = Theme.shared.whiteColor
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.isSecureTextEntry = true
        return passwordTextField
    }()
    
    let passwordSeparatorView: UIView = {
        let passwordSeparatorView = UIView()
        passwordSeparatorView.backgroundColor = Theme.shared.lightGrayColor
        passwordSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        return passwordSeparatorView
    }()
    
    lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: ASSETS.IMAGE.LOGO)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                     action: #selector(handleSelectProfileImageView)))
        profileImageView.layer.cornerRadius = 75
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = Theme.shared.whiteColor.cgColor
        return profileImageView
    
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let loginRegisterSegmentedControl = UISegmentedControl(items: [Constants.loginTitle,Constants.registerTitle])
        loginRegisterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        loginRegisterSegmentedControl.tintColor = Theme.shared.whiteColor
        loginRegisterSegmentedControl.selectedSegmentIndex = 0
        loginRegisterSegmentedControl.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return loginRegisterSegmentedControl
    }()
    
    let imageViewBackground: UIImageView = {
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0,
                                              width: Dimension.shared.widthScreen, height: Dimension.shared.heightScreen))
        imageViewBackground.image = UIImage(named: ASSETS.IMAGE.BACKGROUND)
        imageViewBackground.contentMode = .scaleAspectFill
        return imageViewBackground
    }()
    
    private let blurEffectView: UIVisualEffectView = {
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
    private func setDelegate() {
        //emailTextField.delegate = self
        //passwordTextField.delegate = self
        nameTextField.delegate = self
    }
    
    //MARK: - SETUP UI
    private func setupViews() {
        view.backgroundColor = Theme.shared.secondaryColor
        view.addSubview(imageViewBackground)
        view.addSubview(blurEffectView)
     
        setupProfileImageView()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLoginRegisterSegmentedControl()     
    }
    
    private func setupLoginRegisterSegmentedControl() {
        view.addSubview(loginRegisterSegmentedControl)
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    private func setupInputsContainerView() {
        view.addSubview(inputsContainerView)
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 80).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        inputContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
        inputContainerViewHeightAnchor?.isActive = true
        
        setupNameTextfieldConstraint()
        setupEmailTextfieldConstrain()
        setupPasswordTextfieldConstraint()
    }
    
    private func setupNameTextfieldConstraint() {
        inputsContainerView.addSubview(nameTextField)
        //nameTF constrain
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextfieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
        nameTextfieldHeightAnchor?.isActive = true
        nameSeparatorView.isHidden = true
        
        inputsContainerView.addSubview(nameSeparatorView)
        //nameSeparatorView
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func setupEmailTextfieldConstrain() {
        inputsContainerView.addSubview(emailTextField)
        //emailTF constrain
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextfieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: RATIO.TWO_PART)
        emailTextfieldHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(emailSeparatorView)
        //emailSeparatorView
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func setupPasswordTextfieldConstraint() {
        inputsContainerView.addSubview(passwordTextField)
        //passwordTF constrain
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextfieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: RATIO.TWO_PART)
        passwordTextfieldHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(passwordSeparatorView)
        //passwordSeparatorView
        passwordSeparatorView.bottomAnchor.constraint(equalTo: inputsContainerView.bottomAnchor).isActive = true
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func setupLoginRegisterButton() {
        view.addSubview(loginRegisterButton)
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 24).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: RATIO.TWO_PART).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupProfileImageView() {
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
}
//MARK: TEXTFIELD DELEGATE
extension LoginAndRegisterController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        return newLength <= Constants.maxLenghtInputName
    }
    
    //hide keyboard when touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
}
