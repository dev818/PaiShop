

import UIKit

class MyUserInfoUpgradeDegreeCell: UICollectionViewCell {
    
    @IBOutlet weak var degreeImageView: UIImageView!
    @IBOutlet weak var roundView: RoundView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var degreeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ degree: DegreeModel) {
        degreeImageView.setImageWithURLString(degree.image)
        degreeLabel.text = degree.name
        
        let currentDegreeId = UserInstance.degreeId!
        if degree.id! > currentDegreeId {
            roundView.backgroundColor = UIColor.init(colorWithHexValue: 0xCECFCF)
            lineView.backgroundColor = UIColor.init(colorWithHexValue: 0xCECFCF)
        } else {
            roundView.backgroundColor = UIColor.init(colorWithHexValue: 0x299ae9)
            lineView.backgroundColor = UIColor.init(colorWithHexValue: 0x299ae9)
        }
    }

}
