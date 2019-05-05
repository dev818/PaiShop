//
//  MyRecmMemberDetailVC.swift
//  paishop
//
//  Created by Admin on 8/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyRecmMemberDetailVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var myNameLabel: UILabel!
    @IBOutlet weak var myLevelImage: UIImageView!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!   
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var dicUser = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        self.initMainView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "会员详情"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }

    func initMainView() {
        var strName = String()
        var strPhoto = String()
        var strAddresss = String()
        var strCreatedAt = String()
        var strPhone = String()
        var intLevelId = NSInteger()
        
        if dicUser["pai_name"] is NSNull || dicUser["pai_name"] == nil {
            strName = ""
        } else {
            strName = dicUser["pai_name"] as! String
        }
        
        if dicUser["image"] is NSNull || dicUser["image"] == nil {
            strPhoto = ""
        } else {
            strPhoto = dicUser["image"] as! String
        }
        
        if dicUser["created_at"] is NSNull || dicUser["created_at"] == nil {
            strCreatedAt = ""
        } else {
            strCreatedAt = dicUser["created_at"] as! String
        }
        
        if dicUser["address"] is NSNull || dicUser["address"] == nil {
            strAddresss = ""
        } else {
            strAddresss = dicUser["address"] as! String
        }
        
        if dicUser["phone"] is NSNull || dicUser["phone"] == nil {
            strPhone = ""
        } else {
            strPhone = dicUser["phone"] as! String
        }
        
        if dicUser["level_id"] is NSURL || dicUser["level_id"] == nil {
            intLevelId = 0
        } else {
            intLevelId = dicUser["level_id"] as! NSInteger
        }

        // set info
        myNameLabel.text = strName
        myProfileImage.setImageWithURLStringNoCache(strPhoto,
                                              placeholderImage: UIImage.init(named: "icon_avatar.png"))
        myProfileImage.layer.masksToBounds = true
        myProfileImage.layer.cornerRadius = myProfileImage.layer.frame.size.width / 2
        
        myLevelImage.image = levelImages[intLevelId]
        createdDateLabel.text = strCreatedAt
        addressLabel.text = strAddresss
        phoneNumberLabel.text = strPhone
        if intLevelId > 0 {
            levelLabel.text = levelNames2[intLevelId]
        } else {
            levelLabel.text = ""
        }
    }
}

extension MyRecmMemberDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
