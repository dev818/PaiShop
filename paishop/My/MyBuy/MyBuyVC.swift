
import UIKit
import Alamofire
import SwiftyJSON

class MyBuyVC: UIViewController {
    
    var items: String = ""
    var cartIds: String!
    var products: [ProductDetailModel] = []
    var productCounts: [Int] = []
    
    var paymentType = 1 // Pai: 1, Point:2, Weixin: 1, Alipay: 2
    var currencyRate: Double = 6.58
    var totalPrice: Double = 0.00
    var restitutionRate: Double = 200.00
    var oldSelectedMethod = 0 // 0: pai, 1: point, 2: weixin, 3: alipay
    
    @IBOutlet var checkMarkList: [UIImageView]!
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.tableFooterView = UIView()
            tableView.ts_registerCellNib(MyBuyContactCell.self)
            tableView.ts_registerCellNib(MyBuyCell.self)
            tableView.ts_registerCellNib(MyBuyPaiCell.self)
        }
    }
    @IBOutlet weak var totalPriceLabel: UILabel! {
        didSet {
            totalPriceLabel.text = "¥0.00"
        }
    }
    @IBOutlet weak var orderConfirmButton: UIButton!
    @IBOutlet weak var orderConfirmButtonBg: GradientView!
    
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customTransactionView: UIView!
    @IBOutlet weak var transactionField: UITextField!
    
    //QRCode View
    @IBOutlet var qrcodeView: UIView!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    
    @IBOutlet var customPayView: UIView!
    @IBOutlet weak var confirmTransactionButtonBg: GradientView!
    @IBOutlet var confirmPayView: UIView!
    @IBOutlet weak var payMethodImgOfConfirmView: UIImageView!
    let payImages: [UIImage] = [
        ImageAsset.payment_pai.image,
        ImageAsset.payment_point.image,
        ImageAsset.payment_weixin.image,
        ImageAsset.payment_ali.image,
        ]
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var ratePaiVSYeanLbl: UILabel!
    
    var contacts: [ContactModel] = []
    var defaultContact: ContactModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupUI()
        
        print("MYBuyVC:items:", items)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveQrPaySuccess(_:)), name: NSNotification.Name(Notifications.QR_PAY_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactAddBack(_:)), name: NSNotification.Name(Notifications.CONTACT_ADD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactSelect(_:)), name: NSNotification.Name(Notifications.CONTACT_SELECT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactsBack(_:)), name: NSNotification.Name(Notifications.CONTACTS_BACK), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createOrderProduct(_:)), name: NSNotification.Name(Notifications.ALIPAY_SUCCESS), object: nil)
        
        self.tableView.isHidden = true
        self.orderConfirmButton.isEnabled = false
        MyAPI.shared.contactList { (json, success) in
            self.tableView.isHidden = false
            self.orderConfirmButton.isEnabled = true
            if success {
                print("Contact List...", json)                
                self.contacts = ContactModel.getContactsFromJson(json["contacts"])
                if self.contacts.count > 0 {
                    self.getDefaultContact()
                } else {
                    self.presentAlert("请先设置收货地址", message: nil, completionOK: {
                        self.presentContactAddVC()
                    }, completionCancel: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            } else {
                self.presentOKAlert("不能获取收货地址", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupCustomViews()
    }
    
    private func presentContactAddVC() {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactAddVC.nameOfClass) as! MyBuyContactAddVC
        vc.isAdd = true
        vc.isModal = true
        vc.senderVC = MyBuyVC.nameOfClass
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        self.present(nav, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "我的订单"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        totalPriceLabel.textColor = MainColors.themeEndColors[selectedTheme]
        orderConfirmButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        orderConfirmButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        confirmTransactionButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        confirmTransactionButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
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
        
        self.setTotalPriceLabel()
        let rateString = "1π=" + String.init(format:"%.2f", self.currencyRate) + "人民币"
        self.ratePaiVSYeanLbl.text = rateString
        self.tableView.reloadData()
        
        let darkViewTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(darkViewTap)
    }
    
    func setTotalPriceLabel() {
        //var totalPrice: Double = 0
        for i in 0..<self.products.count {
            let price = Double(products[i].price!)! * Double(productCounts[i])
            totalPrice += price
        }
        self.totalPriceLabel.text = "¥" + String.init(format: "%.2f", totalPrice)
        
        if paymentType == 1 {
            let paiTotal = totalPrice / currencyRate
            self.totalPriceLabel.text = String.init(format: "%.2f", paiTotal) + "π"
            //self.finalPriceLabel.text = String.init(format: "%.2f", paiTotal) + "π"
        }
        
    }
    
    private func setupCustomViews() {
        self.view.addSubview(customTransactionView)
        customTransactionView.translatesAutoresizingMaskIntoConstraints = false
        customTransactionView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(196)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        
        self.view.addSubview(qrcodeView)
        qrcodeView.translatesAutoresizingMaskIntoConstraints = false
        qrcodeView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.width.height.equalTo(300)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        if cartIds == nil && (products.first?.qrimage)! != "" {
            let resizedUrl = Utils.getResizedImageUrlString((products.first?.qrimage)!, width: "800")
            qrcodeImageView.setImageWithURLString(resizedUrl)
        }
        
        let qrcodeImageTap = UITapGestureRecognizer(target: self, action: #selector(presentQrcodeSheet))
        qrcodeImageView.isUserInteractionEnabled = true
        qrcodeImageView.addGestureRecognizer(qrcodeImageTap)
        
        self.view.addSubview(customPayView)
        customPayView.translatesAutoresizingMaskIntoConstraints = false
        customPayView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(270)
            make.bottom.equalTo(self.view.bottom).offset(270)
        }
        
        self.view.addSubview(confirmPayView)
        confirmPayView.translatesAutoresizingMaskIntoConstraints = false
        confirmPayView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(315)
            make.bottom.equalTo(self.view.bottom).offset(315)
        }
    }
    
    @IBAction func selectConfirm(_ sender: UIButton) {
        self.view.endEditing(true)
        
        self.showCustomPayView()
    }
    
    private func presentTransaction() {
        if UserInstance.paiAddress!.isEmpty {
            self.presentAlert("没有π账号", message: "你没有π账号. \n 请添加你的π账号详细信息.")
            return
        }
        self.presentTransactionPass()
    }
    
    func presentOrderAlert() {
        let alert = UIAlertController(title: title, message: "直接购买或使用二维码?", preferredStyle: .alert)
        let qrcodeAction = UIAlertAction(title: "二维码", style: .default) { (action) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: QrCodeBuyModalVC.nameOfClass) as! QrCodeBuyModalVC
            vc.product = self.products.first
            vc.currencyRate = self.currencyRate
            vc.paymentType = self.paymentType
            vc.count = self.productCounts.first
            
            vc.items = self.getItemsString()
            vc.userName = self.defaultContact.name
            vc.address = self.defaultContact.address
            vc.phoneNumber = self.defaultContact.phoneNumber
            self.present(vc, animated: true, completion: { })
            
            //self.showQrcodeView()
        }
        let buyAction = UIAlertAction(title: "立即购买", style: .default) { (action) in
            self.presentTransaction()
        }
        alert.addAction(buyAction)
        alert.addAction(qrcodeAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func receiveQrPaySuccess(_ notification: Notification) {
        self.profileUpdate()
    }
    
    @objc func receiveContactAddBack(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyVC.nameOfClass {
            return
        }
        
        guard let contact = notification.userInfo?["contact"] as? ContactModel else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.contacts.append(contact)
        self.defaultContact = contact
        self.tableView.reloadData()        
    }
    
    @objc func receiveContactSelect(_ notification: Notification) {
        guard let contact = notification.userInfo?["contact"] as? ContactModel else { return }
        self.defaultContact = contact
        self.tableView.reloadData()
    }
    
    @objc func receiveContactsBack(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyVC.nameOfClass {
            return
        }
        
        guard let temp = notification.userInfo?["contacts"] as? [ContactModel] else { return }
        
        self.contacts = temp
    }
    
    
    @IBAction func closeCutomTransaction(_ sender: UIButton) {
        self.hideCustomTransactionView()
    }
    
    @IBAction func confirmTransaction(_ sender: UIButton) {
        let transactionPass = transactionField.text!
        if transactionPass.count < 4 {
            ProgressHUD.showErrorWithStatus("请输入有效的交易密码.")
            return
        }
        
        self.view.endEditing(true)
        let parameters: [String : Any] = [
            "payment_password" : transactionPass
        ]
        sender.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentPasswordVerify(params: parameters) { (json, success) in
            if success {
                sender.isEnabled = true
                ProgressHUD.dismiss()
                print("Payment Password Verify...")
                print(json)
                self.hideCustomTransactionView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.implementOrder()
                })
            } else {
                // try again...
                MyAPI.shared.paymentPasswordVerify(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.hideCustomTransactionView()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            self.implementOrder()
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
    
    @objc func presentQrcodeSheet() {
        let sheet = UIAlertController(title: "二维码", message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "存储图像", style: .default) { (action) in
            self.hideQrcodeView()
            let qrcodeImage = self.qrcodeImageView.image!
            UIImageWriteToSavedPhotosAlbum(qrcodeImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            //self.hideQrcodeView()
        }
        sheet.addAction(saveAction)
        sheet.addAction(cancelAction)
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(sheet, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            ProgressHUD.showErrorWithStatus(error.localizedDescription)
        } else {
            ProgressHUD.showSuccessWithStatus("保存成功")
        }
    }
    
    @objc func selectDarkView() {
        self.hideQrcodeView()
        self.hideCustomPayView()
        self.hideConfirmPayView()
        self.showDarkView(false)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func getItemsString() -> String {
        var itemsString = "["
        var isFirstItem = true
        for i in 0..<self.products.count {
            let itemString = "\"[" + String(products[i].id!) + "," + String(productCounts[i]) + "]\""
            if isFirstItem {
                itemsString += itemString
                isFirstItem = false
            } else {
                itemsString += "," + itemString
            }
        }
        itemsString += "]"
        print(itemsString)
        return itemsString
    }
    
    private func implementOrder() {
        var parameters: [String : Any] = [
            "items" : getItemsString(),
            "user_name" : self.defaultContact.name!,
            "address" : self.defaultContact.address!,
            "phone_number" : self.defaultContact.phoneNumber!,
            "currency" : self.paymentType
        ]
        if cartIds != nil {
            parameters["carts"] = cartIds
        }
        
        print("MyBuyVC:Order:", parameters)
            
        orderConfirmButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.orderCreate(params: parameters) { (json, success) in
            self.orderConfirmButton.isEnabled = true
            ProgressHUD.dismiss()
            print("Order Create...")
            print(json)
            if success {                
                ProgressHUD.showSuccessWithStatus("成功购买!")
                
                if self.cartIds != nil {
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.CART_ITEMS_REMOVE), object: nil)
                }
                self.profileUpdate()
            } else {
                let errors = json["errors"].dictionaryValue
                if let error = errors.values.first {
                    if let firstError =  error.arrayObject?.first as? String {
                        ProgressHUD.showErrorWithStatus(firstError)
                    } else {
                        ProgressHUD.showErrorWithStatus("失败购买.")
                    }
                } else {
                    ProgressHUD.showErrorWithStatus("失败购买.")
                }
            }
        }
    }
    
    private func profileUpdate() {
        AuthAPI.shared.profileGet(completion: { (json, success) in
            if success {
                UserInstance.userLoginSuccess(json["profile"])
                if UserInstance.loginName!.isEmpty {
                    //UserInstance.userLoginSuccess(json)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    ProgressHUD.dismiss()
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass)
                    var vcArray = self.navigationController?.viewControllers
                    vcArray?.removeLast()
                    vcArray?.append(vc)
                    self.navigationController?.setViewControllers(vcArray!, animated: false)
                })
            } else {
                // try again...
                AuthAPI.shared.profileGet(completion: { (json, success1) in
                    if success1 {
                        UserInstance.userLoginSuccess(json["profile"])
                        if UserInstance.loginName!.isEmpty {
                            //UserInstance.userLoginSuccess(json)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            ProgressHUD.dismiss()
                            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass)
                            var vcArray = self.navigationController?.viewControllers
                            vcArray?.removeLast()
                            vcArray?.append(vc)
                            self.navigationController?.setViewControllers(vcArray!, animated: false)
                        })
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            ProgressHUD.dismiss()
                            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass)
                            var vcArray = self.navigationController?.viewControllers
                            vcArray?.removeLast()
                            vcArray?.append(vc)
                            self.navigationController?.setViewControllers(vcArray!, animated: false)
                        })
                    }
                })
                
            }
        })
    }
    
    private func presentTransactionPass() {
        if UserInstance.guardPayment {
            self.transactionField.text = ""
            self.customTransactionView.snp.updateConstraints { (make) in
                make.centerY.equalTo(self.view.centerY)
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            self.showDarkView(true)
        } else {
            if UserDefaultsUtil.shared.getIsCheckPaymentPassword() {
                self.implementOrder()
            } else {
                UserDefaultsUtil.shared.setIsCheckPaymentPassword(true)
                self.presentAlert("交易密码设置", message: "你没有设置交易密码.\n 我们建议您设置交易密码.\n 你想立即设置交易密码吗？", completionOK: {
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
                    self.navigationController?.pushViewController(vc, animated: true)
                }, completionCancel: {
                    // call api...
                    self.implementOrder()
                })
            }            
        }
    }
    
    private func showDarkView(_ state: Bool) {
        if state {
            self.darkView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.8
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { (finished) in
                self.darkView.isHidden = true
            })
        }
    }
    
    private func hideCustomTransactionView() {
        self.transactionField.resignFirstResponder()
        customTransactionView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    private func showQrcodeView() {
        qrcodeView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func hideQrcodeView() {
        qrcodeView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    private func getDefaultContact() {
        if self.contacts.count < 1 {
            return
        }
        for contact in self.contacts {
            if contact.main {
                self.defaultContact = contact
            }
        }
        
        if defaultContact == nil {
            self.defaultContact = self.contacts.first!
        }
        
        self.tableView.reloadData()
    }
    
    func showCheckMark(selectedMethod: Int) {
        checkMarkList[oldSelectedMethod].isHidden = true
        checkMarkList[selectedMethod].isHidden = false
        oldSelectedMethod = selectedMethod
    }
    
    //custom pay view ...
    @IBAction func selectPaiPay(_ sender: UIButton) {
        
//        self.hideCustomPayView()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if self.cartIds == nil {
//                if (self.products.first?.qrimage)! != "" {
//                    self.presentOrderAlert()
//                } else {
//                    self.presentTransaction()
//                }
//            } else {
//                self.presentTransaction()
//            }
//        }
        showCheckMark(selectedMethod: 0)
        self.paymentType = 1
    }
    
    @IBAction func selectWeixinPay(_ sender: UIButton) {
        showCheckMark(selectedMethod: 2)
        self.paymentType = 1
    }
    
    @IBAction func selectPointPay(_ sender: UIButton) {
        showCheckMark(selectedMethod: 1)
        self.paymentType = 2
    }
    
    @IBAction func selectAliPay(_ sender: UIButton) {
        showCheckMark(selectedMethod: 3)
        self.paymentType = 2
    }
    
    @IBAction func hidePayMethodView(_ sender: UIButton) {
        self.hideCustomPayView()
        self.showDarkView(false)
    }
    
    @IBAction func goConfirmPayView(_ sender: Any) {
        if oldSelectedMethod == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentAlert("暂未开放!")
            }
        } else {
            self.hideCustomPayView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showConfirmPayView()
            }
        }
    }
    
    @IBAction func goTransationView(_ sender: UIButton) {
        self.hideConfirmPayView()
        if oldSelectedMethod == 0 || oldSelectedMethod == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.cartIds == nil {
                    if (self.products.first?.qrimage)! != "" {
                        self.presentOrderAlert()
                    } else {
                        self.presentTransaction()
                    }
                } else {
                    self.presentTransaction()
                }
            }
        } else if oldSelectedMethod == 3 {
            //self.presentAlert("Alipay!")
            self.aliGetOrder()
            //self.AliplayFunc()
        }
    }
    
    func aliGetOrder() {
        TRADE_NO = ""
        OUT_TRADE_NO = ""
        let itemString = self.getItemsString()
        let amountString = itemString + "|" + String(self.totalPrice)
        let credentialData = amountString.data(using: String.Encoding.utf8)!
        let amountBase64String = credentialData.base64EncodedString(options: [])
        print(amountString)
        print(amountBase64String)
        
        let parameters: Parameters = [
            "amount": amountBase64String
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.getAlipayOrder(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> json:\n", json)
                let orderString = json["result"] as! String
                print(orderString)
                self.showDarkView(false)
                self.AliplayFunc(orderString: orderString)
            } else {
                print("failure >>>> json:\n", json)
            }
        }
    }
    
    //h.g.n
    func AliplayFunc(orderString: String) {
        levelPayment = false
        let appScheme = "paishop"
        VCArray = self.navigationController?.viewControllers as NSArray?
        
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { resultDic in
            print(resultDic as Any)
            
            let result = (resultDic! as NSDictionary)
            let returnCode: String = result["resultStatus"] as! String
            //var returnMsg: String = result["memo"] as! String
            //var subResultMsg:String = ""
            switch  returnCode{
            case "6001":
                break
            case "8000":
                ProgressHUD.showErrorWithStatus("支付失败，请您重新支付！")
                break
            case "4000":
                ProgressHUD.showErrorWithStatus("支付失败，请您重新支付！")
                break
            case "9000":
                //支付返回信息：外系统订单号、内部系统订单号等信息
                //JSON.init(parseJSON: (result["result"] as! String))["alipay_trade_app_pay_response"]["sub_msg"].stringValue
                ProgressHUD.showSuccessWithStatus("支付成功")
                break
            default:
                break
            }
            
        })
        
    }
    
    @objc func createOrderProduct(_ notification: Notification) {
        if !(AlipayPaid) { return }
        AlipayPaid = false
        print("Alipay Success!")
        //ProgressHUD.showSuccessWithStatus("支付成功")
        
        let trade_no = TRADE_NO
        let out_trade_no = OUT_TRADE_NO
        let items = getItemsString() + "|trade_no:" + trade_no + "|out_trade_no:" + out_trade_no
        //let items = AliOrderItemString + "|trade_no:" + trade_no
        
        var parameters: [String : Any] = [
            "items" : items,
            "user_name" : self.defaultContact.name!,
            "address" : self.defaultContact.address!,
            "phone_number" : self.defaultContact.phoneNumber!,
            "currency" : self.paymentType
        ]
        if cartIds != nil {
            parameters["carts"] = cartIds
        }
        
        print("MyBuyVC:Order:", parameters)
        
        orderConfirmButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.wechatOrderCreate(params: parameters) { (json, success) in
            self.orderConfirmButton.isEnabled = true
            ProgressHUD.dismiss()
            print("Order Create...")
            print(json)
            if success {
                ProgressHUD.showSuccessWithStatus("支付已完成!                                                      请在代发货上查询订单")
                //AlipayPaid = false
                
                if self.cartIds != nil {
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.CART_ITEMS_REMOVE), object: nil)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    ProgressHUD.dismiss()
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass)
                    var vcArray = self.navigationController?.viewControllers
                    if vcArray != nil {
                        vcArray?.removeLast()
                        vcArray?.append(vc)
                        print(vcArray!)
                        self.navigationController?.setViewControllers(vcArray!, animated: false)
                    } else {
                        vcArray = VCArray as? [UIViewController]
                        vcArray?.removeLast()
                        vcArray?.removeLast()
                        vcArray?.append(vc)
                        print(vcArray!)
                        self.navigationController?.setViewControllers(vcArray!, animated: false)
                    }
                    
                })
                
            } else {
                print("failure >>>> json:\n", json)
            }
        }
    }
    
    func dateToStringYMD_HMS(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date as Date)
        
        return dateString
    }
    
    private func showCustomPayView() {
        self.customPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func hideCustomPayView() {
        self.customPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(315)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func goBackCustomPayView(_ sender: UIButton) {
        self.hideConfirmPayView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showCustomPayView()
        }
    }
    
    private func showConfirmPayView() {
        self.setupConfirmView()
        self.confirmPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        //self.showDarkView(true)
    }
    
    func setupConfirmView() {
        self.payMethodImgOfConfirmView.image = self.payImages[oldSelectedMethod]
        if oldSelectedMethod == 0 || oldSelectedMethod == 1 {
            let paiTotal = self.totalPrice / self.currencyRate
            self.finalPriceLabel.text = String.init(format: "%.2f", paiTotal) + "π"
        } else if oldSelectedMethod == 2 || oldSelectedMethod == 3 {
            self.finalPriceLabel.text = "¥" + String.init(format: "%.2f", self.totalPrice)
        }
    }
    
    private func hideConfirmPayView() {
        self.confirmPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(315)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    
}


extension MyBuyVC: NavBarDelegate {
    func didSelectBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension MyBuyVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return  2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: MyBuyContactCell = tableView.ts_dequeueReusableCell(MyBuyContactCell.self)
            cell.setCellContent(self)
            return cell
        } else {
            if self.paymentType == 1 {
                let cell: MyBuyPaiCell = tableView.ts_dequeueReusableCell(MyBuyPaiCell.self)
                cell.setCellContent(products[indexPath.row], row: indexPath.row, vc: self, count: productCounts[indexPath.row], currencyRate: currencyRate, restitutionRate: restitutionRate)
                return cell
            } else {
                let cell: MyBuyCell = tableView.ts_dequeueReusableCell(MyBuyCell.self)
                cell.setCellContent(products[indexPath.row], row: indexPath.row, vc: self, count: productCounts[indexPath.row])
                return cell
            }
            
        }
    }
    
    
}


















