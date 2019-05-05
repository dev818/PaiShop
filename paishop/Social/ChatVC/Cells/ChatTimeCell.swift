
import UIKit


private let kChatTimeLabelMaxWdith : CGFloat = UIScreen.ts_width - 30*2
private let kChatTimeLabelPaddingLeft: CGFloat = 6   // Set aside 6 pixels left and right respectively
private let kChatTimeLabelPaddingTop: CGFloat = 3   // Set aside 3 pixels left and right respectively
private let kChatTimeLabelMarginTop: CGFloat = 10   // Top 10 px



class ChatTimeCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.layer.cornerRadius = 4
            timeLabel.layer.masksToBounds = true
            timeLabel.textColor = UIColor.white
            timeLabel.backgroundColor = UIColor (red: 190/255, green: 190/255, blue: 190/255, alpha: 0.6 )
        }
    }
    
    var model: ChatMessageModel?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    func setCellContent(_ model: ChatMessageModel) {
        self.model = model
        self.timeLabel.text = String(format: "%@", model.message!)
    }
    
    override func layoutSubviews() {
        guard let message = self.model?.message else { return }
        self.timeLabel.ts_setFrameWithString(message, width: kChatTimeLabelMaxWdith)
        self.timeLabel.width = self.timeLabel.width + kChatTimeLabelPaddingLeft*2
        self.timeLabel.left =  (UIScreen.ts_width - self.timeLabel.width) / 2
        self.timeLabel.height = self.timeLabel.height + kChatTimeLabelPaddingTop*2
        self.timeLabel.top = kChatTimeLabelMarginTop
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func heightForCell() -> CGFloat {
        return 40
    }
    
}














