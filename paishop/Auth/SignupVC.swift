
import UIKit
import Alamofire
import SwiftyJSON
import BEMCheckBox


class SignupVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var verificationField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var sendCodeButton: SecurityCodeButton!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        phoneField.delegate = self
        verificationField.delegate = self
        passwordField.delegate = self
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "用户注册"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
        
    
    @IBAction func selectSendCode(_ sender: Any) {
        self.view.endEditing(true)
        let phoneNumber = phoneField.text!
        if phoneNumber.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入手机号码.")
        } else {
            sendCodeButton.withFormat("获取验证码", phone: phoneNumber, time: 60)
            sendCodeButton.isEnabled = false
            sendCodeButton.startTime()
            
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "reset_password": 0
            ]
            AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success) in
                if success {
                    self.sendCodeButton.isEnabled = true
                    //self.sendCodeButton.stopTime()
                    ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                } else {
                    // try again...
                    AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
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
    
    @IBAction func selectRegister(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        if validateRegisterFields() {
            let phoneNumber = phoneField.text!
            let verificationCode = verificationField.text!
            let password = passwordField.text!
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "password": password,
                "verify_code": verificationCode
            ]
            
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            AuthAPI.shared.register(params: parameters) { (json, success) in
                if success {
                    print("Register...")
                    print(json)
                    let token = json["access_token"].stringValue
                    UserInstance.password = password
                    UserInstance.accessToken = token
                    
                    if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                        self.registerDeviceToken(deviceToken, userJson: json["user"])
                    } else {
                        sender.isEnabled = true
                        ProgressHUD.dismiss()
                        ProgressHUD.showSuccessWithStatus("注册成功!")
                        UserInstance.userLoginSuccess(json["user"])
                        self.sendLoginSuccessNotification()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.dismiss(animated: true) {
                            }
                        })
                    }
                } else {
                    // try again...
                    AuthAPI.shared.register(params: parameters, completion: { (json, success1) in
                        if success1 {
                            let token = json["access_token"].stringValue
                            UserInstance.password = password
                            UserInstance.accessToken = token
                            if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                                self.registerDeviceToken(deviceToken, userJson: json["user"])
                            } else {
                                sender.isEnabled = true
                                ProgressHUD.dismiss()
                                ProgressHUD.showSuccessWithStatus("注册成功!")
                                UserInstance.userLoginSuccess(json["user"])
                                self.sendLoginSuccessNotification()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                    self.dismiss(animated: true) {
                                    }
                                })
                            }
                        } else {
                            ProgressHUD.dismiss()
                            sender.isEnabled = true
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("注册失败.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("注册失败.")
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func registerDeviceToken(_ token: String, userJson: JSON) {
        print("Token to register...", token)
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let parameters: [String: Any] = [
            "token" : token,
            "system" : true,
            "version" : currentVersion,
            ]
        AuthAPI.shared.deviceToken(params: parameters) { (json, success) in
            if success {
                self.signupButton.isEnabled = true
                ProgressHUD.dismiss()
                print("Register Device Token Success...")
                ProgressHUD.showSuccessWithStatus("注册成功!")
                UserInstance.userLoginSuccess(userJson)
                self.sendLoginSuccessNotification()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.dismiss(animated: true) {
                    }
                })
            } else {
                // try again...
                AuthAPI.shared.deviceToken(params: parameters, completion: { (json, success1) in
                    self.signupButton.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("注册成功!")
                        UserInstance.userLoginSuccess(userJson)
                        self.sendLoginSuccessNotification()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.dismiss(animated: true) {
                            }
                        })
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("注册失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("注册失败.")
                        }
                    }
                })
            }
        }
    }
    
    private func sendLoginSuccessNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGIN_APPLICATION), object: nil)
    }
    
    private func validateRegisterFields() -> Bool {
        let phoneNumber = phoneField.text!
        let verificationCode = verificationField.text!
        let password = passwordField.text!
        
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return false
        } else if verificationCode.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入验证码.")
            return false
        } else if password.count < 6 {
            ProgressHUD.showErrorWithStatus("密码必须至少6个字符.")
            return false
        }
        return true
    }
    
}


extension SignupVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if textField == phoneField {
            return newLength <= 11
        } else if textField == verificationField {
            return newLength <= 6
        } else if textField == passwordField {
            return newLength <= 50
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordField {
            self.view.endEditing(true)
        }
        return true
    }
    
}


extension SignupVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


