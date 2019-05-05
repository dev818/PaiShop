

import UIKit
import DropDown
import BEMCheckBox

class MyStoreOrderDetailVC: UIViewController {
    
    var orderId: Int64!
    var orderIndex: Int!
    var originOrderStatus: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var buyerNameLabel: UILabel!
    @IBOutlet weak var buyerPhoneLabel: UILabel!
    @IBOutlet weak var buyerAddressLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var productSelectView: UIView!
    
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deliverCheckBox: BEMCheckBox!
    @IBOutlet weak var cancelCheckBox: BEMCheckBox!
    @IBOutlet weak var checkBoxesFrame: UIStackView! {
        didSet {
            checkBoxesFrame.isHidden = true
        }
    }
    @IBOutlet weak var deliverCheckBoxFrame: UIStackView!
    @IBOutlet weak var cancelCheckBoxFrame: UIStackView!
    @IBOutlet weak var confirmButton: RoundRectButton! {
        didSet {
            confirmButton.isHidden = true
        }
    }
    
    @IBOutlet weak var deliveryNumberView: UIView! {
        didSet {
            deliveryNumberView.isHidden = true
        }
    }
    @IBOutlet weak var deliveryNumberField: UITextField!
    @IBOutlet weak var deliveryViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            deliveryViewHeightConstraint.constant = 0
        }
    }
    
    @IBOutlet weak var piImageView: UIImageView! {
        didSet {
            piImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    @IBOutlet weak var yuanImageView: UIImageView! {
        didSet {
            yuanImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    
    @IBOutlet weak var treasureFrame: UIView!
    @IBOutlet weak var treasureFrameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var piPriceLabel: UILabel!
    @IBOutlet weak var returnPeriodLabel: UILabel!
    @IBOutlet weak var returnPriceLabel: UILabel!
    
    @IBOutlet weak var transactionImageFrame: UIView!
    @IBOutlet weak var transactionImageView: UIImageView!
    
    @IBOutlet weak var confirmButtonBg: GradientView! {
        didSet {
            confirmButtonBg.isHidden = true
        }
    }
    
    
    var currencyRate: Double = 6.58
    var restitutionRate: Double = 200.00
    
    var order: OrderModel!
    var product: ProductListModel!
    var statusDropDown: DropDown!
    var checkBoxGroup: BEMCheckBoxGroup!
    var selectedStatusIndex: Int!
    var statusChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.scrollView.isHidden = true
        self.loadOrderDetail()
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "订单详情"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        confirmButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        confirmButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        deliverCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        deliverCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
        cancelCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        cancelCheckBox.onCheckColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func loadOrderDetail() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        let parameters: [String : Any] = [
            "id" : self.orderId
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.orderDetail(params: parameters) { (json, success) in
            
            if success {
                ProgressHUD.dismiss()
                print("Order Detail...")
                print(json)
                self.scrollView.isHidden = false
                let resultJson = json["order"]
                self.order = OrderModel.init(resultJson)
                self.product = ProductListModel.init(resultJson["item"])
                self.setupUI()
            } else {
                // load again...
                MyAPI.shared.orderDetail(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.scrollView.isHidden = false
                        let resultJson = json["order"]
                        self.order = OrderModel.init(resultJson)
                        self.product = ProductListModel.init(resultJson["item"])
                        self.setupUI()
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("加载失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("加载失败.")
                        }
                    }
                })
            }
        }
    }
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.currencyRate != nil {
            self.currencyRate = appDelegate.currencyRate
        } else {
            self.currencyRate = UserDefaultsUtil.shared.getCurrencyRate()
        }
        if appDelegate.restitutionRate != nil {
            self.restitutionRate = appDelegate.restitutionRate
        } else {
            self.restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        buyerNameLabel.text = order.userName
        buyerPhoneLabel.text = order.phoneNumber
        buyerAddressLabel.text = order.address
        
        let resizedUrl = Utils.getResizedImageUrlString((product.images?.first)!, width: "200")
        productImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)//productImageView.setImageWithURLString(API.IMAGE_URL + (product.images?.first)!, placeholderImage: ImageAsset.default_image.image)
        productNameLabel.text = product.name
        productPriceLabel.text = "¥" + order.price!
        productCountLabel.text = "x" + String(order.count!)
        
        let totalPrice = Double(order.price!)! * Double(order.count!) //+ Double(order.fare!)
        totalPriceLabel.text = "¥" + String(totalPrice)
        
        orderDateLabel.text = order.createdAt
        
        self.selectedStatusIndex = order.status!
        switch selectedStatusIndex {
        case 0:
            statusLabel.text = "取消"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
        case 1:
            statusLabel.text = "完成"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0x03A678)
        case 2:
            statusLabel.text = "等待"
            statusLabel.textColor = UIColor.lightGray
        case 3:
            statusLabel.text = "已发货"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFFA400)
        default:
            statusLabel.text = "等待"
            statusLabel.textColor = UIColor.lightGray
        }
        checkBoxGroup = BEMCheckBoxGroup(checkBoxes: [deliverCheckBox, cancelCheckBox])
        
        deliverCheckBox.delegate = self
        cancelCheckBox.delegate = self
        if selectedStatusIndex == 2 {
            checkBoxesFrame.isHidden = false
        } else if selectedStatusIndex == 3 {
            checkBoxesFrame.isHidden = false
            cancelCheckBoxFrame.isHidden = true
            checkBoxGroup.selectedCheckBox = deliverCheckBox
            confirmButton.isHidden = false
            confirmButtonBg.isHidden = false
        }
        
        
        if self.selectedStatusIndex == 3 {
            deliveryNumberView.isHidden = false
            deliveryViewHeightConstraint.constant = 44
            deliveryNumberField.isEnabled = true
        } else {
            deliveryNumberField.isEnabled = false
        }
        
        if let delivery = order.delivery {
            deliveryNumberField.text = delivery.receipt
            if !delivery.receipt!.isEmpty {
                deliveryNumberView.isHidden = false
                deliveryViewHeightConstraint.constant = 44
            }
        }
        
        if self.selectedStatusIndex == 0 || self.selectedStatusIndex == 2 {
            deliveryNumberView.isHidden = true
            deliveryViewHeightConstraint.constant = 0
        }
        
        if product.paymentType! == 1 {
            piImageView.isHidden = false
            yuanImageView.isHidden = true
        } else if product.paymentType! == 2 {
            piImageView.isHidden = true
            yuanImageView.isHidden = false
        }
        
        if product.paymentType! == 1 {
            treasureFrame.isHidden = false
            treasureFrameHeightConstraint.constant = 132
            
            /*let paiPrice = totalPrice / currencyRate
            piPriceLabel.text = String.init(format: "%.2f", paiPrice)*/
            piPriceLabel.text = order.salePrice
            
            var treasureRatio = product.treasureRatio!
            if treasureRatio < 1 {
                treasureRatio = 1
            }
            
            var restitutionRate: Double = 0
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.periodRatio != nil {
                restitutionRate = appDelegate.restitutionRate
            } else {
                restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
            }
            let periodDouble = Double(PAISHOP_PERIODS_TABLE[treasureRatio - 1])! * 135 / restitutionRate            
            
            let roundedPeriod = round(periodDouble)
            let period = Int(roundedPeriod)
            returnPeriodLabel.text = "\(period)"
            
            //let buyerReturn = Double(product.price!)! / Double(period)
            if let piPriceStr = order.salePrice, piPriceStr != "" {
                if let piPrice = Double(piPriceStr) {
                    let sellerReturn = piPrice * Double(treasureRatio) * self.restitutionRate / (10000.0 * Double(period))
                    returnPriceLabel.text = String.init(format: "%.2f", sellerReturn)
                }
            }
            
            if let restitutionModel = order.restitution, restitutionModel.id! > 0 {
                returnPeriodLabel.text = restitutionModel.period
                returnPriceLabel.text = restitutionModel.sellderRestitution
            }
            
        } else {
            treasureFrame.isHidden = true
            treasureFrameHeightConstraint.constant = 0
        }
        
        if(order.image! == "") {
            transactionImageFrame.isHidden = true
            transactionImageFrame.snp.makeConstraints { (make) in
                make.height.equalTo(0)
            }
        } else {
            transactionImageFrame.isHidden = false
            print("order image..........", order.image!)
            let resizedUrl = Utils.getResizedImageUrlString(order.image!, width: "800")
            transactionImageView.setImageWithURLString(resizedUrl)
        }
        
        
        
        let productTap = UITapGestureRecognizer(target: self, action: #selector(selectProduct))
        productSelectView.isUserInteractionEnabled = true
        productSelectView.addGestureRecognizer(productTap)
    }
    
    
    
    
    
    @objc func selectProduct() {
        Utils.applyTouchEffect(productSelectView)
        
        let productId = self.product.id!
        print("Product Id...", productId)
        if productId < 1 {
            return
        }
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = productId
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    
    
    @IBAction func selectConfirm(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let receipt = deliveryNumberField.text!
        
        if selectedStatusIndex == 3 && receipt.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入交货号码!")
            return
        } else if selectedStatusIndex == 3 && receipt.count < 4 {
            ProgressHUD.showErrorWithStatus("请输入有效的交货号码!")
            return
        }
        
        var parameters: [String : Any] = [
            "id" : order.id!,
            "status" : selectedStatusIndex
        ]
        if selectedStatusIndex == 3 {
            parameters["receipt"] = receipt
        }
        ProgressHUD.showWithStatus()
        self.navBar.rightButton.isEnabled = false
        MyAPI.shared.orderStatusChange(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.navBar.rightButton.isEnabled = true
                print("Order Status Change...")
                print(json)
                ProgressHUD.showSuccessWithStatus("成功更改状态")
                let info: [String : Any] = [
                    "orderIndex" : self.orderIndex,
                    "orderStatus" : self.selectedStatusIndex,
                    "originOrderStatus" : self.originOrderStatus
                ]
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_ORDER_CHANGE), object: nil, userInfo: info)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                // try again...
                MyAPI.shared.orderStatusChange(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    self.navBar.rightButton.isEnabled = true
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功更改状态")
                        let info: [String : Any] = [
                            "orderIndex" : self.orderIndex,
                            "orderStatus" : self.selectedStatusIndex,
                            "originOrderStatus" : self.originOrderStatus
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_ORDER_CHANGE), object: nil, userInfo: info)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("失败.")
                        }
                    }
                })
                
            }
        }
    }
        

}


extension MyStoreOrderDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyStoreOrderDetailVC: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        checkBoxGroup.mustHaveSelection = true
        if deliverCheckBox.on {
            selectedStatusIndex = 3
            deliveryNumberView.isHidden = false
            deliveryViewHeightConstraint.constant = 44
            deliveryNumberField.isEnabled = true
            confirmButton.isHidden = false
            confirmButtonBg.isHidden = false
        } else if cancelCheckBox.on {
            selectedStatusIndex = 0
            deliveryNumberView.isHidden = true
            deliveryViewHeightConstraint.constant = 0
            deliveryNumberField.isEnabled = false
            confirmButton.isHidden = false
            confirmButtonBg.isHidden = false
        }
        
    }
}













