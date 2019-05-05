
import UIKit
import Alamofire
import SwiftyJSON


class LoginVC: UIViewController {
    
    var isChangeTab = true
    
    @IBOutlet weak var topBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discoveryButton: UIButton!
    @IBOutlet weak var piButton: UIButton!
    @IBOutlet weak var discoveryButtonTriangle: UIImageView! {
        didSet {
            discoveryButtonTriangle.isHidden = true
        }
    }
    @IBOutlet weak var piButtonTriangle: UIImageView!
    @IBOutlet weak var nameImage: UIImageView! {
        didSet {
            nameImage.setTintColor(MainColors.defaultContent)
        }
    }
    @IBOutlet weak var nameField: UITextField! {
        didSet {
            nameField.delegate = self
        }
    }
    @IBOutlet weak var passwordField: UITextField! {
        didSet {
            passwordField.delegate = self
        }
    }
    @IBOutlet weak var loginButton: RoundButton!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customPhoneView: UIView!
    @IBOutlet weak var customPhoneField: UITextField! {
        didSet {
            customPhoneField.delegate = self
        }
    }
    @IBOutlet weak var customVerifyCodeField: UITextField! {
        didSet {
            customVerifyCodeField.delegate = self
        }
    }
    @IBOutlet weak var verifyCodeButton: SecurityCodeButton!
    @IBOutlet weak var registerFrame: UIView!
    
    
    var isPasswordSecure = true
    var isSelectedDiscovery = false
    var paiPhone: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        selectToDiscovery()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupUI() {
        if Utils.isIphoneX() {
            topBgHeightConstraint.constant = 150 + 24
        }
        
        self.view.addSubview(customPhoneView)
        customPhoneView.translatesAutoresizingMaskIntoConstraints = false
        customPhoneView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(270)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
    }
    
    
    @IBAction func selectClose(_ sender: UIButton) {
        
        if UserInstance.referee_id == 0 {
            UserInstance.userLogout()
        }
        
        if isChangeTab {
            let tab: [String : Any] = ["tab" : 0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil, userInfo: tab)
            self.dismiss(animated: true) { }
        } else {
            self.dismiss(animated: true) { }
        }
    }
    
    @IBAction func selectDiscovery(_ sender: UIButton) {
        self.selectToDiscovery()
    }
    
    private func selectToDiscovery() {
        discoveryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        piButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        discoveryButtonTriangle.isHidden = false
        piButtonTriangle.isHidden = true
        nameImage.image = UIImage(named: "auth_login_name")
        nameImage.setTintColor(MainColors.defaultContent)
        registerFrame.isHidden = true
        
        if !isSelectedDiscovery {
            self.nameField.text = ""
            self.passwordField.text = ""
        }
        self.isSelectedDiscovery = true
        self.nameField.placeholder = "请输入DISCOVERY用户名"
        self.nameField.keyboardType = .default
        self.view.endEditing(true)
    }
    
    @IBAction func selectPi(_ sender: UIButton) {
        self.selectToPi()
    }
    
    private func selectToPi() {
        discoveryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        piButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        discoveryButtonTriangle.isHidden = true
        piButtonTriangle.isHidden = false
        nameImage.image = UIImage(named: "ic_auth_phone")
        registerFrame.isHidden = false
        
        if isSelectedDiscovery {
            self.nameField.text = ""
            self.passwordField.text = ""
        }
        self.isSelectedDiscovery = false
        self.nameField.placeholder = "请输入手机号"
        self.nameField.keyboardType = .phonePad
        self.view.endEditing(true)
    }
    
    @IBAction func selectPasswordShow(_ sender: UIButton) {
        self.isPasswordSecure = !self.isPasswordSecure
        if isPasswordSecure {
            //lookImageView.image = ImageAsset.auth_eye.image
            passwordField.isSecureTextEntry = true
        } else {
            //lookImageView.image = ImageAsset.auth_eye_show.image
            passwordField.isSecureTextEntry = false
        }
    }
    
