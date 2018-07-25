//
//  BaseTableViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class BaseTableViewController: UITableViewController {
   
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_menu"), style: .plain, target: self, action: #selector(handleShowMenu))
        tableView.backgroundColor = Theme.shared.whiteColor
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        checkIfUserIsLogIn()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func checkIfUserIsLogIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            fetchUserAndSetupNavBarTitle()
        }
    }
    var user : User?

    func fetchUserAndSetupNavBarTitle(){

        guard let uid = Auth.auth().currentUser?.uid
            else{
                return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{

                let user = User(values: dictionary)
                user.id = snapshot.key
                self.user = user
                ///user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
                self.setupMenuView(user: user)
            }
            
        }, withCancel: nil)
        
    }
    
    @objc func handleMyPage(){
        dismissMenu()
        let persionnalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())

        persionnalPageController.hidesBottomBarWhenPushed = true
        persionnalPageController.user = user

        navigationController?.pushViewController(persionnalPageController, animated: true)

    }

    
    override func viewDidAppear(_ animated: Bool) {
        fetchUserAndSetupNavBarTitle()
 
    }
    
    func setupNavBarWithUser(user: User){
   
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleView
        
        //titleView constrains
        titleView.centerYAnchor.constraint(equalTo: (navigationItem.titleView?.centerYAnchor)!).isActive = true
        titleView.centerXAnchor.constraint(equalTo: (navigationItem.titleView?.centerXAnchor)!).isActive = true
        titleView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        titleView.heightAnchor.constraint(equalTo: (navigationItem.titleView?.heightAnchor)!).isActive = true
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        //profileImageView constrains
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.textColor = Theme.shared.whiteColor
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        //Name Label constrains
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        //containerView constrains
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        
    }
    
    func setupMenuView(user: User){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuView.addSubview(blurEffectView)
        
        let profileImageView = UIImageView()
        profileImageView.loadImageUsingCacheWithUrlString(urlString: (user.profileImageUrl)!)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 75
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = Theme.shared.whiteColor.cgColor
        
        menuView.addSubview(profileImageView)
        profileImageView.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 32).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        let nameLabel = UIButton()
        if let gender = user.gender{
            if gender == "Female" {
                nameLabel.setImage(UIImage(named: "ic_female"), for: .normal)
            }else{
                nameLabel.setImage(UIImage(named: "ic_male"), for: .normal)
            }
            nameLabel.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
            nameLabel.contentHorizontalAlignment = .center
        }
        nameLabel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setTitle(user.name, for: .normal)
        nameLabel.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        
        menuView.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 180).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let btnProfile = UIButton()
        btnProfile.setImage(UIImage(named: "ic_profile"), for: .normal)
        btnProfile.setTitle("Profile", for: .normal)
        btnProfile.setTitleColor(Theme.shared.blackColor, for: .normal)
        btnProfile.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btnProfile.contentHorizontalAlignment = .left
        btnProfile.translatesAutoresizingMaskIntoConstraints = false
        btnProfile.addTarget(self, action: #selector(handleMyPage), for: .touchUpInside)
        
        menuView.addSubview(btnProfile)
        btnProfile.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        btnProfile.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        btnProfile.widthAnchor.constraint(equalToConstant: 150).isActive = true
        btnProfile.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let btnLogout = UIButton()
        btnLogout.setImage(UIImage(named: "ic_logout"), for: .normal)
        btnLogout.setTitle("Sign Out", for: .normal)
        btnLogout.setTitleColor(Theme.shared.blackColor, for: .normal)
        btnLogout.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btnLogout.contentHorizontalAlignment = .left
        btnLogout.translatesAutoresizingMaskIntoConstraints = false
        btnLogout.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        menuView.addSubview(btnLogout)
        btnLogout.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -8).isActive = true
        btnLogout.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        btnLogout.widthAnchor.constraint(equalToConstant: 150).isActive = true
        btnLogout.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    var menuView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        

        
        return view
    }()
    
    @objc func handleLogout(){
        dismissMenu()
        let sv = UIViewController.displaySpinner(onView: view)
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        UIViewController.removeSpinner(spinner: sv)
        present(loginController, animated: true, completion: nil)
    }

    
    let windowz = UIApplication.shared.keyWindow
    
    lazy var blView : UIView = {
        let blView  = UIView()
        blView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blView.alpha = 0
        blView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))

 
        
        
        return blView
    }()
    
    @objc func dismissMenu(){

        UIView.transition(with: blView, duration: 0.3, options: .curveEaseOut, animations: {
            self.blView.alpha = 0
        }) { (finish) in
            self.blView.removeFromSuperview()
        }

    }
    
    @objc func handleShowMenu(){
        blView.frame = (windowz?.frame)!
        blView.addSubview(menuView)
        menuView.topAnchor.constraint(equalTo: blView.topAnchor).isActive = true
        menuView.leftAnchor.constraint(equalTo: blView.leftAnchor).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: blView.frame.height).isActive = true
        menuView.widthAnchor.constraint(equalToConstant: self.view.frame.width/2).isActive = true
        self.windowz?.addSubview(self.blView)

        UIView.transition(with: blView, duration: 0.3, options: .curveEaseIn, animations: {
            
            self.blView.alpha = 1
        }, completion: nil)
        
            
    
        
        
    }
    
    
    func showActionSheet(cell: UserCell){
        print(123)
    }
}
