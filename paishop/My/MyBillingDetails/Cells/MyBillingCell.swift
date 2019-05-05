
import UIKit

class MyBillingCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ billing: BillingModel) {
        //let dates = billing.createdAt!.split(separator: " ")
        //dateLabel.text = String(dates[0])
        
        let dates = billing.createdAt!
        dateLabel.text = String(dates)
        amountLabel.text = billing.amount
        if(billing.comment == "卖商品") {
            commentLabel.text = "售出商品"
        } else {
            commentLabel.text = billing.comment
        }
    }
    
}