    @IBAction func selectRegister(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: SignupVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectForgot(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: ForgotPassVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectLogin(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        
        if !self.validateLoginFields() {
            return
        }
        
        let phoneNumber = nameField.text!
        let password = passwordField.text!
        
        self.loginButton.isEnabled = false
        ProgressHUD.showWithStatus()
        if isSelectedDiscovery {
            self.processPaiLogin(paiName: phoneNumber, password: password)
        } else {
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "password": password
            ]
            self.processGeneralLogin(parameters)
        }
    }
    
    @IBAction func selectIntro(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
        vc.urlString = API.WEB_LINK + "/aboutus"
        vc.navBarTitle = "服务介绍"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectWeixin(_ sender: UIButton) {
    }
    
    @IBAction func selectQQ(_ sender: UIButton) {
    }
    
    
    
    @IBAction func selectSendVerifyCode(_ sender: Any) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        let phoneNumber = customPhoneField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return
        }
        
        verifyCodeButton.withFormat("验证码", phone: phoneNumber, time: 60)
        verifyCodeButton.startTime()
        
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "reset_password": 2
        ]
        verifyCodeButton.isEnabled = false
        ProgressHUD.showWithStatus()
        AuthAPI.shared.sendVerifyCode(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.verifyCodeButton.isEnabled = true
                //self.sendCodeButton.stopTime()
                ProgressHUD.showSuccessWithStatus("获取验证码成功.")
            } else {
                //try again...
                AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                    } else {
                        self.verifyCodeButton.stopTime()
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
        }
    }
    
    @IBAction func selectCustomConfirm(_ sender: UIButton)  {
        if !validateCustomPhoneFields() {
            return
        }
        
        //process register
        self.processPaiRegister(sender)
        
    }
    
    @IBAction func selectCustomClose(_ sender: Any) {
        self.hideCustomPhoneView()
    }
    
    private func processPaiLogin(paiName: String, password: String) {
        let parameters: [String: Any] = [
            "username": paiName,
            "password": password
        ]
        
        AuthAPI.shared.paiLogin(params: parameters) { (json, success) in
            if success {
                let loginSuccess = json["success"].boolValue
                if loginSuccess {
                    let mobile = json["data"]["user"]["mobile"].stringValue
                    let indexLast4 = mobile.index(mobile.endIndex, offsetBy: -4)
                    self.paiPhone = String(mobile[indexLast4...])
                    print("pai_phone...",  self.paiPhone)
                    
                    let params: [String: Any] = [
                        "pai_name": paiName,
                        "password": password,
                        "pai_address": paiName,
                        "pai_phone": self.paiPhone
                    ]
                    self.processGeneralLogin(params)
                    
                } else {
                    self.loginButton.isEnabled = true
                    ProgressHUD.dismiss()
                    let msg = json["msg"].stringValue
                    if msg == "" {
                        ProgressHUD.showErrorWithStatus("登录失败.")
                    } else {
                        ProgressHUD.showErrorWithStatus(msg)
                    }
                    
                }
            } else {
                self.loginButton.isEnabled = true
                ProgressHUD.dismiss()
                ProgressHUD.showErrorWithStatus("登录失败.")
            }
        }
    }
    
    private func processGeneralLogin(_ parameters: [String: Any]) {
        AuthAPI.shared.login(params: parameters, completion: { (json, success) in
            if success {
                print("Login.........")
                print(json)
                
                let token = json["access_token"].stringValue
                //print("Access Token", token)
                UserInstance.password = parameters["password"] as? String
                UserInstance.accessToken = token
                
                if self.isSelectedDiscovery && token == "" {
                    self.loginButton.isEnabled = true
                    ProgressHUD.dismiss()
                    self.showCustomPhoneView()
                } else {
                    if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                        self.registerDeviceToken(deviceToken, userJson: json["user"])
                    } else {
                        self.loginButton.isEnabled = true
                        ProgressHUD.dismiss()
                        self.processLoginSuccess(json["user"])
                    }
                }
                
            } else {
                // try again...
                AuthAPI.shared.login(params: parameters, completion: { (json, success1) in
                    if success1 {
                        let token = json["access_token"].stringValue
                        UserInstance.password = parameters["password"] as? String
                        UserInstance.accessToken = token
                        
                        if self.isSelectedDiscovery && token == "" {
                            self.loginButton.isEnabled = true
                            ProgressHUD.dismiss()
                            self.showCustomPhoneView()
                        } else {
                            if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                                self.registerDeviceToken(deviceToken, userJson: json["user"])
                            } else {
                                self.loginButton.isEnabled = true
                                ProgressHUD.dismiss()
                                self.processLoginSuccess(json["user"])
                            }
                        }
                        
                    } else {
                        self.loginButton.isEnabled = true
                        ProgressHUD.dismiss()
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("登录失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败.")
                        }
                    }
                })
            }
        })
    }
    
    private func registerDeviceToken(_ token: String, userJson: JSON) {
        print("Token to register...", token)
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let parameters: [String: Any] = [
            "token" : token,
            "system" : true,
            "version": currentVersion,
            ]
        AuthAPI.shared.deviceToken(params: parameters) { (json, success) in
            if success {
                self.loginButton.isEnabled = true
                ProgressHUD.dismiss()
                print("Register Device Token Success...")
                self.processLoginSuccess(userJson)
            } else {
                // try again...
                AuthAPI.shared.deviceToken(params: parameters, completion: { (json, success1) in
                    self.loginButton.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.processLoginSuccess(userJson)
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("登录失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败.")
                        }
                    }
                })
            }
        }
    }
    
    private func processLoginSuccess(_ json: JSON) {
        UserInstance.userLoginSuccess(json)
        print(UserInstance.loginName!)
        if UserInstance.referee_id == 0 {
            //UserInstance.userLogout()
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass) as! MyUserInfoEditVC
            //vc.isFromPaiLogin = true
            //vc.loginJson = json
            self.navigationController?.pushViewController(vc, animated: true)
        } else if isSelectedDiscovery && UserInstance.loginName!.count < 6 {
            UserInstance.userLogout()
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass) as! MyUserInfoEditVC
            vc.isFromPaiLogin = true
            vc.loginJson = json
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.sendLoginSuccessNotification()
            ProgressHUD.showSuccessWithStatus("登录成功!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.dismiss(animated: true) { }
            })
        }
    }
    
    private func sendLoginSuccessNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGIN_APPLICATION), object: nil)
    }
    
    private func validateLoginFields() -> Bool {
        let phoneNumber = nameField.text!
        let password = passwordField.text!
        
        if isSelectedDiscovery {
            if phoneNumber.count < 1 {
                ProgressHUD.showErrorWithStatus("请输入商户名称.")
                return false
            } else if password.count < 1 {
                ProgressHUD.showErrorWithStatus("请输入密码.")
                return false
            }
            return true
        } else {
            if phoneNumber.count < 11 {
                ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
                return false
            } else if password.count < 6{
                ProgressHUD.showErrorWithStatus("密码必须至少6个字符.")
                return false
            }
            return true
        }
    }
    
    private func hideCustomPhoneView() {
        self.view.endEditing(true)
        customPhoneView.snp.updateConstraints { (make) in
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
    
    private func showCustomPhoneView() {
        self.view.endEditing(true)
        self.customPhoneField.text = UserInstance.loginName
        self.customVerifyCodeField.text = ""
        
        self.customPhoneView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
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
    
    private func validateCustomPhoneFields() -> Bool {
        let phoneNumber = customPhoneField.text!
        let verification = customVerifyCodeField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return false
        } else if verification.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入验证码.")
            return false
        }
        return true
    }
    
    private func processPaiRegister(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let phoneNumber = customPhoneField.text!
        let paiName = nameField.text!
        let password = passwordField.text!
        let verificationCode = customVerifyCodeField.text!
        
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "password": password,
            "verify_code": verificationCode,
            "pai_name": paiName,
            "pai_phone": self.paiPhone
        ]
        
        print("Pai Register parameters..........", parameters)
        
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
                    ProgressHUD.showSuccessWithStatus("登录成功!")
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
                            ProgressHUD.showSuccessWithStatus("登录成功!")
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
                                ProgressHUD.showErrorWithStatus("登录失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败.")
                        }
                    }
                })
            }
        }
    }
    
}


extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if textField == nameField && !isSelectedDiscovery {
            return newLength <= 11
        } else if textField == passwordField {
            return newLength <= 50
        } else if textField == customPhoneField {
            return newLength <= 11
        } else if textField == customVerifyCodeField {
            return newLength <= 6
        }
        return true
    }
}



/*
class LoginVC: UIViewController {
    
    var isChangeTab = true
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var lookButton: UIButton!
    @IBOutlet weak var lookImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var discoveryButton: UIButton!
    @IBOutlet weak var piButton: UIButton!
    @IBOutlet weak var registerFrame: UIView!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customPhoneView: UIView!
    @IBOutlet weak var customPhoneField: UITextField! {
        didSet {
            customPhoneField.delegate = self
        }
    }
    @IBOutlet weak var customVerifyCodeField: UITextField! {
        didSet {
            customVerifyCodeField.delegate = self
        }
    }
    @IBOutlet weak var verifyCodeButton: SecurityCodeButton!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var loginImageView: UIImageView!
    @IBOutlet weak var passImageView: UIImageView!
    @IBOutlet weak var verifyConfirmButton: RoundRectButton!
    
    
    
    var isPasswordSecure = true
    var isSelectedDiscovery = false
    var paiPhone: String!
    var selectedTheme = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.delegate = self
        passField.delegate = self
        
        nameField.text = ""//"13000000003"//piaoyanhong0515
        passField.text = ""//"password" //080909
        
        changeToDiscovery()
        
        self.setupCustomView()
        self.setupTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupTheme() {
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        headerView.backgroundColor = MainColors.themeEndColors[selectedTheme]
        piButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        piButton.setTitleColor(UIColor.init(colorWithHexValue: 0xF2F1F1), for: .normal)
        discoveryButton.backgroundColor = UIColor.init(colorWithHexValue: 0xF2F1F1)
        discoveryButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        loginImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        passImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        loginButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        verifyCodeButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        verifyConfirmButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
    }
    
    private func changeToDiscovery() {
        discoveryButton.backgroundColor = UIColor.init(colorWithHexValue: 0xF2F1F1)
        discoveryButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        
        piButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        piButton.setTitleColor(UIColor.init(colorWithHexValue: 0xF2F1F1), for: .normal)
        
        registerFrame.isHidden = true
        
        if !isSelectedDiscovery {
            self.nameField.text = ""
            self.passField.text = ""
        }
        self.isSelectedDiscovery = true
        self.nameField.placeholder = "请输入DISCOVERY用户名"
        self.nameField.keyboardType = .default
        self.view.endEditing(true)
    }
    
    private func setupCustomView() {
        self.view.addSubview(customPhoneView)
        customPhoneView.translatesAutoresizingMaskIntoConstraints = false
        customPhoneView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(270)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
    }
    
    private func changeToPi() {
        piButton.backgroundColor = UIColor.init(colorWithHexValue: 0xF2F1F1)
        piButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        
        discoveryButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        discoveryButton.setTitleColor(UIColor.init(colorWithHexValue: 0xF2F1F1), for: .normal)
        
        registerFrame.isHidden = false
        
        if isSelectedDiscovery {
            self.nameField.text = ""
            self.passField.text = ""
        }
        self.isSelectedDiscovery = false
        self.nameField.placeholder = "请输入手机号"
        self.nameField.keyboardType = .phonePad
        self.view.endEditing(true)
    }
    
    @IBAction func selectDiscovery(_ sender: UIButton) {
        self.changeToDiscovery()
    }
    
    @IBAction func selectPi(_ sender: UIButton) {
        self.changeToPi()
    }
    
    
    @IBAction func selectClose(_ sender: Any) {
        if isChangeTab {
            let tab: [String : Any] = ["tab" : 0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil, userInfo: tab)
            self.dismiss(animated: true) { }
        } else {
            self.dismiss(animated: true) { }
        }
        
    }
    
    @IBAction func changeLook(_ sender: Any) {
        self.isPasswordSecure = !self.isPasswordSecure
        if isPasswordSecure {
            lookImageView.image = ImageAsset.auth_eye.image
            passField.isSecureTextEntry = true
        } else {
            lookImageView.image = ImageAsset.auth_eye_show.image
            passField.isSecureTextEntry = false
        }
    }
    
    @IBAction func selectLogin(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        
        if !self.validateLoginFields() {
            return
        }
        
        let phoneNumber = nameField.text!
        let password = passField.text!
        
        self.loginButton.isEnabled = false
        ProgressHUD.showWithStatus()
        if isSelectedDiscovery {
            self.processPaiLogin(paiName: phoneNumber, password: password)
        } else {
            let parameters: Parameters = [
                "phone_number": phoneNumber,
                "password": password
            ]
            self.processGeneralLogin(parameters)
        }
        
    }
    
    private func processPaiLogin(paiName: String, password: String) {
        let parameters: [String: Any] = [
            "username": paiName,
            "password": password
        ]
        
        AuthAPI.shared.paiLogin(params: parameters) { (json, success) in
            if success {
                let loginSuccess = json["success"].boolValue
                if loginSuccess {
                    let mobile = json["data"]["user"]["mobile"].stringValue
                    let indexLast4 = mobile.index(mobile.endIndex, offsetBy: -4)
                    self.paiPhone = String(mobile[indexLast4...])
                    print("pai_phone...",  self.paiPhone)
                    
                    let params: [String: Any] = [
                        "pai_name": paiName,
                        "password": password,
                        "pai_address": paiName,
                        "pai_phone": self.paiPhone
                    ]
                    self.processGeneralLogin(params)
                    
                } else {
                    self.loginButton.isEnabled = true
                    ProgressHUD.dismiss()
                    let msg = json["msg"].stringValue
                    if msg == "" {
                        ProgressHUD.showErrorWithStatus("登录失败.")
                    } else {
                        ProgressHUD.showErrorWithStatus(msg)
                    }
                    
                }
            } else {
                self.loginButton.isEnabled = true
                ProgressHUD.dismiss()
                ProgressHUD.showErrorWithStatus("登录失败.")
            }
        }
        
    }
    
    private func processGeneralLogin(_ parameters: [String: Any]) {
        AuthAPI.shared.login(params: parameters, completion: { (json, success) in
            if success {
                print("Login.........")
                print(json)
                
                let token = json["access_token"].stringValue
                //print("Access Token", token)
                UserInstance.password = parameters["password"] as? String
                UserInstance.accessToken = token
                
                if self.isSelectedDiscovery && token == "" {
                    self.loginButton.isEnabled = true
                    ProgressHUD.dismiss()
                    self.showCustomPhoneView()
                } else {
                    if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                        self.registerDeviceToken(deviceToken, userJson: json["user"])
                    } else {
                        self.loginButton.isEnabled = true
                        ProgressHUD.dismiss()
                        self.processLoginSuccess(json["user"])
                    }
                }
                
            } else {
                // try again...
                AuthAPI.shared.login(params: parameters, completion: { (json, success1) in
                    if success1 {
                        let token = json["access_token"].stringValue
                        UserInstance.password = parameters["password"] as? String
                        UserInstance.accessToken = token
                        
                        if self.isSelectedDiscovery && token == "" {
                            self.loginButton.isEnabled = true
                            ProgressHUD.dismiss()
                            self.showCustomPhoneView()
                        } else {
                            if let deviceToken = UserInstance.deviceToken, !deviceToken.isEmpty {
                                self.registerDeviceToken(deviceToken, userJson: json["user"])
                            } else {
                                self.loginButton.isEnabled = true
                                ProgressHUD.dismiss()
                                self.processLoginSuccess(json["user"])
                            }
                        }
                        
                    } else {
                        self.loginButton.isEnabled = true
                        ProgressHUD.dismiss()
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("登录失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败.")
                        }
                    }
                })
            }
        })
    }
    
    
    private func registerDeviceToken(_ token: String, userJson: JSON) {
        print("Token to register...", token)
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let parameters: [String: Any] = [
            "token" : token,
            "system" : true,
            "version": currentVersion,
        ]
        AuthAPI.shared.deviceToken(params: parameters) { (json, success) in
            if success {
                self.loginButton.isEnabled = true
                ProgressHUD.dismiss()
                print("Register Device Token Success...")
                self.processLoginSuccess(userJson)
            } else {
                // try again...
                AuthAPI.shared.deviceToken(params: parameters, completion: { (json, success1) in
                    self.loginButton.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.processLoginSuccess(userJson)
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("登录失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败.")
                        }
                    }
                })
            }            
        }
    }
    
    private func processLoginSuccess(_ json: JSON) {
        UserInstance.userLoginSuccess(json)
        if isSelectedDiscovery && UserInstance.loginName!.count < 6 {
            UserInstance.userLogout()
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass) as! MyUserInfoEditVC
            vc.isFromPaiLogin = true
            vc.loginJson = json
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.sendLoginSuccessNotification()
            ProgressHUD.showSuccessWithStatus("登录成功!")            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.dismiss(animated: true) { }
            })
        }
    }
    
    private func sendLoginSuccessNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGIN_APPLICATION), object: nil)
    }
    
    @IBAction func selectSignup(_ sender: Any) {
        self.performSegue(withIdentifier: SignupVC.nameOfClass, sender: self)
    }
    
    @IBAction func selectForgot(_ sender: Any) {
        self.performSegue(withIdentifier: ForgotPassVC.nameOfClass, sender: self)
    }
    
    
    private func validateLoginFields() -> Bool {
        let phoneNumber = nameField.text!
        let password = passField.text!
        
        if isSelectedDiscovery {
            if phoneNumber.count < 1 {
                ProgressHUD.showErrorWithStatus("请输入商户名称.")
                return false
            } else if password.count < 1 {
                ProgressHUD.showErrorWithStatus("请输入密码.")
                return false
            }
            return true
        } else {
            if phoneNumber.count < 11 {
                ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
                return false
            } else if password.count < 6{
                ProgressHUD.showErrorWithStatus("密码必须至少6个字符.")
                return false
            }
            return true
        }
    }
    
    
    
    
    
    @IBAction func selectSendVerifyCode(_ sender: Any) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        let phoneNumber = customPhoneField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return
        }
        
        verifyCodeButton.withFormat("验证码", phone: phoneNumber, time: 60)
        verifyCodeButton.startTime()
        
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "reset_password": 2
        ]
        verifyCodeButton.isEnabled = false
        ProgressHUD.showWithStatus()
        AuthAPI.shared.sendVerifyCode(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.verifyCodeButton.isEnabled = true
                //self.sendCodeButton.stopTime()
                ProgressHUD.showSuccessWithStatus("获取验证码成功.")
            } else {
                //try again...
                AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                    } else {
                        self.verifyCodeButton.stopTime()
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
        }
    }
    
    @IBAction func selectCustomConfirm(_ sender: UIButton)  {
        if !validateCustomPhoneFields() {
            return
        }
        
        //process register
        self.processPaiRegister(sender)
        
    }
    
    @IBAction func selectCustomClose(_ sender: Any) {
        self.hideCustomPhoneView()
    }
    
    private func hideCustomPhoneView() {
        self.view.endEditing(true)
        customPhoneView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    private func showCustomPhoneView() {
        self.view.endEditing(true)
        self.customPhoneField.text = UserInstance.loginName
        self.customVerifyCodeField.text = ""
        
        self.customPhoneView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
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
    
    private func validateCustomPhoneFields() -> Bool {
        let phoneNumber = customPhoneField.text!
        let verification = customVerifyCodeField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return false
        } else if verification.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入验证码.")
            return false
        }
        return true
    }
    
    private func processPaiRegister(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let phoneNumber = customPhoneField.text!
        let paiName = nameField.text!
        let password = passField.text!
        let verificationCode = customVerifyCodeField.text!
        
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "password": password,
            "verify_code": verificationCode,
            "pai_name": paiName,
            "pai_phone": self.paiPhone
        ]
        
        print("Pai Register parameters..........", parameters)
        
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
                    ProgressHUD.showSuccessWithStatus("登录成功!")
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
                            ProgressHUD.showSuccessWithStatus("登录成功!")
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
                                ProgressHUD.showErrorWithStatus("登录失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("登录失败.")
                        }
                    }
                })
            }
        }
        
    }
    
    
    
}



extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if textField == nameField && !isSelectedDiscovery {
            return newLength <= 11
        } else if textField == passField {
            return newLength <= 50
        } else if textField == customPhoneField {
            return newLength <= 11
        } else if textField == customVerifyCodeField {
            return newLength <= 6
        }
        return true
    }
}

*/















