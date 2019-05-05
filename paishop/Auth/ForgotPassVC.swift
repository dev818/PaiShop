

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var verificationField: UITextField!
    @IBOutlet weak var sendCodeButton: SecurityCodeButton!
    
    @IBOutlet weak var nextButton: RoundRectButton!
    
    
    var token: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        phoneField.delegate = self
        verificationField.delegate = self
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        sendCodeButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        nextButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
    }

    
    private func setupNavBar() {
        navBar.lblTitle.text = "忘记密码"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @IBAction func selectSendCode(_ sender: Any) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        let phoneNumber = phoneField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
        } else {
            sendCodeButton.withFormat("验证码", phone: phoneNumber, time: 60)
            sendCodeButton.isEnabled = false
            sendCodeButton.startTime()
            
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "reset_password": 1
            ]
            ProgressHUD.showWithStatus()
            AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success) in
                if success {
                    ProgressHUD.dismiss()
                    self.sendCodeButton.isEnabled = true
                    //self.sendCodeButton.stopTime()
                    ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                } else {
                    // try again...
                    AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
                        ProgressHUD.dismiss()
                        self.sendCodeButton.isEnabled = true
                        //self.sendCodeButton.stopTime()
                        if success1 {
                            ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                        } else {
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("获取验证码失败.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("获取验证码失败.")
                            }
                        }
                    })
                }
            })
        }
    }
    
    
    @IBAction func selectNext(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        if validateFields() {
            let phoneNumber = phoneField.text!
            let verification = verificationField.text!
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "verify_code": verification
            ]
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            AuthAPI.shared.forgorPassword(params: parameters, completion: { (json, success) in
                if success {
                    ProgressHUD.dismiss()
                    sender.isEnabled = true
                    self.token = json["token"].stringValue
                    if self.token.count > 10 {
                        self.performSegue(withIdentifier: ResetPassVC.nameOfClass, sender: self)
                    }
                } else {
                    // try again...
                    AuthAPI.shared.forgorPassword(params: parameters, completion: { (json, success1) in
                        ProgressHUD.dismiss()
                        sender.isEnabled = true
                        if success1 {
                            self.token = json["token"].stringValue
                            if self.token.count > 10 {
                                self.performSegue(withIdentifier: ResetPassVC.nameOfClass, sender: self)
                            }
                        } else {
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("出了些问题.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("出了些问题.")
                            }
                        }
                    })
                }
            })
        }
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ResetPassVC.nameOfClass {
            let resetPassVC = segue.destination as! ResetPassVC
            resetPassVC.phoneNumber = phoneField.text!
            resetPassVC.token = self.token
        }
    }
    
    
    private func validateFields() -> Bool {
        let phoneNumber = phoneField.text!
        let verification = verificationField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return false
        } else if verification.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入验证码.")
            return false
        }
        return true
    }
    

}




extension ForgotPassVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if textField == phoneField {
            return newLength <= 11
        } else if textField == verificationField {
            return newLength <= 6
        }
        return true
    }
}


extension ForgotPassVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}









