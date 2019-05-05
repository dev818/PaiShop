//
//  HomeNewsTableViewCell.swift
//  paishop
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class HomeNewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    var notification: NotificationListModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ notification: NotificationListModel) {
        self.notification = notification
        
        itemLabel.text = notification.message
        itemImageView.setImageWithURLString(notification.imageUrl, placeholderImage: ImageAsset.default_image.image)
    }
    
    
}
