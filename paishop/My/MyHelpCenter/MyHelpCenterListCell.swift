
import UIKit

class MyHelpCenterListCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var statusFrame: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ ticket: TicketListModel) {
        switch ticket.status {
        case 0:
            statusLabel.text = "完结"
            statusFrame.backgroundColor = UIColor(colorWithHexValue: 0x299ae9)
        case 1:
            statusLabel.text = "回答"
            statusFrame.backgroundColor = UIColor.blue
        case 2:
            statusLabel.text = "等待答复"
            statusFrame.backgroundColor = UIColor.lightGray
        default:
            statusLabel.text = "等待答复"
            statusFrame.backgroundColor = UIColor.lightGray
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: ticket.updatedAt)!
        timeLabel.text = Date.messageAgoSinceDate(date)
        
        contentLabel.text = ticket.content
        
    }
    
}
