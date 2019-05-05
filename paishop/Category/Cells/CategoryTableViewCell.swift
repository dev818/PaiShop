//
//  CategoryTableViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/02.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTitle1: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func setInfo(dic: NSDictionary) {
        var strName = String()
        
        if dic["name"] is NSURL || dic["name"] == nil {
            strName = ""
        } else {
            strName = dic["name"] as! String
        }
        
        lblTitle.text = strName
        lblTitle1.text = strName
        
        bgView.isHidden = true

    }
    
    func setSelected() {
        bgView.isHidden = false
    }
}
