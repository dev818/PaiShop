//
//  CategoryCollectionViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/02.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func setInfo(dic: NSDictionary) {
        var strName = String()
        var strImage = String()
        
        if dic["name"] is NSNull || dic["name"] == nil {
            strName = ""
        } else {
            strName = dic["name"] as! String
        }
        
        if dic["image"] is NSNull || dic["image"] == nil {
            strImage = ""
        } else {
            strImage = dic["image"] as! String
        }
        
        // set value
        lblTitle.text = strName
        imgThumb.sd_setImage(with: NSURL.init(string: strImage)! as URL, completed: nil)
        
    }
    
}
