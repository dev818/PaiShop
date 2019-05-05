//
//  SecondLevelMemberCollectionViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/08/31.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class SecondLevelMemberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgLevel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initMainView()
    }
    
    func initMainView() {
        imgPhoto.layer.masksToBounds = true
        imgPhoto.layer.cornerRadius = imgPhoto.layer.frame.size.width / 2
        
    }

    func setInfo(dic: NSDictionary) {
        var strImage = String()
        var strName = String()
        var intLevelId = NSInteger()
        
        if (dic["image"] is NSNull) || dic["image"] == nil {
            imgPhoto.image = UIImage.init(named: "icon_avatar.png")
        } else {
            strImage = dic["image"] as! String
            imgPhoto.sd_setImage(with: NSURL.init(string: strImage)! as URL, completed: nil)
        }
        
        if (dic["pai_name"] is NSNull) || dic["pai_name"] == nil {
            strName = ""
        } else {
            strName = dic["pai_name"] as! String
        }
        
        if (dic["level_id"] is NSNull) || dic["level_id"] == nil {
            intLevelId = 0
        } else {
            intLevelId = dic["level_id"] as! NSInteger
        }
        
        lblName.text = strName
        imgLevel.image = levelImages[intLevelId]
        
    }
}
