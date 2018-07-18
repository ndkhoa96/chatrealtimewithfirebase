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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_menu"), style: .plain, target: self, action: #selector(handleLogout))
        tableView.backgroundColor = Theme.shared.whiteColor
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserIsLogIn()
        setUpMenuView()
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
            }
            
        }, withCancel: nil)
        
    }
    
    @objc func handleMyPage(){
        let persionnalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        //persionnalPageController.user = self.user
        persionnalPageController.hidesBottomBarWhenPushed = true
        persionnalPageController.user = user
        persionnalPageController.btv = self
        navigationController?.pushViewController(persionnalPageController, animated: true)

    }


    var tapGesture : UITapGestureRecognizer?
    
    override func viewDidAppear(_ animated: Bool) {
        if let tap = tapGesture{
            navigationController?.navigationBar.addGestureRecognizer(tap)
        }
    }
    
    func setupNavBarWithUser(user: User){
   
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleView
        navigationController?.navigationBar.isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMyPage))
        navigationController?.navigationBar.addGestureRecognizer(tapGesture!)
        
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
    
    let menuView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    var menuViewWidthAnchor: NSLayoutConstraint?
    
    func setUpMenuView(){
        view.addSubview(menuView)
        
        menuView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        menuViewWidthAnchor = menuView.widthAnchor.constraint(equalToConstant: 0)
        menuViewWidthAnchor?.isActive = true
        
        
    }
    
    @objc func handleLogout(){
        
//        UIView.animate(withDuration: 0.3) {
//            if self.menuView.frame.width == 0 {
//                self.menuViewWidthAnchor?.isActive = false
//                self.menuViewWidthAnchor = self.menuView.widthAnchor.constraint(equalToConstant: self.view.frame.width/2)
//                self.menuViewWidthAnchor?.isActive = true
//            }else{
//                self.menuViewWidthAnchor?.isActive = false
//                self.menuViewWidthAnchor = self.menuView.widthAnchor.constraint(equalToConstant: 0)
//                self.menuViewWidthAnchor?.isActive = true
//
//            }
//            self.view.layoutIfNeeded()
//        }
        
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
    
    
    func showActionSheet(cell: UserCell){
        print(123)
    }
}
