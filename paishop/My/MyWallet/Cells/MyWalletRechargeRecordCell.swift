

import UIKit

class MyWalletRechargeRecordCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ paymentList: PaymentListModel) {
        dateLabel.text = paymentList.paymentDate
        //type: Bool? // true - recharge, false - withdraw
        if !(paymentList.type!) {
            idLabel.text = "转入"
            idLabel.textColor = UIColor.red
        } else {
            idLabel.text = "转出"
            idLabel.textColor = UIColor.green
        }
        //idLabel.text = String(paymentList.id!)
        amountLabel.text = paymentList.paymentAmount
        
        if paymentList.status! == 0 {
            statusLabel.text = "拒绝"
            statusLabel.textColor = UIColor(colorWithHexValue: 0xFF3E03)
        } else if paymentList.status! == 1 {
            statusLabel.text = "成功"
            statusLabel.textColor = UIColor(colorWithHexValue: 0x299ae9)
        } else if paymentList.status! == 2 {
            statusLabel.text = "有待"
            statusLabel.textColor = UIColor.lightGray
        }
    }
    
}
