

import UIKit
import Kingfisher
import SDWebImage

class MySettingVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piNameLabel: UILabel!
    
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    
    @IBOutlet weak var currentVersionLabel: UILabel! {
        didSet {
            currentVersionLabel.text = ""
        }
    }
    @IBOutlet weak var latestVersionLabel: UILabel! {
        didSet {
            latestVersionLabel.text = ""
        }
    }
    @IBOutlet weak var versionUpdateButton: RoundRectButton! {
        didSet {
            versionUpdateButton.backgroundColor = UIColor.init(colorWithHexValue: 0xF2F1F1)
            versionUpdateButton.setTitleColor(UIColor.lightGray, for: .normal)
            versionUpdateButton.isEnabled = false
        }
    }
    @IBOutlet weak var cacheDeleteButton: RoundRectButton!
    
    @IBOutlet weak var logoutButtonBg: GradientView!
    
    
    var iosVersion: String!
    var iosUrl: String!
    var selectedTheme = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        setupTheme()
        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: NSNotification.Name(Notifications.CHANGE_THEME), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "设置"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        notificationSwitch.onTintColor = MainColors.themeEndColors[selectedTheme]
        cacheDeleteButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
        logoutButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        logoutButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.iosVersion != nil {
            self.iosVersion = appDelegate.iosVersion
        } else {
            self.iosVersion = UserDefaultsUtil.shared.getIosVersion()
        }
        if appDelegate.iosUrl != nil {
            self.iosUrl = appDelegate.iosUrl
        } else {
            self.iosUrl = UserDefaultsUtil.shared.getIosUrl()
        }
        
        if UserDefaultsUtil.shared.getDeviceSound() {
            notificationSwitch.setOn(true, animated: true)
        } else {
            notificationSwitch.setOn(false, animated: true)
        }
        
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        currentVersionLabel.text = currentVersion
        if iosVersion != nil {
            latestVersionLabel.text = "最新版本: " + iosVersion
            
            if Double(iosVersion)! > Double(currentVersion)! {
                versionUpdateButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
                versionUpdateButton.setTitleColor(UIColor.white, for: .normal)
                versionUpdateButton.isEnabled = true
            }
        } else {
            latestVersionLabel.isHidden = true
        }
        
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        nameLabel.text = UserInstance.nickname
        piNameLabel.text = "π账号：" + UserInstance.paiAddress!
    }
    
    @IBAction func selectProfile(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectBuyContact(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactManageVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectTransactionPass(_ sender: UIButton) {
        if UserInstance.guardPayment {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassChangeVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectThemeChange(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyThemeSettingVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectAboutUs(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: AboutUsVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func selectVersionUpdate(_ sender: UIButton) {
        //go to version update url
        UIApplication.shared.open(URL.init(string: iosUrl)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func selectCacheDelete(_ sender: UIButton) {
        ProgressHUD.showWithStatus()
        cacheDeleteButton.isEnabled = false
        cacheDeleteButton.backgroundColor = UIColor.init(colorWithHexValue: 0xF2F1F1)
        cacheDeleteButton.setTitleColor(UIColor.lightGray, for: .normal)

        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        //KingfisherManager.shared.cache.clearDiskCache()
        //KingfisherManager.shared.cache.clearMemoryCache()
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                ProgressHUD.dismiss()
            })
        }
    }
    
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        self.deviceSound(sender.isOn)
    }
    
    @IBAction func selectLogout(_ sender: UIButton) {
        ProgressHUD.showWithStatus()
        let parameters: [String : Any] = [
            "token" : UserInstance.deviceToken!
        ]
        AuthAPI.shared.logout(params: parameters) { (success) in
            ProgressHUD.dismiss()
            UserInstance.userLogout()
            
            let tab: [String : Any] = ["tab" : 0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil, userInfo: tab)
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGOUT_APPLICATION), object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navigationController?.popViewController(animated: true)
            }
            
            
            if success {
                print("Logout......")
            }
        }
        
        
    }
    
    @objc func changeTheme() {
        navBar.setTheme()
        self.setupTheme()
    }
    
    
        
    private func deviceSound(_ status: Bool) {
        let parameters: [String : Any] = [
            "token" : UserInstance.deviceToken!,
            "sound" : status
        ]
        ProgressHUD.showWithStatus()
        MyAPI.shared.deviceSound(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                ProgressHUD.showSuccessWithStatus("成功改变了通知声音")
                UserDefaultsUtil.shared.setDeviceSound(status)
            } else {
                //try again...
                MyAPI.shared.deviceSound(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功改变了通知声音")
                        UserDefaultsUtil.shared.setDeviceSound(status)
                    } else {
                        self.notificationSwitch.setOn(!status, animated: true)
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
    

}


extension MySettingVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}













