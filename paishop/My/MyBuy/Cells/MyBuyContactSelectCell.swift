//
//  MyBuyContactSelectCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyBuyContactSelectCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCellContent(_ contact: ContactModel) {
        nameLabel.text = contact.name
        phoneLabel.text = contact.phoneNumber
        addressLabel.text = contact.address
    }
    
}
