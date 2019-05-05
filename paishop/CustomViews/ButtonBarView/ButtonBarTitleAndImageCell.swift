
import UIKit

class ButtonBarTitleAndImageCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImage: RoundImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImageHeightConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
