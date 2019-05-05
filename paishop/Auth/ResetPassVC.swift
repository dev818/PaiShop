
import UIKit
import Alamofire

class ResetPassVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var confirmPassField: UITextField!
    
    @IBOutlet weak var doneButton: RoundRectButton!
    
    var phoneNumber: String!
    var token: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        passField.delegate = self
        confirmPassField.delegate = self
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        doneButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "重设密码"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @IBAction func selectDone(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        if validateFields() {
            let password = passField.text!
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "password": password,
                "token": token
            ]
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            AuthAPI.shared.resetPassword(params: parameters, completion: { (json, success) in
                if success {
                    ProgressHUD.dismiss()
                    sender.isEnabled = true
                    ProgressHUD.showSuccessWithStatus("重置密码成功.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                } else {
                    // try again...
                    AuthAPI.shared.resetPassword(params: parameters, completion: { (json, success1) in
                        ProgressHUD.dismiss()
                        sender.isEnabled = true
                        if success1 {
                            ProgressHUD.showSuccessWithStatus("重置密码成功.")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                self.navigationController?.popToRootViewController(animated: true)
                            })
                        } else {
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("重置密码失败.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("重置密码失败.")
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    private func validateFields() -> Bool {
        let password = passField.text!
        let confirmPassword = confirmPassField.text!
        if password.count < 6 {
            ProgressHUD.showErrorWithStatus("密码必须至少6个字符.")
            return false
        } else if password != confirmPassword {
            ProgressHUD.showErrorWithStatus("两次密码输入不一致.")
            return false
        }
        return true
    }

}



extension ResetPassVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 50
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passField {
            confirmPassField.becomeFirstResponder()
        } else if textField == confirmPassField {
            self.view.endEditing(true)
        }
        return true
    }
}



extension ResetPassVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}















