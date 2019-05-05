

import UIKit

class HomeProductDetailCommentTitleCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ totalComments: Int) {
        titleLabel.text = "宝贝评价（\(totalComments)）"
    }
    
}
