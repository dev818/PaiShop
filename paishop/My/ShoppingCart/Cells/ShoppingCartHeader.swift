
import UIKit
import BEMCheckBox

class ShoppingCartHeader: UITableViewHeaderFooterView {
    
    var store: StoreModel!
    var shoppingCartVC: ShoppingCartVC! //var shoppingCartVC: MyOrderMineTab2VC!
    var section: Int!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var degreeImageView: UIImageView!
    
    func setContent(_ store: StoreModel, vc: ShoppingCartVC, section: Int) {//func setContent(_ store: StoreModel, vc: MyOrderMineTab2VC, section: Int) { 
        self.store = store
        self.shoppingCartVC = vc
        self.section = section
        
        checkBox.delegate = self
        checkBox.on = store.checked
        nameLabel.text = store.name
        
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        checkBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        
    }

}


extension ShoppingCartHeader: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        self.shoppingCartVC.stores[section].checked = checkBox.on
        
        let storeId = self.store.storeId!
        
        for i in 0..<self.shoppingCartVC.cartsDic[storeId]!.count {
            self.shoppingCartVC.cartsDic[self.store.storeId!]![i].checked = checkBox.on
        }
        
        for i in 0..<self.shoppingCartVC.carts.count {
            if self.shoppingCartVC.carts[i].item?.store?.storeId! == storeId {
                self.shoppingCartVC.carts[i].checked = checkBox.on
            }
        }
        
        self.shoppingCartVC.allCheckBox.on = self.shoppingCartVC.checkAllSelected()
        
        self.shoppingCartVC.tableView.reloadData {
            self.shoppingCartVC.calculateSum()
        }
    }
}








