

import UIKit
import BEMCheckBox
import DropDown

class MyUserInfoUpgradeVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gradeView: RoundRectView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var confirmUpgradeButton: RoundRectButton!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var treasurePeriodLabel: UILabel!
    @IBOutlet weak var treasureReturnLabel: UILabel!
    @IBOutlet weak var profitRatioLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.isHidden = true
        }
    }
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customTransactionView: UIView!
    @IBOutlet weak var transactionField: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.ts_registerCellNib(MyUserInfoUpgradeDegreeCell.self)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.ts_registerCellNib(MyUserInfoUpgradeCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeightConstraint.constant = 0
        }
    }
    
    @IBOutlet weak var confirmTransactionButtonBg: GradientView!
    
    
    var gradeDropDown: DropDown!
    var selectedDegree = 0
    
    var degrees: [DegreeModel] = []
    var degreeNames: [String] = []
    var releaseRate: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupCustomView()
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.profileDegree { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.scrollView.isHidden = false
                print("Profile Degree...")
                print(json)
                UserInstance.degreeId = json["degree"].intValue
                self.degrees = DegreeModel.getDegreesFromJson(json["degrees"])
                var degreeImageArray: [String] = []
                for i in 0..<self.degrees.count {
                    degreeImageArray.append(self.degrees[i].image!)
                    self.degreeNames.append("   " + self.degrees[i].name! + "   ")
                }
                UserDefaultsUtil.shared.setDegreeImageArray(degreeImageArray)
                self.setupUI()
            } else {
                // try again...
                MyAPI.shared.profileDegree(completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.scrollView.isHidden = false
                        UserInstance.degreeId = json["degree"].intValue
                        self.degrees = DegreeModel.getDegreesFromJson(json["degrees"])
                        var degreeImageArray: [String] = []
                        for i in 0..<self.degrees.count {
                            degreeImageArray.append(self.degrees[i].image!)
                            self.degreeNames.append("   " + self.degrees[i].name! + "   ")
                        }
                        UserDefaultsUtil.shared.setDegreeImageArray(degreeImageArray)
                        self.setupUI()
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

    private func setupNavBar() {
        navBar.lblTitle.text = "店铺升级"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        confirmUpgradeButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        confirmTransactionButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        confirmTransactionButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
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
    
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.restitutionRate != nil {
            self.releaseRate = appDelegate.restitutionRate
        } else {
            self.releaseRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        self.selectedDegree = UserInstance.degreeId! + 1
        if self.selectedDegree > degrees.count {
            self.selectedDegree = degrees.count
        }
        
        nameLabel.text = Utils.getNickName()
        
        gradeView.isUserInteractionEnabled = true
        let gradeViewTap = UITapGestureRecognizer(target: self, action: #selector(selectGradeView))
        gradeView.addGestureRecognizer(gradeViewTap)
        
        gradeDropDown = DropDown()
        gradeDropDown.anchorView = gradeView
        
        gradeDropDown.dataSource = degreeNames
        gradeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedDegree = index + 1
            self.updateFields()
            self.gradeDropDown.hide()
        }
        
        self.collectionView.reloadData()
        
        self.tableViewHeightConstraint.constant = CGFloat(degrees.count * 37)
        self.updateFields()
    }
    
    func updateFields() {
        gradeLabel.text = self.degreeNames[selectedDegree - 1]
        tableView.reloadData()
        priceLabel.text = "π" + String.init(format: "%.2f", degrees[selectedDegree - 1].fee!) 
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: Date())
        let daysToAdd = degrees[selectedDegree - 1].period!
        var dateComponent = DateComponents()
        dateComponent.day = daysToAdd
        let finishDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        let finishDateString = dateFormatter.string(from: finishDate!)
        periodLabel.text = startDateString + " ~ " + finishDateString
        
        introductionLabel.text = degrees[selectedDegree - 1].description
        profitRatioLabel.text = "\(degrees[selectedDegree - 1].profitRatio!)%"
        
        var periodIndex = 0
        let profitRatio = degrees[selectedDegree - 1].profitRatio!
        periodIndex = profitRatio
        if periodIndex < 0 {
            periodIndex = 0
        }
        
        var restitutionRate: Double = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.periodRatio != nil {
            restitutionRate = appDelegate.restitutionRate
        } else {
            restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        let periodDouble = Double(PAISHOP_PERIODS_TABLE[periodIndex - 1])! * 135 / restitutionRate
        
        let roundedPeriod = round(periodDouble)
        let period = Int(roundedPeriod)
        print("period:", period)
        treasurePeriodLabel.text = "\(period)"
        
        let serverReturn = degrees[selectedDegree - 1].fee! * releaseRate * Double(periodIndex) / (10000.0 * Double(period))
        treasureReturnLabel.text = String.init(format: "%.2f", serverReturn)
    }
    
    @IBAction func selectConfirm(_ sender: UIButton) {
        if self.selectedDegree <= UserInstance.degreeId! {
            ProgressHUD.showWarningWithStatus("你应该选择比当前更高的级别.")
            return
        }
        
        if UserInstance.guardPayment {
            self.transactionField.text = ""
            self.customTransactionView.snp.updateConstraints { (make) in
                make.centerY.equalTo(self.view.centerY)
            }
            UIView.animate(withDuration: 0.3, delay: 0, options:UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            self.showDarkView(true)
        } else {
            if UserDefaultsUtil.shared.getIsCheckPaymentPassword() {
                self.implementDegreeUpgrade()
            } else {
                UserDefaultsUtil.shared.setIsCheckPaymentPassword(true)
                self.presentAlert("交易密码设置", message: "你没有设置交易密码.\n 我们建议您设置交易密码.\n 你想立即设置交易密码吗？", completionOK: {
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
                    self.navigationController?.pushViewController(vc, animated: true)
                }, completionCancel: {
                    //implement recharge...
                    self.implementDegreeUpgrade()
                })
            }
        }
    }
    
    
    @objc func selectGradeView() {
        Utils.applyTouchEffect(gradeView)
        gradeDropDown.show()
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
                //implement degree upgrade...
                self.implementDegreeUpgrade()
            } else {
                // try again...
                MyAPI.shared.paymentPasswordVerify(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.hideCustomTransactionView()
                        self.implementDegreeUpgrade()
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
    
    private func implementDegreeUpgrade() {
        //check user balance here and return if not sufficient...
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : selectedDegree
        ]
        confirmUpgradeButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.profileDegreeUpdate(params: parameters) { (json, success) in
            self.confirmUpgradeButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                print("Profile Degree Update...")
                print(json)
                ProgressHUD.showSuccessWithStatus("成功升级")
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
    
    private func hideCustomTransactionView() {
        self.transactionField.resignFirstResponder()
        customTransactionView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options:UIView.AnimationOptions.curveEaseOut, animations: {
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


extension MyUserInfoUpgradeVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

















