
import UIKit
import RxSwift
import RxCocoa

let kChatAvatarMarginLeft: CGFloat = 10             
let kChatAvatarMarginTop: CGFloat = 0
let kChatAvatarWidth: CGFloat = 40

class ChatBaseCell: UITableViewCell {
    weak var delegate: ChatCellDelegate?
    
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
    
    var model: ChatMessageModel?
    let disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        self.avatarImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        let tap = UITapGestureRecognizer()
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { (tapGesture) in
            guard let delegate = self.delegate else { return }
            delegate.cellDidTapedAvatarImage(self)
        }, onError: { (error) in
            // Handel Error
        }, onCompleted: {
            // Handle Completed
        }) {
            // Handle Disposed
        }.disposed(by: self.disposeBag)
    }
    
    func setCellContent(_ model: ChatMessageModel) {
        self.model = model
        if self.model!.fromMe {
            let avatarURL = UserInstance.avatar
            let resizedUrl = Utils.getResizedImageUrlString(avatarURL!, width: "200")
            self.avatarImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        } else {
            let avatarURL = model.user?.image
            let resizedUrl = Utils.getResizedImageUrlString(avatarURL!, width: "200")
            self.avatarImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
