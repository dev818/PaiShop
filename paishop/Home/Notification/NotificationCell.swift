//
//  NotificationCell.swift
//  paishop
//
//  Created by SeniorCorder on 5/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
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
        if notification.imageUrl != "" {
            let resizedUrl = Utils.getResizedImageUrlString(notification.imageUrl!, width: "100")
            itemImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        }
        
    }
    
}
