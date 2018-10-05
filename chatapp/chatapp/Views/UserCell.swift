//
//  UserCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/23/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class UserCell:UITableViewCell{
    
    var message: Message? {
        didSet{
            setupNameAndProfileImage()
            
            if let seconds = message?.timeStamp?.doubleValue{
                let timeStampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "dd/MM/yyyy"
                let timeFormat = DateFormatter()
                timeFormat.dateFormat = "HH:mm"
                
                let curTimeStamp: NSNumber? = NSDate().timeIntervalSince1970 as NSNumber
                let curTimeStampDate = NSDate(timeIntervalSince1970: (curTimeStamp?.doubleValue)!)
                
                if dateFormat.string(from: timeStampDate as Date) == dateFormat.string(from: curTimeStampDate as Date){
                    dateLabel.text = "Today"
                }else{
                     dateLabel.text = dateFormat.string(from: timeStampDate as Date)
                }
                
                timeLabel.text = timeFormat.string(from: timeStampDate as Date)
            }
            
        }
    }
    
    func setupNameAndProfileImage(){
             
        if let id = message?.chatPartnerId() {
            let ref = DBProvider.shared.users.child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    self.textLabel?.text = dictionary[KEY_DATA.USER.NAME] as? String
                    if let profileImageUrl = dictionary[KEY_DATA.USER.PROFILE_IMAGE_URL] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            })
        }
        
        if let messText = message?.text{
            if message?.fromID == AuthProvider.shared.userID {
                self.detailTextLabel?.text = "You: \(messText)"
            }else{
                self.detailTextLabel?.text = messText
            }
        }else{
            if message?.fromID  == AuthProvider.shared.userID {
                self.detailTextLabel?.text = "You: [MEDIA]]"
            }else{
                self.detailTextLabel?.text =  "[MEDIA]"
            }
        }
        
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        self.detailTextLabel?.textColor = UIColor.darkGray

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (self.frame.width)-150, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let dateLabel :UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.darkGray
        
        return dateLabel
    }()
    
    let timeLabel :UILabel = {
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.darkGray
        
        return timeLabel
    }()
    
    var baseTableController: BaseTableViewController?
    
    @objc func handle(){
        baseTableController?.showActionSheet(cell: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(handle))
        lpg.minimumPressDuration = 1
        self.addGestureRecognizer(lpg)
        
        addSubview(profileImageView)
        addSubview(dateLabel)
        addSubview(timeLabel)
        
        // add constrains x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //dateLabel constrains
        dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        //dateLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
        //timeLabel constrains
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant : -8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        //timeLabel.heightAnchor.constraint(equalTo: (self.textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("inint has not been implemented")
    }
}
