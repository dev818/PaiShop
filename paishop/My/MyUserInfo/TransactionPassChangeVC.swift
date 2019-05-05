

import UIKit

class TransactionPassChangeVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var currentPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!    
    @IBOutlet weak var changeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setTheme()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "交易密码修改"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        changeButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
    }

    @IBAction func confirmPassword(_ sender: UIButton) {
        if !validateFields() {
            return
        }
        
        let currentPass = currentPassField.text!
        let newPass = newPassField.text!
        
        self.view.endEditing(true)
        let parameters: [String : Any] = [
            "current_password" : currentPass,
            "payment_password" : newPass
        ]
        MyAPI.shared.paymentPasswordChange(params: parameters) { (json, success) in
            if success {
                print("Payment Password Change...")
                print(json)
                ProgressHUD.showSuccessWithStatus("交易密码已成功更改")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                // try again...
                MyAPI.shared.paymentPasswordChange(params: parameters, completion: { (json, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("交易密码已成功更改")
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
        let currentPass = currentPassField.text!
        let newPass = newPassField.text!
        let confirmPass = confirmPassField.text!
        
        if currentPass.count < 4 {
            ProgressHUD.showErrorWithStatus("请输入有效当前密码.")
            return false
        }
        if newPass.count < 4 {
            ProgressHUD.showErrorWithStatus("请输入有效新密码.")
            return false
        }
        if newPass != confirmPass {
            ProgressHUD.showErrorWithStatus("密码和确认密码不一样.")
            return false
        }
        return true
    }

}

extension TransactionPassChangeVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


























