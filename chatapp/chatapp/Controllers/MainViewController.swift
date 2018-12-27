//
//  ViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/29/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var controllers: [UIViewController]?
    
    var collectionView: UICollectionView?
    
    var bottomView: UIView = {
       let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = Theme.shared.lightGrayColor
        return bottomView
    }()
    
    lazy var btnFriends: UIButton = {
       let btnFriends = UIButton()
        btnFriends.setImage(UIImage(named: ASSETS.ICON.CONTACT), for: .normal)
        btnFriends.translatesAutoresizingMaskIntoConstraints = false
        btnFriends.addTarget(self, action: #selector(handleTabFriends), for: .touchUpInside)
        return btnFriends
    }()
    
    lazy var btnUserMessages: UIButton = {
        let btnUserMessages = UIButton()
        btnUserMessages.setImage(UIImage(named: ASSETS.ICON.MESSAGE), for: .normal)
        btnUserMessages.translatesAutoresizingMaskIntoConstraints = false
        btnUserMessages.addTarget(self, action: #selector(handleTabUserMessages), for: .touchUpInside)
        return btnUserMessages
    }()
    
    lazy var btnGroupMessages: UIButton = {
        let btnGroupMessages = UIButton()
        btnGroupMessages.setImage(UIImage(named: ASSETS.ICON.FAMILY), for: .normal)
        btnGroupMessages.translatesAutoresizingMaskIntoConstraints = false
        btnGroupMessages.addTarget(self, action: #selector(handleTabGroupMessages), for: .touchUpInside)
        return btnGroupMessages
    }()
    
    @objc func handleTabFriends() {
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView?.scrollToItemIfAvailable(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func handleTabUserMessages() {
        let indexPath = IndexPath(item: 1, section: 0)
        collectionView?.scrollToItemIfAvailable(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc func handleTabGroupMessages() {
        let indexPath = IndexPath(item: 2, section: 0)
        collectionView?.scrollToItemIfAvailable(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBottomView()
    }
    
    private func setupBottomView() {
        let userMessagesController = UserMessagesController()
        let groupsMessagesController = GroupsMessagesController()
        let friendsController = FriendsViewController()
        
        let userMessagesNavController = UINavigationController(rootViewController: userMessagesController)
        let groupsMessagesNavController = UINavigationController(rootViewController: groupsMessagesController)
        let friendsNavController = UINavigationController(rootViewController: friendsController)
        
        controllers = [friendsNavController, userMessagesNavController, groupsMessagesNavController]
        
        view.addSubview(bottomView)
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        setupBtnTabFriends()
        setupBtnTabUserMessages()
        setupBtnTabGroupMessages()
    }
    
    private func setupBtnTabFriends() {
        bottomView.addSubview(btnFriends)
        btnFriends.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 8).isActive = true
        btnFriends.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        btnFriends.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btnFriends.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupBtnTabUserMessages() {
        bottomView.addSubview(btnUserMessages)
        btnUserMessages.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        btnUserMessages.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        btnUserMessages.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btnUserMessages.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupBtnTabGroupMessages() {
        bottomView.addSubview(btnGroupMessages)
        btnGroupMessages.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -8).isActive = true
        btnGroupMessages.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        btnGroupMessages.widthAnchor.constraint(equalToConstant: 100).isActive = true
        btnGroupMessages.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: "123")
        view.addSubview(collectionView!)
        collectionView?.backgroundColor = .white
        collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView?.isScrollEnabled = false
        
    }

    let colors = [UIColor.red, UIColor.green, UIColor.yellow]
}
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "123", for: indexPath) as! CollectionViewCell
        cell.controller = controllers![indexPath.item]
        //cell.backgroundColor = colors[indexPath.item]
        return cell
        
    }
}
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
