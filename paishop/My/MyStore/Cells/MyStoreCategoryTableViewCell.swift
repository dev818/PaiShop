//
//  MyStoreCategoryTableViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/11.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyStoreCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    
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
    }
    
}
