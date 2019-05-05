
import UIKit
import BEMCheckBox

class ShoppingCartVC: UIViewController {

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var manageMenuView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerHeaderFooterNib(ShoppingCartHeader.self)
            tableView.ts_registerCellNib(ShoppingCartCell.self)
        }
    }
    @IBOutlet weak var manageMenuHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var allCheckBox: BEMCheckBox!
    @IBOutlet weak var calcButton: UIButton!
    @IBOutlet weak var sumLabel: UILabel! {
        didSet {
            sumLabel.text = "0"
        }
    }
    
    //@IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var calcButtonBg: GradientView!
    
    
    
    var isShowManageMenu = false
    var carts: [CartModel] = []
    var storeIds: [Int64] = []
    var stores: [StoreModel] = []
    var cartsDic: [Int64 : [CartModel]] = [:]
    
    var totalAmount: Double = 0.0
    var paymentType: Int = 1
    var currencyRate: Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        
        self.manageMenuHeightConstraint.constant = 0
        self.manageMenuView.isHidden = true
        self.navBar.rightButton.setTitle("管理", for: .normal)
        allCheckBox.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.currencyRate != nil {
            self.currencyRate = appDelegate.currencyRate
        } else {
            self.currencyRate = UserDefaultsUtil.shared.getCurrencyRate()
        }
        
        self.loadCarts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveItemsRemoved), name: NSNotification.Name(Notifications.CART_ITEMS_REMOVE), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "我的购物车"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        navBar.rightButton.isHidden = false
        navBar.rightButton.addTarget(self, action: #selector(selectNavRight), for: .touchUpInside)
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        //segmentedControl.tintColor = MainColors.themeEndColors[selectedTheme]
        calcButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        calcButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        allCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        allCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func loadCarts() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        self.tableView.isHidden = true
        self.calcButton.isEnabled = false
        self.allCheckBox.isEnabled = false
        
        let parameters: [String : Any] = [
            "payment" : self.paymentType
        ]
        MyAPI.shared.cartList(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.tableView.isHidden = false
                self.calcButton.isEnabled = true
                self.allCheckBox.isEnabled = true
                print("Cart All...")
                print(json)
                self.reloadData(CartModel.getCartsFromJson(json["cart"]))
            } else {
                // load again...
                MyAPI.shared.cartList(params: parameters) { (json, success1) in
                    ProgressHUD.dismiss()
                    self.tableView.isHidden = false
                    self.calcButton.isEnabled = true
                    self.allCheckBox.isEnabled = true
                    if success1 {
                        self.reloadData(CartModel.getCartsFromJson(json["cart"]))
                    }
                }
            }
        }
    }
    
    /*@IBAction func itemChanged(_ sender: UISegmentedControl) {
        self.resetFields()
        self.allCheckBox.on = false
        let selectedIndex = sender.selectedSegmentIndex
        self.paymentType = selectedIndex + 1
        self.loadCarts()
    }*/
    
    
    @IBAction func deleteCarts(_ sender: Any) {
        var selectedIds: [Int64] = []
        for cart in self.carts {
            if cart.checked {
                selectedIds.append(cart.id!)
            }
        }
        
        if selectedIds.isEmpty {
            ProgressHUD.showWarningWithStatus("悠还没有选择哦!")
            return
        }
        
        self.presentAlert("确认要删除这\(selectedIds.count)件商品吗?") {
            self.deleteSelectedCarts(ids: selectedIds)
        }
        
    }
    
    @IBAction func selectCalcButton(_ sender: UIButton) {
        var itemsString = "["
        var cartIdsString = "["
        var products: [ProductDetailModel] = []
        var productCounts: [Int] = []
        
        var isFirstItem = true
        for cart in self.carts {
            if cart.checked {
                let product = cart.item!
                
                products.append(product)
                productCounts.append(cart.count!)
                let itemString = "\"[" + String(cart.item!.id!) + "," + String(cart.count!) + "]\""
                if isFirstItem {
                    itemsString += itemString
                    cartIdsString += String(cart.id!)
                    isFirstItem = false
                } else {
                    itemsString += "," + itemString
                    cartIdsString += "," + String(cart.id!)
                }
            }
        }
        itemsString += "]"
        cartIdsString += "]"
        
        if isFirstItem {
            return
        }
        print("Items String...", itemsString)
        print("Cart Ids String...", cartIdsString)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyVC.nameOfClass) as! MyBuyVC
        vc.items = itemsString
        vc.cartIds = cartIdsString
        vc.products = products
        vc.productCounts = productCounts
        vc.paymentType = self.paymentType
        vc.currencyRate = self.currencyRate
        
        self.pushAndHideTabbar(vc)
    }
    
    @objc func receiveItemsRemoved() {
        self.loadCarts()
        self.resetFields()
    }
    
    private func resetFields() {
        for i in 0..<self.carts.count {
            self.carts[i].checked = false
        }
        
        for i in 0..<self.stores.count {
            self.stores[i].checked = false
        }
        
        for storeId in self.storeIds {
            for i in 0..<self.cartsDic[storeId]!.count {
                self.cartsDic[storeId]![i].checked = false
            }
        }
        
        self.tableView.ts_reloadData {
            self.calculateSum()
        }
    }
    
    
    @objc func selectNavRight() {
        self.isShowManageMenu = !self.isShowManageMenu
        if self.isShowManageMenu {
            self.manageMenuHeightConstraint.constant = 44
            self.manageMenuView.isHidden = false
            self.navBar.rightButton.setTitle("完成", for: .normal)
        } else {
            self.manageMenuHeightConstraint.constant = 0
            self.manageMenuView.isHidden = true
            self.navBar.rightButton.setTitle("管理", for: .normal)
        }
    }
    
    func calculateSum() {
        var totalAmount = 0.0
        var itemCount = 0
        for cart in self.carts {
            if cart.checked {
                if let price = cart.item?.price, let count = cart.count {
                    totalAmount += Double(price)! * Double(count)
                    itemCount += 1
                }
            }
        }
        
        self.totalAmount = totalAmount
        self.sumLabel.text = "¥" + String.init(format: "%.2f", totalAmount)
        if paymentType == 1 && currencyRate != nil {
            let paiTotal = self.totalAmount / currencyRate
            self.sumLabel.text = String.init(format: "%.2f", paiTotal) + "π"
        }
        
        self.calcButton.setTitle("结算(\(itemCount))", for: .normal)
    }
    
    func checkAllSelected() -> Bool {
        var allSelected = true
        for cart in self.carts {
            if !cart.checked {
               allSelected = false
            }
        }
        
        return allSelected
    }
    
    
    private func deleteSelectedCarts(ids: [Int64]) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        let parameters: [String: Any] = [
            "ids" : ids
        ]
        MyAPI.shared.cartDeletes(params: parameters) { (json, success) in
            if success {
                //print("Cart Deletes..........")
                //print(json)
                var remainingCarts: [CartModel] = []
                for cart in self.carts {
                    if !ids.contains(cart.id!) {
                        remainingCarts.append(cart)
                    }
                }
                self.reloadData(remainingCarts)
            } else {
                // try again...
                MyAPI.shared.cartDeletes(params: parameters, completion: { (json, success1) in
                    if success1 {
                        var remainingCarts: [CartModel] = []
                        for cart in self.carts {
                            if !ids.contains(cart.id!) {
                                remainingCarts.append(cart)
                            }
                        }
                        self.reloadData(remainingCarts)
                    }
                })
            }
        }
    }
    
    private func reloadData(_ carts: [CartModel]) {
        self.carts = []
        self.storeIds = []
        self.stores = []
        self.cartsDic = [:]
        
        self.carts = carts
        
        // Get storeIds from carts
        for cart in self.carts {
            guard let storeId = cart.item?.store?.storeId else {
                return
            }
            if !self.storeIds.contains(storeId) {
                self.storeIds.append(storeId)
                self.stores.append((cart.item?.store)!)
            }
        }
        
        print("storeIds..........")
        print(self.storeIds)
        
        for storeId in self.storeIds {
            var tempCarts: [CartModel] = []
            for cart in self.carts {
                guard let tempStoreId = cart.item?.store?.storeId else {
                    continue
                }
                if tempStoreId == storeId {
                    tempCarts.append(cart)
                }
            }
            self.cartsDic[storeId] = tempCarts
        }
        
        //print("cartsDic............")
        //print(self.cartsDic)
        
        self.tableView.ts_reloadData {  }
        self.calculateSum()
    }

}


extension ShoppingCartVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.storeIds.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let storeId = self.storeIds[section]
        return (self.cartsDic[storeId]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShoppingCartCell = tableView.ts_dequeueReusableCell(ShoppingCartCell.self)
        let storeId = self.storeIds[indexPath.section]
        let cart = self.cartsDic[storeId]![indexPath.row]
        cell.setContent(cart, vc: self, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: ShoppingCartHeader = tableView.ts_dequeueReusableHeaderFooter(ShoppingCartHeader.self)
        let store = self.stores[section]
        cell.setContent(store, vc: self, section: section)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 4
    }
    
}



extension ShoppingCartVC: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        for i in 0..<self.carts.count {
            self.carts[i].checked = checkBox.on
        }
        
        for i in 0..<self.stores.count {
            self.stores[i].checked = checkBox.on
        }
        
        for storeId in self.storeIds {
            for i in 0..<self.cartsDic[storeId]!.count {
                self.cartsDic[storeId]![i].checked = checkBox.on
            }
        }
        
        self.tableView.ts_reloadData {
            self.calculateSum()
        }
        
    }
}



extension ShoppingCartVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}







