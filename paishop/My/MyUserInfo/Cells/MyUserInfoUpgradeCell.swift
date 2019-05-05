

import UIKit
import BEMCheckBox

class MyUserInfoUpgradeCell: UITableViewCell, BEMCheckBoxDelegate {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    var parentVC: MyUserInfoUpgradeVC!
    var degree: DegreeModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ degree: DegreeModel, parentVC: MyUserInfoUpgradeVC) {
        self.parentVC = parentVC
        self.degree = degree
        
        feeLabel.text = "  π" + String.init(format: "%.2f", degree.fee!) 
        periodLabel.text = "/\(degree.period!)天"
        if degree.id! == parentVC.selectedDegree {
            checkBox.on = true
            checkBox.isEnabled = false
        } else {
            checkBox.on = false
            checkBox.isEnabled = true
        }
        
        checkBox.delegate = self
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox.on {
            parentVC.selectedDegree = degree.id!
            parentVC.updateFields()
        }
    }
    
    
    
}
