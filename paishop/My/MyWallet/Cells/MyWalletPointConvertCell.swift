
import UIKit

class MyWalletPointConvertCell: UICollectionViewCell {
    
    @IBOutlet weak var amountButton: RoundRectButton!
    
    var parentVC: MyWalletPointConvertVC!
    var row: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ selectedIndex: Int, row: Int, parentVC: MyWalletPointConvertVC) {
        self.parentVC = parentVC
        self.row = row
        if selectedIndex == row {
            amountButton.setTitleColor(UIColor.white, for: .normal)
            amountButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0x299ae9), forState: .normal)
        } else {
            amountButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
            amountButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        }
        amountButton.setTitle(self.parentVC.pointExchangeList[row] + "π", for: .normal)
    }
    
    @IBAction func selectAmount(_ sender: UIButton) {
        self.parentVC.selectedAmountIndex = row
        self.parentVC.collectionView.reloadData()
    }
    

}
