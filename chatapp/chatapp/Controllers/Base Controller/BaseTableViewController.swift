//
//  BaseTableViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//  Document file CHAT_APPLICATION_TLPT_01_FriendList.xlsx

import UIKit

class BaseTableViewController: UITableViewController {
    
    //MARK: - CONSTANT
    struct Constant {
        static let menuProfileBtnTitle = "Information"
        static let menuNotificationBtnTitle = "Notification"
        static let menuSettingBtnTitle = "Setting"
        static let menuSignoutBtnTitle = "Sign Out"
    }

    //MARK: - PROPERTIES
    var user : User? {
        didSet{
            setupNavBarWithUser()
            setupMenuView()
        }
    }
    
    //MARK: - UI
    let window = UIApplication.shared.keyWindow
    
    lazy var grayView : UIView = {
        let blackView  = UIView()
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
        
        return blackView
    }()
    
    var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    var navProfileImageView: UIImageView = {
        let navProfileImageView = UIImageView()
        navProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        navProfileImageView.layer.cornerRadius = 20
        navProfileImageView.clipsToBounds = true
        navProfileImageView.contentMode = .scaleAspectFill
        
        return navProfileImageView
    }()
    
    var navNameLabel: UILabel = {
        let navNameLabel = UILabel()
        navNameLabel.textColor = Theme.shared.whiteColor
        navNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        navNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return navNameLabel
    }()
   
    
    var menuView : UIView = {
        let menuView = UIView()
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.backgroundColor = UIColor.clear
        menuView.layer.cornerRadius = 8
        menuView.layer.masksToBounds = true
        menuView.alpha = 0
        
        return menuView
    }()
    
    var menuProfileImageView: UIImageView = {
        let menuProfileImageView = UIImageView()
        menuProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        menuProfileImageView.contentMode = .scaleAspectFill
        menuProfileImageView.layer.cornerRadius = 75
        menuProfileImageView.layer.masksToBounds = true
        menuProfileImageView.layer.borderWidth = 1
        menuProfileImageView.layer.borderColor = Theme.shared.whiteColor.cgColor
        return menuProfileImageView
    }()
    
    var menuNameBtn: UIButton = {
        let menuNameBtn = UIButton()
        menuNameBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        menuNameBtn.translatesAutoresizingMaskIntoConstraints = false
        menuNameBtn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        
        return menuNameBtn
    }()
    
    var menuProfileBtn: UIButton = {
        let menuProfileBtn = UIButton()
        menuProfileBtn.setImage(UIImage(named: ASSETS.ICON.BOY), for: .normal)
        menuProfileBtn.setTitle(Constant.menuProfileBtnTitle, for: .normal)
        menuProfileBtn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        menuProfileBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        menuProfileBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        menuProfileBtn.layer.cornerRadius = 10
        menuProfileBtn.layer.masksToBounds = true
        menuProfileBtn.contentHorizontalAlignment = .center
        menuProfileBtn.translatesAutoresizingMaskIntoConstraints = false
        
        return menuProfileBtn
    }()
    
    var menuNotificationBtn: UIButton = {
        let menuNotificationBtn = UIButton()
        menuNotificationBtn.setImage(UIImage(named: ASSETS.ICON.BELL), for: .normal)
        menuNotificationBtn.setTitle(Constant.menuNotificationBtnTitle, for: .normal)
        menuNotificationBtn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        menuNotificationBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        menuNotificationBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        menuNotificationBtn.layer.cornerRadius = 10
        menuNotificationBtn.layer.masksToBounds = true
        menuNotificationBtn.contentHorizontalAlignment = .center
        menuNotificationBtn.translatesAutoresizingMaskIntoConstraints = false
        return menuNotificationBtn
    }()
    
