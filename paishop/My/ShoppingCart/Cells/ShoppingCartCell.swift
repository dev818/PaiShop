
import UIKit
import BEMCheckBox

class ShoppingCartCell: UITableViewCell {    
    
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var productSelectView: UIView!
    @IBOutlet weak var calculatorView: UIView! {
        didSet {
            calculatorView.isHidden = true
        }
    }
    @IBOutlet weak var calcNumberLabel: UILabel!
    @IBOutlet weak var calcPlusButton: RoundRectButton!
    @IBOutlet weak var calcMinusButton: RoundRectButton!
    @IBOutlet weak var calcCompleteButtonBg: GradientView!
    @IBOutlet weak var calcNumberFrame: RoundRectView!
    
    
    
    var cart: CartModel!
    var shoppingCartVC: ShoppingCartVC! //var shoppingCartVC: MyOrderMineTab2VC!
    var productCount: Int = 1
    var indexPath: IndexPath!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.updateProductNumber()
        
        let checkBoxViewTap = UITapGestureRecognizer(target: self, action: #selector(selectCheckBoxView))
        checkBoxView.isUserInteractionEnabled = true
        checkBoxView.addGestureRecognizer(checkBoxViewTap)
        
        let productImageViewTap = UITapGestureRecognizer(target: self, action: #selector(selectProduct))
        productImageView.isUserInteractionEnabled = true
        productImageView.addGestureRecognizer(productImageViewTap)
        
        let productSelectViewTap = UITapGestureRecognizer(target: self, action: #selector(selectProduct))
        productSelectView.isUserInteractionEnabled = true
        productSelectView.addGestureRecognizer(productSelectViewTap)
        
        setupTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        checkBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        calcPlusButton.borderColor = MainColors.themeEndColors[selectedTheme]
        calcPlusButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        calcMinusButton.borderColor = MainColors.themeEndColors[selectedTheme]
        calcMinusButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        calcNumberLabel.textColor = MainColors.themeEndColors[selectedTheme]
        calcCompleteButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        calcCompleteButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        calcNumberFrame.borderColor = MainColors.themeEndColors[selectedTheme]
    }
    
    func setContent(_ cart: CartModel, vc: ShoppingCartVC, indexPath: IndexPath) {//func setContent(_ cart: CartModel, vc: MyOrderMineTab2VC, indexPath: IndexPath) {
        self.cart = cart
        self.shoppingCartVC = vc
        self.indexPath = indexPath
        
        checkBox.delegate = self
        checkBox.on = cart.checked
        self.productCount = cart.count!
        let item = cart.item
        
        if (item?.images?.count)! > 0 {
            if let itemUrl = item?.images?.first, itemUrl != "" {
                let resizedItemUrl = Utils.getResizedImageUrlString(itemUrl, width: "200")
                productImageView.setImageWithURLString(resizedItemUrl)
            }
        }
        
        
        productNameLabel.text = item?.name
        productPriceLabel.text = "¥" + (item?.price)!
        self.updateProductNumber()
    }
        
    
    @IBAction func selectEdit(_ sender: UIButton) {
        calculatorView.isHidden = false
    }
    
    @IBAction func selectCalcComplete(_ sender: UIButton) {
        let parameters: [String: Any] = [
            "id" : cart.id!,
            "count" : productCount
        ]
        MyAPI.shared.cartChange(params: parameters) { (json, success) in
            if success {
                self.calculatorView.isHidden = true
                //print("Change Cart...")
                //print(json)
                let storeId = self.shoppingCartVC.storeIds[self.indexPath.section]
                self.shoppingCartVC.cartsDic[storeId]![self.indexPath.row].count = self.productCount
                
                let cartId = self.shoppingCartVC.cartsDic[storeId]![self.indexPath.row].id!
                for i in 0..<self.shoppingCartVC.carts.count {
                    if self.shoppingCartVC.carts[i].id! == cartId {
                        self.shoppingCartVC.carts[i].count = self.productCount
                    }
                }
                
                self.shoppingCartVC.tableView.ts_reloadData {
                    self.shoppingCartVC.calculateSum()
                }
            } else {
                // try again
                MyAPI.shared.cartChange(params: parameters, completion: { (json, success1) in
                    self.calculatorView.isHidden = true
                    if success1 {
                        let storeId = self.shoppingCartVC.storeIds[self.indexPath.section]
                        self.shoppingCartVC.cartsDic[storeId]![self.indexPath.row].count = self.productCount
                        let cartId = self.shoppingCartVC.cartsDic[storeId]![self.indexPath.row].id!
                        for i in 0..<self.shoppingCartVC.carts.count {
                            if self.shoppingCartVC.carts[i].id! == cartId {
                                self.shoppingCartVC.carts[i].count = self.productCount
                            }
                        }
                    }
                    
                    self.shoppingCartVC.tableView.ts_reloadData {
                        self.shoppingCartVC.calculateSum()
                    }
                })
            }
            
            
        }
    }
    
    @IBAction func selectCalcPlus(_ sender: UIButton) {
        self.productCount += 1
        self.updateProductNumber()
    }
    
    @IBAction func selectCalcMinus(_ sender: UIButton) {
        if self.productCount > 1 {
            self.productCount -= 1
            self.updateProductNumber()
        }
    }
    
    @objc func selectCheckBoxView() {
        self.checkBox.setOn(!self.checkBox.on, animated: true)
        self.updateCheckBox()
    }
    
    @objc func selectProduct() {
        let storeId = self.shoppingCartVC.storeIds[indexPath.section]
        let cart = self.shoppingCartVC.cartsDic[storeId]![indexPath.row]
        let productId = (cart.item?.id)!
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = productId
        self.shoppingCartVC.pushAndHideTabbar(vc)
    }
    
    private func updateProductNumber() {
        numberLabel.text = "x\(productCount)"
        calcNumberLabel.text = "\(productCount)"
    }
    
    
    private func updateCheckBox() {
        let storeId = shoppingCartVC.storeIds[indexPath.section]
        shoppingCartVC.cartsDic[storeId]![indexPath.row].checked = self.checkBox.on
        
        let cartId = shoppingCartVC.cartsDic[storeId]![indexPath.row].id!
        for i in 0..<shoppingCartVC.carts.count {
            if shoppingCartVC.carts[i].id! == cartId {
                shoppingCartVC.carts[i].checked = checkBox.on
            }
        }
        
        let storeCarts = shoppingCartVC.cartsDic[storeId]!
        var allSelected = true
        for storeCart in storeCarts {
            if !storeCart.checked {
                allSelected = false
            }
        }
        if allSelected {
            shoppingCartVC.stores[indexPath.section].checked = true
        } else {
            shoppingCartVC.stores[indexPath.section].checked = false
        }
        
        self.shoppingCartVC.allCheckBox.on = self.shoppingCartVC.checkAllSelected()
        
        shoppingCartVC.tableView.ts_reloadData {
            self.shoppingCartVC.calculateSum()
        }
    }
    
}



extension ShoppingCartCell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        self.updateCheckBox()
        
    }
}