/*
class SignupVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var verificationField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var sendCodeButton: SecurityCodeButton!
    @IBOutlet weak var lookButton: UIButton!
    @IBOutlet weak var lookImageView: UIImageView!
    @IBOutlet weak var signupButton: UIButton! {
        didSet {
            signupButton.isEnabled = false
            signupButton.setTitleColor(UIColor.darkGray, for: .normal)
            signupButton.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var backBuuttonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var nameImageView: UIImageView!
    @IBOutlet weak var verifyImageView: UIImageView!
    @IBOutlet weak var passwordImageView: UIImageView!
    
    
    
    
    var isPasswordSecure = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTheme()
        
        phoneField.delegate = self
        verificationField.delegate = self
        passwordField.delegate = self
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        bgImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        nameImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        verifyImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        passwordImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        sendCodeButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
    }
    
    private func setupUI() {
        backImageView.setTintColor(UIColor.white)
        if Utils.isIphoneX() {
            backBuuttonTopConstraint.constant = 28 + 24
        }
        
        checkBox.boxType = .square
        checkBox.delegate = self
        
        
    }
    
    @IBAction func selectServiceIntro(_ sender: UIButton) {
        /*let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: AboutUsVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)*/
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
        vc.urlString = API.WEB_LINK + "/aboutus"
        vc.navBarTitle = "服务介绍"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func selectSendCode(_ sender: Any) {
        self.view.endEditing(true)
        let phoneNumber = phoneField.text!
        if phoneNumber.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入手机号码.")
        } else {
            sendCodeButton.withFormat("验证码", phone: phoneNumber, time: 60)
            sendCodeButton.isEnabled = false
            sendCodeButton.startTime()
            
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "reset_password": 0
            ]
            AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success) in
                if success {
                    self.sendCodeButton.isEnabled = true
                    //self.sendCodeButton.stopTime()
                    ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                } else {
                    // try again...
                    AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
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
    
    @IBAction func changeLook(_ sender: Any) {
        self.isPasswordSecure = !self.isPasswordSecure
        if self.isPasswordSecure {
            lookImageView.image = ImageAsset.auth_eye.image
            passwordField.isSecureTextEntry = true
        } else {
            lookImageView.image = ImageAsset.auth_eye_show.image
            passwordField.isSecureTextEntry = false
        }
    }
    
    @IBAction func selectRegister(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        if validateRegisterFields() {
            let phoneNumber = phoneField.text!
            let verificationCode = verificationField.text!
            let password = passwordField.text!
            let parameters: Parameters = [
                //"name": userName,
                "phone_number": phoneNumber,
                //"email": "admin@gmail.com",
                "password": password,
                "verify_code": verificationCode
            ]
            
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            AuthAPI.shared.register(params: parameters) { (json, success) in
                if success {
                    print("Register...")
                    print(json)
                    let token = json["access_token"].stringValue
                    UserInstance.password = password
                    UserInstance.accessToken = token
                    
                    if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                        self.registerDeviceToken(deviceToken, userJson: json["user"])
                    } else {
                        sender.isEnabled = true
                        ProgressHUD.dismiss()
                        ProgressHUD.showSuccessWithStatus("注册成功!")
                        UserInstance.userLoginSuccess(json["user"])
                        self.sendLoginSuccessNotification()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.dismiss(animated: true) {
                            }
                        })
                    }
                } else {
                    // try again...
                    AuthAPI.shared.register(params: parameters, completion: { (json, success1) in
                        if success1 {
                            let token = json["access_token"].stringValue
                            UserInstance.password = password
                            UserInstance.accessToken = token
                            if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                                self.registerDeviceToken(deviceToken, userJson: json["user"])
                            } else {
                                sender.isEnabled = true
                                ProgressHUD.dismiss()
                                ProgressHUD.showSuccessWithStatus("注册成功!")
                                UserInstance.userLoginSuccess(json["user"])
                                self.sendLoginSuccessNotification()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                    self.dismiss(animated: true) {
                                    }
                                })
                            }
                        } else {
                            ProgressHUD.dismiss()
                            sender.isEnabled = true
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("注册失败.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("注册失败.")
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func registerDeviceToken(_ token: String, userJson: JSON) {
        print("Token to register...", token)
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let parameters: [String: Any] = [
            "token" : token,
            "system" : true,
            "version" : currentVersion,
        ]
        AuthAPI.shared.deviceToken(params: parameters) { (json, success) in
            if success {
                self.signupButton.isEnabled = true
                ProgressHUD.dismiss()
                print("Register Device Token Success...")
                ProgressHUD.showSuccessWithStatus("注册成功!")
                UserInstance.userLoginSuccess(userJson)
                self.sendLoginSuccessNotification()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    self.dismiss(animated: true) {
                    }
                })
            } else {
                // try again...
                AuthAPI.shared.deviceToken(params: parameters, completion: { (json, success1) in
                    self.signupButton.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("注册成功!")
                        UserInstance.userLoginSuccess(userJson)
                        self.sendLoginSuccessNotification()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            self.dismiss(animated: true) {
                            }
                        })
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("注册失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("注册失败.")
                        }
                    }
                })
            }
        }
    }
    
    private func sendLoginSuccessNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGIN_APPLICATION), object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func selectBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func validateRegisterFields() -> Bool {
        let phoneNumber = phoneField.text!
        let verificationCode = verificationField.text!
        let password = passwordField.text!
        
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return false
        } else if verificationCode.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入验证码.")
            return false
        } else if password.count < 6 {
            ProgressHUD.showErrorWithStatus("密码必须至少6个字符.")
            return false
        }
        return true
    }
    
}



extension SignupVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        if textField == phoneField {
            return newLength <= 11
        } else if textField == verificationField {
            return newLength <= 6
        } else if textField == passwordField {
            return newLength <= 50
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordField {
            self.view.endEditing(true)
        }
        return true
    }
    
}


extension SignupVC: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox.on {
            signupButton.isEnabled = true
            signupButton.setTitleColor(UIColor.white, for: .normal)
            signupButton.backgroundColor = UIColor.init(colorWithHexValue: 0x299ae9)
        } else {
            signupButton.isEnabled = false
            signupButton.setTitleColor(UIColor.darkGray, for: .normal)
            signupButton.backgroundColor = UIColor.lightGray
        }
    }
}

*/









