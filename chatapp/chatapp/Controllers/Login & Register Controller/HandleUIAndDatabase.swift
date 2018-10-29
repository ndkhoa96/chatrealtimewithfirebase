//
//  HandleUIAndDatabase.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/17/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//  Document file CHAT_APPLICATION_TLPT_01_LoginAndRegister

import UIKit
import FirebaseAuth

extension LoginAndRegisterController {
    //MARK: - HANDLE UI
    //Change the login and register handlers
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleSelectProfileImageView() {
        GallaryPicker.shared.showActionPhotoCamera(from: self, withCancel: nil)
    }
    
    private func changeHeightInputView() {
        //change name textfield height
        nameTextfieldHeightAnchor?.isActive = false
        nameTextfieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : RATIO.THREE_PART)
        nameTextfieldHeightAnchor?.isActive = true
        
        //change email textfield height
        emailTextfieldHeightAnchor?.isActive = false
        emailTextfieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: ratioWithLoginRegisterSegmentedControl)
        emailTextfieldHeightAnchor?.isActive = true
        
        //change password textfield height
        passwordTextfieldHeightAnchor?.isActive = false
        passwordTextfieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: ratioWithLoginRegisterSegmentedControl)
        passwordTextfieldHeightAnchor?.isActive = true
    }
    
    //Animation when transition tab Login to Register and inverse
    @objc func handleLoginRegisterChange() {
        var anim: UIView.AnimationOptions!
        var image: UIImage!
        
        if self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            anim = UIView.AnimationOptions.transitionFlipFromRight
            image = UIImage(named: ASSETS.IMAGE.LOGO)
            self.profileImageView.isUserInteractionEnabled = false
            self.nameSeparatorView.isHidden = true
        } else {
            anim = UIView.AnimationOptions.transitionFlipFromLeft
            image = UIImage(named: ASSETS.ICON.USER)
            profileImageView.isUserInteractionEnabled = true
            nameSeparatorView.isHidden = false
        }
        //animation flip
        animateProfileImageView(with: anim, image: image)
        animateLoginRegisterBtn(with: anim)
        animateInputContainerView(with: anim)
    }
    
    //profileImageView animation flip
    private func animateProfileImageView(with anim: UIView.AnimationOptions, image: UIImage){
        UIView.transition(with: self.profileImageView, duration: ANIMATION.FLIP_SHAKE, options: anim, animations: { [unowned self] in
            self.profileImageView.image = image
        }, completion: nil)
    }
    //inputContainerView animation flip
    private func animateInputContainerView(with anim: UIView.AnimationOptions){
        UIView.transition(with: self.inputsContainerView, duration: ANIMATION.FLIP_SHAKE, options: anim, animations: { [unowned self] in
            self.inputContainerViewHeightAnchor?.constant = self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? Constants.height2Part : Constants.height3Part
            self.changeHeightInputView()
        }, completion: nil)
    }
    
    //loginRegisterBtn animation flip
    private func animateLoginRegisterBtn(with anim: UIView.AnimationOptions){
        UIView.transition(with: self.loginRegisterButton, duration: ANIMATION.FLIP_SHAKE, options: anim, animations: { [unowned self] in
            let title = self.loginRegisterSegmentedControl.titleForSegment(at: self.loginRegisterSegmentedControl.selectedSegmentIndex)
            self.loginRegisterButton.setTitle(title, for: .normal)
        }, completion: nil)
    }
    
    //switch to Main Screen
    private func switchToMainController() {
        let customTabBarController = CustomTabBarController()
        self.present(customTabBarController, animated: true, completion: nil)
    }
    
//    MARK: - HANDLE ON DATABASE

    private func showMessageError(error: Error) {
        //1 LOGIN_REGISTER_E001
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .networkError:
                AlertMessage.shared.show(tilte: ERROR.CONNECTION.E001.TITLE,
                                         message: ERROR.CONNECTION.E001.MESSAGE, from: self)
            case .invalidEmail:
                AlertMessage.shared.show(tilte: ERROR.LOGIN_REGISTER.E002.TITLE,
                                         message: ERROR.LOGIN_REGISTER.E002.MESSAGE, from: self)
            case .weakPassword:
                AlertMessage.shared.show(tilte: ERROR.LOGIN_REGISTER.E005.TITLE,
                                         message: ERROR.LOGIN_REGISTER.E005.MESSAGE, from: self)
            case .emailAlreadyInUse:
                AlertMessage.shared.show(tilte: ERROR.LOGIN_REGISTER.E006.TITLE,
                                         message: ERROR.LOGIN_REGISTER.E006.MESSAGE, from: self)
            case .wrongPassword:
                AlertMessage.shared.show(tilte: ERROR.LOGIN_REGISTER.E003.TITLE,
                                         message: ERROR.LOGIN_REGISTER.E003.MESSAGE, from: self)
            case .userNotFound:
                AlertMessage.shared.show(tilte: ERROR.LOGIN_REGISTER.E004.TITLE,
                                         message: ERROR.LOGIN_REGISTER.E004.MESSAGE, from: self)
            default:
                AlertMessage.shared.show(tilte: nil, message: error.localizedDescription, from: self)
            }
        }
    }
    
    private func handleLogin() {
        view.endEditing(true)
        let sv = UIViewController.displaySpinner(onView: view)
        guard !isEmptyInputLogin
            else {
                UIViewController.removeSpinner(spinner: sv)
                inputsContainerView.shake(count: ANIMATION.SHAKE_COUNT, for: ANIMATION.SHAKE_TIME, withTranslation: ANIMATION.SHAKE_TRANSLATION)
                return
        }
        guard let email = emailTextField.text, let password = passwordTextField.text
            else { return }
        
        AuthProvider.shared.loginWith(email: email, password: password) { (error) in
            if error != nil {
                print(error!)
                UIViewController.removeSpinner(spinner: sv)
                self.showMessageError(error: error!)
                return
            }
            
            self.switchToMainController()
        }
    }
    
    private func handleRegister() {
        view.endEditing(true)
        let sv = UIViewController.displaySpinner(onView: view)
        guard !isEmptyInputRegister
            else {
                UIViewController.removeSpinner(spinner: sv)
                inputsContainerView.shake(count: ANIMATION.SHAKE_COUNT, for: ANIMATION.SHAKE_TIME, withTranslation: ANIMATION.SHAKE_TRANSLATION)
                return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else { return }
        
        AuthProvider.shared.createUserWith(email: email, password: password, name: name, profileImage: profileImageView.image!, backgroundImage: UIImage(named: ASSETS.ICON.SCENERY)!) { (error) in
            if error != nil{
                print(error!.localizedDescription)
                UIViewController.removeSpinner(spinner: sv)
                self.showMessageError(error: error!)
                return
            }
            
            self.switchToMainController()
        }
    }
    
}
//MARK: - IMAGEPICKER CONTROLLER DELEGATE
extension LoginAndRegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage       
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
