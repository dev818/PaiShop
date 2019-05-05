
import UIKit

class MyOrderMineDetailVC: UIViewController {
    
    var orderId: Int64!
    var orderIndex: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var buyerNameLabel: UILabel!
    @IBOutlet weak var buyerPhoneLabel: UILabel!
    @IBOutlet weak var buyerAddressLabel: UILabel!
    
    @IBOutlet weak var storeSelectView: UIView!
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var productSelectView: UIView!
    
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var receiptLabel: UILabel!
    @IBOutlet weak var deliveryView: UIView! {
        didSet {
            deliveryView.isHidden = true
        }
    }
    @IBOutlet weak var deliveryViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            deliveryViewHeightConstraint.constant = 0
        }
    }
    @IBOutlet weak var confirmButton: RoundRectButton! {
        didSet {
            confirmButton.isHidden = true
        }
    }
    @IBOutlet weak var confirmButtonNew: UIButton!
    @IBOutlet weak var confirmBtnConstraint: NSLayoutConstraint!
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
    
    @IBOutlet weak var deliveryStatusBtn: RoundButton!
    @IBOutlet weak var inputDeliveryNumBackView: UIView!
    @IBOutlet weak var deliveryNumLabel: UILabel!
    @IBOutlet weak var deliveryDateFrameView: UIView!
    @IBOutlet weak var deliveryDateView: UIView! {
        didSet {
            deliveryDateView.isHidden = true
        }
    }
    @IBOutlet weak var deliveryStatusView: UIView! {
        didSet {
            deliveryStatusView.isHidden = true
        }
    }
    
    var order: OrderModel!
    var product: ProductListModel!
    var currencyRate: Double = 6.58
    var restitutionRate: Double = 200.00

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
        navBar.setDefaultNav()
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        //let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        //confirmButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        //confirmButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
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
                // try again...
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
        
        storeNameLabel.text = product.store?.name
        if (product.images?.count)! > 0 {
            if let productUrl = product.images?.first, productUrl != "" {
                let resizedProductUrl = Utils.getResizedImageUrlString(productUrl, width: "150")
                productImageView.setImageWithURLString(resizedProductUrl, placeholderImage: ImageAsset.default_image.image)
            }
        }
        
        
        productNameLabel.text = product.name
        productPriceLabel.text = "¥" + order.price!
        productCountLabel.text = "x" + String(order.count!)
        
        orderDateLabel.text = order.createdAt
        self.setupStatusLabel(order.status!)
        if let delivery = order.delivery {
            receiptLabel.text = delivery.receipt
            if !delivery.receipt!.isEmpty {
                //deliveryView.isHidden = false
                //deliveryViewHeightConstraint.constant = 44
                self.deliveryNumLabel.text = delivery.receipt
                inputDeliveryNumBackView.isHidden = false
            }
        }
        
        //h.g.n
        if order.status! == 2 {
            confirmBtnConstraint.constant = 10
            confirmButtonNew.isEnabled = false
            confirmButtonNew.alpha = 0.5
            deliveryStatusBtn.isHidden = true
            inputDeliveryNumBackView.isHidden = true
            deliveryDateFrameView.isHidden = true
        }
        
        if order.status! == 3 && !deliveryView.isHidden {
            confirmBtnConstraint.constant = 175
            headerTitleLabel.text = "待收货"
            //confirmButton.isHidden = false
            //confirmButtonBg.isHidden = false
            //h.g.n
            deliveryDateView.isHidden = true
            deliveryView.isHidden = true
            deliveryDateFrameView.isHidden = true
        }
        
        if order.status! == 1 {
            headerTitleLabel.text = "完成"
            confirmButtonNew.isHidden = true
            //deliveryViewHeightConstraint.constant = -20
            deliveryDateFrameView.isHidden = true
        }
        
        let totalPrice = Double(order.price!)! * Double(order.count!)
        totalPriceLabel.text = "¥" + String(totalPrice)
        
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
            if appDelegate.periodRatio != nil {
                restitutionRate = appDelegate.restitutionRate
            } else {
                restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
            }
            let periodDouble = Double(PAISHOP_PERIODS_TABLE[treasureRatio - 1])! * 135 / restitutionRate
            let roundedPeriod = round(periodDouble)
            let period = Int(roundedPeriod)
            
            returnPeriodLabel.text = "\(period)"
            
            if let piPriceStr = order.salePrice, piPriceStr != "" {
                if let piPrice = Double(piPriceStr) {
                    let buyerReturn = piPrice / Double(period)
                    returnPriceLabel.text = String.init(format: "%.2f", buyerReturn)
                }
            }
            
            if let restitutionModel = order.restitution, restitutionModel.id! > 0 {
                returnPeriodLabel.text = restitutionModel.period
                returnPriceLabel.text = restitutionModel.buyerRestitution
            }
            
            
        } else {
            treasureFrame.isHidden = true
            treasureFrameHeightConstraint.constant = 0
        }
        
        
        let storeTap = UITapGestureRecognizer(target: self, action: #selector(selectStore))
        storeSelectView.isUserInteractionEnabled = true
        storeSelectView.addGestureRecognizer(storeTap)
        
        let productTap = UITapGestureRecognizer(target: self, action: #selector(selectProduct))
        productSelectView.isUserInteractionEnabled = true
        productSelectView.addGestureRecognizer(productTap)
        
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
        
    }
    
    @IBAction func callStoreBtnTapped(_ sender: UIButton) {
        print("call Btn Tapped!")
        let phoneString = product.store?.phoneNumber
        if let phoneStr = phoneString, !phoneStr.isEmpty {
            if let phoneCallURL:URL = URL(string: "tel://\(phoneStr)") {
                print("call phone=\(phoneStr)")
                let application:UIApplication = UIApplication.shared
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func transferInfoBtnTapped(_ sender: UIButton) {
        
        if let delivery = order.delivery {
            if !delivery.receipt!.isEmpty {
                let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
                vc.index = 9
                vc.transfer_id = delivery.receipt!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    

    @IBAction func confirmBtnTapped(_ sender: Any) {
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : orderId!,
            "status" : 1
        ]
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
                    "orderIndex" : self.orderIndex
                ]
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.MINE_ORDER_CHANGE), object: nil, userInfo: info)
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
                            "orderIndex" : self.orderIndex
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.MINE_ORDER_CHANGE), object: nil, userInfo: info)
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
    
    @objc func selectStore() {
        Utils.applyTouchEffect(storeSelectView)
        
        guard let store = self.product.store else { return }
        let storeId = store.storeId!
        print("Store Id...", storeId)
        if storeId < 1 {
            return
        }
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
        vc.storeId = storeId
        self.navigationController?.pushViewController(vc, animated: true)
        
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
    
    
    private func setupStatusLabel(_ index: Int) {
        switch index {
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
    }

}


extension MyOrderMineDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
























