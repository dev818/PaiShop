

import UIKit

class ChatListCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
        }
    }
    @IBOutlet weak var lastMessageLabel: UILabel! {
        didSet {
            lastMessageLabel.text = ""
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.text = ""
        }
    }
    @IBOutlet weak var unreadNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.unreadNumberLabel.layer.masksToBounds = true
        self.unreadNumberLabel.layer.cornerRadius = self.unreadNumberLabel.frame.height / 2.0
    }
    
    func setCellContent(_ model: ChatListModel) {
        if model.type == 1 { //Group Chat
            self.avatarImageView.image = ImageAsset.social_chat_group.image
        } else {
            if model.users.count > 0 {
                if let image = model.users.first?.image, image != "" {
                    let resizedUrl = Utils.getResizedImageUrlString((model.users.first?.image)!, width: "200")
                    self.avatarImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
                } else {
                    self.avatarImageView.image = ImageAsset.icon_avatar.image
                }                
            } else {
                self.avatarImageView.image = ImageAsset.icon_avatar.image
            }
        }
        //self.unreadNumberLabel.text = model.unreadNumber! > 99 ? "99+" : String(model.unreadNumber!)
        self.unreadNumberLabel.isHidden = true //(model.unreadNumber == 0)
        self.nameLabel.text = model.name
        if model.name.isEmpty {
            if model.users.count > 0 {
                self.nameLabel.text = model.users.first?.name
                if (model.users.first?.name?.isEmpty)! {
                    self.nameLabel.text = Utils.getNickNameFromPhoneNumber((model.users.first?.phoneNumber)!)
                }
            }            
        }
        if (model.lastMessage?.id?.isEmpty)! {
            self.lastMessageLabel.text = " "
        } else {
            if model.lastMessage?.messageContentType == MessageContentType.Text {
                self.lastMessageLabel.text = model.lastMessage?.message
            } else if model.lastMessage?.messageContentType == MessageContentType.Image {
                self.lastMessageLabel.text = "图像"
            }
            
        }
        self.dateLabel.text = model.dateString
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
