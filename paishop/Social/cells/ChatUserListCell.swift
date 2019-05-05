

import UIKit

class ChatUserListCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
        // Configure the view for the selected state
    }
    
    func setCellContent(_ user: UserModel) {
        let resizedUrl = Utils.getResizedImageUrlString(user.image!, width: "200")
        avatarImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        nameLabel.text = user.name
        if (user.name?.isEmpty)! {
            nameLabel.text = Utils.getNickNameFromPhoneNumber(user.phoneNumber!)
        }
    }
    
}
