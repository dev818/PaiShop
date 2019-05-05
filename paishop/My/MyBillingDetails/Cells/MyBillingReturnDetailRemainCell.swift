
import UIKit

class MyBillingReturnDetailRemainCell: UITableViewCell {
    
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
    
    func setCellContent(_ release: ReleaseModel, releaseType: Bool, row: Int) {
        let startDateString = release.expectAt!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: startDateString)!
        
        var dateComponent = DateComponents()
        dateComponent.month = row
        let date = Calendar.current.date(byAdding: dateComponent, to: startDate)!
        let dateString = dateFormatter.string(from: date)
        dateLabel.text = dateString
        
        amountLabel.text = releaseType ? release.sellerRestitution : release.buyerRestitution
        
        let releaseCount = release.releaseCount!
        let releasePeriod = release.releasePeriod!
        periodNumberLabel.text = "\(releaseCount + row + 1)/\(releasePeriod)"
        
    }
    
}
