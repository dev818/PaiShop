

import UIKit

class MyWalletWithdrawVC: UIViewController {
    
    var serverPaiAddress: String = ""
    var serverPaiPhone: String = ""
    
    @IBOutlet weak var calculBackView: UIView!
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var serverPaiAddressLabel: UILabel!
    @IBOutlet weak var serverMobileKeyLabel: UILabel!
    @IBOutlet weak var amountField: UITextField! {
        didSet {
            amountField.text = "100"
        }
    }
    
    @IBOutlet weak var amountField1: UITextField!
    @IBOutlet weak var myPaiLabel: UILabel!
    
    @IBOutlet weak var withdrawTotalLabel: UILabel!
    @IBOutlet weak var withdrawUnitLabel: UILabel!
    @IBOutlet weak var withdrawPaiButton: UIButton! {
        didSet {
            withdrawPaiButton.tag = 401
        }
    }
    @IBOutlet weak var withdrawCNYButton: UIButton! {
        didSet {
            withdrawCNYButton.tag = 402
        }
    }
    @IBOutlet var withdrawAmountButtons: [UIButton]! // tag: 301 - 306
    @IBOutlet weak var confirmWithdrawButton: RoundRectButton!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customTransactionView: UIView!
    @IBOutlet weak var transactionField: UITextField!
    @IBOutlet weak var withDrawTypeLabel: UILabel!
    @IBOutlet weak var withdrawAmountLabel: UILabel!
    
    
    var isSelectedPai = true
    var selectedAmountIndex = 2 // index - 1, 2, 3, 4, 5, 6
    var selectedTheme = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupCustomView()
        myPaiLabel.text = "余额 " + UserInstance.paiBalance! + "π"
        withdrawTotalLabel.text = UserInstance.paiBalance
        serverPaiAddressLabel.text = UserInstance.paiAddress
        serverMobileKeyLabel.text = String(UserInstance.mobileKey!)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "提派"
        navBar.setDefaultNav()
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        withDrawTypeLabel.textColor = MainColors.themeEndColors[selectedTheme]
        withdrawAmountLabel.textColor = MainColors.themeEndColors[selectedTheme]
        confirmWithdrawButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        withdrawPaiButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        for withdrawAmountButton in withdrawAmountButtons {
            if withdrawAmountButton.tag == 302 {
                withdrawAmountButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
            }
        }
    }
    
    private func setupCustomView() {
        
        self.calculBackView.dropShadow()
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
    }


    @IBAction func selectPai(_ sender: UIButton) {
        self.isSelectedPai = true
        self.amountField.text = "100"
        
        withdrawCNYButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
        withdrawCNYButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        
        withdrawPaiButton.setTitleColor(UIColor.white, for: .normal)
        withdrawPaiButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        for withdrawAmountButton in withdrawAmountButtons {
            switch withdrawAmountButton.tag {
            case 301:
                withdrawAmountButton.setTitle("50π", for: .normal)
            case 302:
                withdrawAmountButton.setTitle("100π", for: .normal)
            case 303:
                withdrawAmountButton.setTitle("150π", for: .normal)
            case 304:
                withdrawAmountButton.setTitle("200π", for: .normal)
            case 305:
                withdrawAmountButton.setTitle("250π", for: .normal)
            case 306:
                withdrawAmountButton.setTitle("300π", for: .normal)
            default:
                break
            }
        }
        self.resetAmountButtons()
    }
    
    @IBAction func selectCNY(_ sender: UIButton) {
        self.isSelectedPai = false
        self.amountField.text = "200"
        
        withdrawPaiButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
        withdrawPaiButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        
        withdrawCNYButton.setTitleColor(UIColor.white, for: .normal)
        withdrawCNYButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        for withdrawAmountButton in withdrawAmountButtons {
            switch withdrawAmountButton.tag {
            case 301:
                withdrawAmountButton.setTitle("100元", for: .normal)
            case 302:
                withdrawAmountButton.setTitle("200元", for: .normal)
            case 303:
                withdrawAmountButton.setTitle("300元", for: .normal)
            case 304:
                withdrawAmountButton.setTitle("400元", for: .normal)
            case 305:
                withdrawAmountButton.setTitle("500元", for: .normal)
            case 306:
                withdrawAmountButton.setTitle("600元", for: .normal)
            default:
                break
            }
        }
        self.resetAmountButtons()
    }
    
    @IBAction func selectAmount(_ sender: UIButton) {
        for withdrawAmountButton in withdrawAmountButtons {
            withdrawAmountButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
            withdrawAmountButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        }
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        switch sender.tag {
        case 301:
            selectedAmountIndex = 1
            if isSelectedPai {
                amountField.text = "50"
            } else {
                amountField.text = "100"
            }
        case 302:
            selectedAmountIndex = 2
            if isSelectedPai {
                amountField.text = "100"
            } else {
                amountField.text = "200"
            }
        case 303:
            selectedAmountIndex = 3
            if isSelectedPai {
                amountField.text = "150"
            } else {
                amountField.text = "300"
            }
        case 304:
            selectedAmountIndex = 4
            if isSelectedPai {
                amountField.text = "200"
            } else {
                amountField.text = "400"
            }
        case 305:
            selectedAmountIndex = 5
            if isSelectedPai {
                amountField.text = "250"
            } else {
                amountField.text = "500"
            }
        case 306:
            selectedAmountIndex = 6
            if isSelectedPai {
                amountField.text = "300"
            } else {
                amountField.text = "600"
            }
        default:
            break
        }
    }
    
    @IBAction func confirmWithdraw(_ sender: UIButton) { 
        let amount = amountField1.text!
        if amount.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入提现余额.")
            return
        }
        if amount == "0" {
            ProgressHUD.showWarningWithStatus("请输入提现余额.")
            return
        }
        
        if isSelectedPai {
            if Double(UserInstance.paiBalance!)! < Double(amount)! {
                ProgressHUD.showWarningWithStatus("你没有足够的余额.")
                return
            }
        } else {
            if Double(UserInstance.rmbBalance!)! < Double(amount)! {
                ProgressHUD.showWarningWithStatus("你没有足够的余额.")
                return
            }
        }
        
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
                self.implementWithdraw()
            } else {
                UserDefaultsUtil.shared.setIsCheckPaymentPassword(true)
                self.presentAlert("交易密码设置", message: "你没有设置交易密码.\n 我们建议您设置交易密码.\n 你想立即设置交易密码吗？", completionOK: {
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
                    self.navigationController?.pushViewController(vc, animated: true)
                }, completionCancel: {
                    //implement recharge...
                    self.implementWithdraw()
                })
            }            
        }
        
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
                //implement recharge...
                self.implementWithdraw()
            } else {
                // try again...
                MyAPI.shared.paymentPasswordVerify(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.hideCustomTransactionView()
                        self.implementWithdraw()
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
    
    @IBAction func closeCustomTransaction(_ sender: UIButton) {
        self.hideCustomTransactionView()
    }
    
    private func implementWithdraw() {
        let amount = Double(amountField1.text!)
        if amount == nil {
            ProgressHUD.showWarningWithStatus("请输入有效的充值余额.")
            return
        }
        
        let currency = isSelectedPai ? 1 : 2 // 1 - pai, 2 - CNY
        let type = false // withdraw
        
        let parameters: [String : Any] = [
            "amount" : amount!,
            "currency" : currency,
            "type" : type
        ]
        
        confirmWithdrawButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentCreate(params: parameters) { (json, success) in
            self.confirmWithdrawButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                print("Payment Create...")
                print(json)
                ProgressHUD.showSuccessWithStatus("请稍后正在确认...\n关注提示信息!")
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
        }
    }
    
    private func resetAmountButtons() {
        selectedAmountIndex = 2
        for withdrawAmountButton in withdrawAmountButtons {
            if withdrawAmountButton.tag == 302 {
                withdrawAmountButton.setTitleColor(UIColor.white, for: .normal)
                withdrawAmountButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
            } else {
                withdrawAmountButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
                withdrawAmountButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
            }
        }
        
        if isSelectedPai {
            myPaiLabel.text = "余额 " + UserInstance.paiBalance! + "π"
            withdrawTotalLabel.text = UserInstance.paiBalance
            withdrawUnitLabel.text = "π"
        } else {
            withdrawTotalLabel.text = UserInstance.rmbBalance
            withdrawUnitLabel.text = "元"
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
    

}


extension MyWalletWithdrawVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}














