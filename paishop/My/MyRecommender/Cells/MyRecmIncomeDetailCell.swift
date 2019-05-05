//
//  MyRecmIncomeDetailCell.swift
//  paishop
//
//  Created by Admin on 8/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyRecmIncomeDetailCell: UITableViewCell {
    
    @IBOutlet weak var recmMemberImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!    
    @IBOutlet weak var eventDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        recmMemberImage.layer.masksToBounds = true
        recmMemberImage.layer.cornerRadius = recmMemberImage.frame.size.width / 2
        
        nameLabel.text = ""
        descriptionLabel.text = ""
        eventDateLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setInfo(dic: NSDictionary) {
        var strName = String()
        var strPhoto = String()
        var strCreatedAt = String()
        var strDescription = String()
        var intAmount = NSInteger()

        if dic["sender_name"] is NSNull || dic["sender_name"] == nil {
            strName = ""
        } else {
            strName = dic["sender_name"] as! String
        }
        
        if dic["image"] is NSNull || dic["image"] == nil {
            strPhoto = ""
        } else {
            strPhoto = dic["image"] as! String
        }
        
        if dic["description"] is NSNull || dic["description"] == nil {
            strDescription = ""
        } else {
            strDescription = dic["description"] as! String
        }
        
        if dic["created_at"] is NSNull || dic["created_at"] == nil {
            strCreatedAt = ""
        } else {
            strCreatedAt = dic["created_at"] as! String
        }
        
        if dic["amount"] is NSNull || dic["amount"] == nil {
            intAmount = 0
        } else {
            intAmount = dic["amount"] as! NSInteger
        }
        
//        dic["amount"] as NSInteger
        
        // set values
        if strPhoto.count > 0 {
            recmMemberImage.sd_setImage(with: NSURL.init(string: strPhoto)! as URL, completed: nil)
        } else {
            recmMemberImage.image = UIImage.init(named: "my_recm_profile1.png")
        }
        
        nameLabel.text = strName
        //descriptionLabel.text = String(format: "%@%li%@", strDescription, intAmount, "π")
        descriptionLabel.text = String(format: "%@", strDescription)
        eventDateLabel.text = strCreatedAt
        
    }
}
