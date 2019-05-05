

import UIKit

class MyBillingReturnDetailCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var periodNumberLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ releaseTransaction: ReleaseTransactionModel, releasePeriod: Int, index: Int) {
        dateLabel.text = releaseTransaction.createdAt
        amountLabel.text = releaseTransaction.amount
        periodNumberLabel.text = "\(index + 1)/\(releasePeriod)"
    }
    
}