    var menuSettingBtn: UIButton = {
        let menuSettingBtn = UIButton()
        menuSettingBtn.setImage(UIImage(named: ASSETS.ICON.ADJUST), for: .normal)
        menuSettingBtn.setTitle(Constant.menuSettingBtnTitle, for: .normal)
        menuSettingBtn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        menuSettingBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 25)
        menuSettingBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 45)
        menuSettingBtn.layer.cornerRadius = 10
        menuSettingBtn.layer.masksToBounds = true
        menuSettingBtn.contentHorizontalAlignment = .center
        menuSettingBtn.translatesAutoresizingMaskIntoConstraints = false
        
        return menuSettingBtn
    }()
    
    var menuLogoutBtn: UIButton = {
        let menuLogoutBtn = UIButton()
        menuLogoutBtn.setImage(UIImage(named: ASSETS.ICON.LOGOUT), for: .normal)
        menuLogoutBtn.setTitle(Constant.menuSignoutBtnTitle, for: .normal)
        menuLogoutBtn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        menuLogoutBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        menuLogoutBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        menuLogoutBtn.contentHorizontalAlignment = .center
        menuLogoutBtn.translatesAutoresizingMaskIntoConstraints = false
        menuLogoutBtn.layer.cornerRadius = 10
        menuLogoutBtn.layer.masksToBounds = true
        
        return menuLogoutBtn
    }()
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLogIn()
        setupTableView()
        setupBarButtonItem()
    }
    
    //MARK: - SETUP TABLEVIEW
    private func setupTableView() {
        tableView.backgroundColor = Theme.shared.whiteColor
        tableView.separatorStyle = .none
    }
    
    //MARK: - SETUP NAVIGATION BAR
    func setupBarButtonItem() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: ASSETS.ICON.MENU), style: .plain, target: self, action: #selector(handleShowMenu))
    }
    
    private func setupNavProfileImageView() {

        if let imageUrl = self.user?.profileImageUrl{
            navProfileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
        containerView.addSubview(navProfileImageView)
        
        //profileImageView constrains
        navProfileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        navProfileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        navProfileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        navProfileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupNavNameLabel() {
        if let name = self.user?.name{
            navNameLabel.text = name
        }
        containerView.addSubview(navNameLabel)
        
        //Name Label constrains
        navNameLabel.leftAnchor.constraint(equalTo: navProfileImageView.rightAnchor, constant: 8).isActive = true
        navNameLabel.centerYAnchor.constraint(equalTo: navProfileImageView.centerYAnchor).isActive = true
        navNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        navNameLabel.heightAnchor.constraint(equalTo: navProfileImageView.heightAnchor).isActive = true
    }
    
    func setupNavBarWithUser() {
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleView
        
        //titleView constrains
        titleView.centerYAnchor.constraint(equalTo: (navigationItem.titleView?.centerYAnchor)!).isActive = true
        titleView.centerXAnchor.constraint(equalTo: (navigationItem.titleView?.centerXAnchor)!).isActive = true
        titleView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        titleView.heightAnchor.constraint(equalTo: (navigationItem.titleView?.heightAnchor)!).isActive = true
        
        titleView.addSubview(containerView)
        
        //containerView constrains
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        setupNavProfileImageView()
        setupNavNameLabel()
    }
 
    
    //MARK: - SETUP MENU
    private func setupMenuProfileImageView() {
        if let imageUrl = self.user?.profileImageUrl {
            menuProfileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
        }
       
        menuView.addSubview(menuProfileImageView)
        menuProfileImageView.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 32).isActive = true
        menuProfileImageView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        menuProfileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        menuProfileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    private func setupMenuNameBtn() {
        if let gender = self.user?.gender {
            if gender == "Female" {
                menuNameBtn.setImage(UIImage(named: ASSETS.ICON.FEMALE), for: .normal)
            }else{
                menuNameBtn.setImage(UIImage(named: ASSETS.ICON.MALE), for: .normal)
            }
            menuNameBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            menuNameBtn.contentHorizontalAlignment = .center
        }
        
        if let name = self.user?.name {
            menuNameBtn.setTitle(name, for: .normal)
        }
        
        menuView.addSubview(menuNameBtn)
        menuNameBtn.topAnchor.constraint(equalTo: menuProfileImageView.bottomAnchor, constant: 8).isActive = true
        menuNameBtn.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        menuNameBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        menuNameBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupMenuProfileBtn(){
        // separateView
        let separateView = UIView()
        separateView.backgroundColor = UIColor.lightGray
        separateView.translatesAutoresizingMaskIntoConstraints = false
        
        menuView.addSubview(separateView)
        separateView.topAnchor.constraint(equalTo: menuNameBtn.bottomAnchor, constant: 8).isActive = true
        separateView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        separateView.widthAnchor.constraint(equalTo: menuView.widthAnchor, multiplier: 0.8).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //btn Profile
        menuProfileBtn.addTarget(self, action: #selector(handleSwitchToPersionalController), for: .touchUpInside)
        menuView.addSubview(menuProfileBtn)
        menuProfileBtn.topAnchor.constraint(equalTo: separateView.bottomAnchor, constant: 8).isActive = true
        menuProfileBtn.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        menuProfileBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        menuProfileBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupMenuNotificationBtn() {
        //separate view
        let separateView = UIView()
        separateView.backgroundColor = UIColor.lightGray
        separateView.translatesAutoresizingMaskIntoConstraints = false
        
        menuView.addSubview(separateView)
        separateView.topAnchor.constraint(equalTo: menuProfileBtn.bottomAnchor, constant: 8).isActive = true
        separateView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        separateView.widthAnchor.constraint(equalTo: menuView.widthAnchor, multiplier: 4/5).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //btn notification
        menuView.addSubview(menuNotificationBtn)
        menuNotificationBtn.topAnchor.constraint(equalTo: separateView.bottomAnchor, constant: 8).isActive = true
        menuNotificationBtn.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        menuNotificationBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        menuNotificationBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupMenuSettingBtn() {
        //separate view
        let separateView = UIView()
        separateView.backgroundColor = UIColor.lightGray
        separateView.translatesAutoresizingMaskIntoConstraints = false
        
        menuView.addSubview(separateView)
        separateView.topAnchor.constraint(equalTo: menuNotificationBtn.bottomAnchor, constant: 8).isActive = true
        separateView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        separateView.widthAnchor.constraint(equalTo: menuView.widthAnchor, multiplier: 4/5).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //btn setting
        menuView.addSubview(menuSettingBtn)
        menuSettingBtn.topAnchor.constraint(equalTo: separateView.bottomAnchor, constant: 8).isActive = true
        menuSettingBtn.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        menuSettingBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        menuSettingBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupMenuLogoutBtn() {
        //btnLogout
        menuLogoutBtn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        menuView.addSubview(menuLogoutBtn)
        menuLogoutBtn.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -16).isActive = true
        menuLogoutBtn.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        menuLogoutBtn.widthAnchor.constraint(equalToConstant: 180).isActive = true
        menuLogoutBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //separate view
        let separateView = UIView()
        separateView.backgroundColor = UIColor.lightGray
        separateView.translatesAutoresizingMaskIntoConstraints = false
        
        menuView.addSubview(separateView)
        separateView.bottomAnchor.constraint(equalTo: menuLogoutBtn.topAnchor, constant: -8).isActive = true
        separateView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        separateView.widthAnchor.constraint(equalTo: menuView.widthAnchor, multiplier: 4/5).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func setupMenuView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuView.addSubview(blurEffectView)
        
        setupMenuProfileImageView()
        setupMenuNameBtn()
        setupMenuProfileBtn()
        setupMenuNotificationBtn()
        setupMenuSettingBtn()
        setupMenuLogoutBtn()
    }
    
    //MARK: - TABLEVIEW DELEGATE AND DATASOURCE
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    //MARK: - HANDLE FUNCTION

    func checkIfUserIsLogIn() {
        if AuthProvider.shared.isLoggedIn {
            guard let myId = AuthProvider.shared.currentUserID else { return }
            DBProvider.shared.getUserWith(id: myId) { (user) in
                if let currentUser = user {
                    self.user = currentUser
                }
            }
        } else {
            switchToLoginController()
        }
    }
    
    @objc func handleSwitchToPersionalController() {
        dismissMenu()
        let persionnalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())

        persionnalPageController.hidesBottomBarWhenPushed = true
        persionnalPageController.user = user

        navigationController?.pushViewController(persionnalPageController, animated: true)
    }
    
    
    @objc func handleLogout() {
        dismissMenu()
        if AuthProvider.shared.logOut() {
            switchToLoginController()
        } else {
            return
        }
    }
    
    private func switchToLoginController() {
        let loginController = LoginAndRegisterController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }

    @objc func dismissMenu() {
        self.menuView.slideIOutFromRight(duration: ANIMATION.FAST)
        UIView.transition(with: grayView, duration: ANIMATION.FAST, options: .curveEaseOut, animations: {
            self.grayView.alpha = 0
        }) { (finish) in
            self.grayView.removeFromSuperview()
            self.menuView.alpha = 0
        }
    }
    
    @objc func handleShowMenu() {
        grayView.frame = (window?.frame)!
        grayView.addSubview(menuView)
        menuView.topAnchor.constraint(equalTo: grayView.topAnchor).isActive = true
        menuView.leftAnchor.constraint(equalTo: grayView.leftAnchor).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: grayView.frame.height).isActive = true
        menuView.widthAnchor.constraint(equalTo: grayView.widthAnchor, multiplier: 2/3).isActive = true
        self.window?.addSubview(self.grayView)
        
        menuView.slideInFromLeft(duration: ANIMATION.FAST)

        UIView.transition(with: grayView, duration: ANIMATION.FAST, options: .curveEaseIn, animations: {
            self.grayView.alpha = 1
            self.menuView.alpha = 1
        }, completion: nil)
    }
    
    func showMessageAction(cell: UserCell) {
        
    }
}


