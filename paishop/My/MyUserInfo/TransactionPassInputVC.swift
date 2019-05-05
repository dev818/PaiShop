

import UIKit

class TransactionPassInputVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassswordField: UITextField!
    
    @IBOutlet weak var setButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setTheme()
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "交易密码设置"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        setButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
    }
    
    @IBAction func confirmPassword(_ sender: UIButton) {
        if !validateFields() {
            return
        }
        
        let password = passwordField.text!
        
        self.view.endEditing(true)
        let parameters: [String : Any] = [
            "payment_password" : password
        ]
        MyAPI.shared.paymentPasswordChange(params: parameters) { (json, success) in
            if success {
                print("Payment Password Create...")
                print(json)
                ProgressHUD.showSuccessWithStatus("交易密码设置成功")
                UserInstance.guardPayment = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                // try again...
                MyAPI.shared.paymentPasswordChange(params: parameters, completion: { (json, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("交易密码设置成功")
                        UserInstance.guardPayment = true
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
    
    private func validateFields() -> Bool {
        let password = passwordField.text!
        let confirm = confirmPassswordField.text!
        
        if password.count < 4 {
            ProgressHUD.showErrorWithStatus("密码必须超过4个字符.")
            return false
        }
        
        if password != confirm {
            ProgressHUD.showErrorWithStatus("密码和确认密码不一样.")
            return false
        }
        
        return true
    }

}


extension TransactionPassInputVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}







