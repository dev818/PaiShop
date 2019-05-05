//
//  TicketBaseCell.swift
//  paishop
//
//  Created by Mac on 2/6/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit



class TicketBaseCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.backgroundColor = UIColor.clear
            avatarImageView.width = kChatAvatarWidth
            avatarImageView.height = kChatAvatarWidth
        }
    }
    
    @IBOutlet weak var nicknameLabel: UILabel! {
        didSet {
            nicknameLabel.font = UIFont.systemFont(ofSize: 11)
            nicknameLabel.textColor = UIColor.darkGray
        }
    }
    
    var model: TicketMessageModel?
    
    
    override func prepareForReuse() {
        self.avatarImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ model: TicketMessageModel) {
        self.model = model
        if self.model!.fromMe {
            let avatarURL = UserInstance.avatar
            let resizedUrl = Utils.getResizedImageUrlString(avatarURL!, width: "200")
            self.avatarImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        } else {
            self.avatarImageView.image = UIImage(named: "ic_my_help_center")
        }
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        guard let model = self.model else { return }
        if model.fromMe {
            self.nicknameLabel.height = 0
            self.avatarImageView.left = UIScreen.ts_width - kChatAvatarMarginLeft - kChatAvatarWidth
        } else {
            self.nicknameLabel.height = 0
            self.avatarImageView.left = kChatAvatarMarginLeft
        }
    }
    

}
