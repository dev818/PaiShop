

import UIKit

class MyWalletPointConvertVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.ts_registerCellNib(MyWalletPointConvertCell.self)
        }
    }
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointValueLabel: UILabel!
    @IBOutlet weak var confirmPointConvertButton: RoundRectButton!
    
    @IBOutlet var customTransactionView: UIView!
    @IBOutlet weak var transactionField: UITextField!
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    
    var pointExchangeList: [String] = []
    var selectedAmountIndex = -1
    let sectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupCustomView()
        self.pointValueLabel.text = UserInstance.point
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.pointExchange.count > 0 {
            self.pointExchangeList = appDelegate.pointExchange
        } else {
            self.pointExchangeList = UserDefaultsUtil.shared.getPointExchange()
        }
        
        var numberOfColumns = pointExchangeList.count / 3
        let temp = pointExchangeList.count % 3
        if temp > 0 {
            numberOfColumns += 1
        }
        collectionViewHeightConstraint.constant = CGFloat(32 * numberOfColumns + 16 * (numberOfColumns - 1))
        
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "积分转π"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupCustomView() {
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
    
    
    @IBAction func confirmPointConvert(_ sender: UIButton) {
        if selectedAmountIndex < 0 {
            ProgressHUD.showWarningWithStatus("请选择转换数量.")
            return
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
                self.implementPointConvert()
            } else {
                UserDefaultsUtil.shared.setIsCheckPaymentPassword(true)
                self.presentAlert("交易密码设置", message: "你没有设置交易密码.\n 我们建议您设置交易密码.\n 你想立即设置交易密码吗？", completionOK: {
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
                    self.navigationController?.pushViewController(vc, animated: true)
                }, completionCancel: {
                    //implement recharge...
                    self.implementPointConvert()
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
                self.implementPointConvert()
            } else {
                // try again...
                MyAPI.shared.paymentPasswordVerify(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.hideCustomTransactionView()
                        self.implementPointConvert()
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
    
    private func implementPointConvert() {
        if selectedAmountIndex < 0 {
            ProgressHUD.showWarningWithStatus("请选择转换数量.")
            return
        }
        let amount = pointExchangeList[selectedAmountIndex]
        
        let parameters: [String : Any] = [
            "amount" : amount
        ]
        confirmPointConvertButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentExchange(params: parameters) { (json, success) in
            self.confirmPointConvertButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                ProgressHUD.showSuccessWithStatus("成功")
                self.profileUpdate()
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
    
    private func profileUpdate() {
        AuthAPI.shared.profileGet(completion: { (json, success) in
            if success {
                UserInstance.userLoginSuccess(json["profile"])
                if UserInstance.loginName!.isEmpty {
                    //UserInstance.userLoginSuccess(json)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    ProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
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
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            ProgressHUD.dismiss()
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                })
            }
        })
    }

}


extension MyWalletPointConvertVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pointExchangeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyWalletPointConvertCell = collectionView.ts_dequeueReusableCell(MyWalletPointConvertCell.self, forIndexPath: indexPath)
        cell.setCellContent(selectedAmountIndex, row: indexPath.row, parentVC: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (3 + 1)
        let availableWidth = (view.frame.width - 48) - paddingSpace - 8
        let widthPerItem = availableWidth / 3
        
        return CGSize(width: widthPerItem, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}




extension MyWalletPointConvertVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
















