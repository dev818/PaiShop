

import UIKit

class HomeProductDetailCommentCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ comment: CommentModel, parentVC: HomeProductDetailVC) {
        nameLabel.text = comment.user?.name
        
        let dates = comment.createdAt!.split(separator: " ")
        if dates.count > 0 {
            dateLabel.text = String(dates.first!) //parentVC.getFormattedDateString(comment.createdAt!)
        } else {
            dateLabel.text = ""
        }
        
        descriptionLabel.text = comment.text
    }
    
}
