
import UIKit
import ESTabBarController_swift



class MainTabVC: ESTabBarController {
    
    var launchImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTabBar()
        
        self.setupLaunchImageView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveTab(_:)), name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeDidLoad(_:)), name: NSNotification.Name(Notifications.HOME_DID_LOAD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeDidLoad(_:)), name: NSNotification.Name(Notifications.APPLICATION_WILL_ENTER_FOREGROUND), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openTicket(_:)), name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveOrderPush(_:)), name: NSNotification.Name(Notifications.PUSH_ORDER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processDeepLink(_:)), name: NSNotification.Name(Notifications.DEEP_LINK), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openProductDetail(_:)), name: NSNotification.Name(Notifications.PUSH_NEW_ITEM), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openPayment(_:)), name: NSNotification.Name(Notifications.PUSH_PAYMENT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(versionUpdate(_:)), name: NSNotification.Name(Notifications.VERSION_UPDATE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLogoutPush(_:)), name: NSNotification.Name(Notifications.PUSH_LOGOUT), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeTheme), name: NSNotification.Name(Notifications.CHANGE_THEME), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openChat(_:)), name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Constants.SCREEN_WIDTH = self.view.frame.width
        //Constants.SCREEN_HEIGHT = self.view.frame.height
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func moveTab(_ notification: NSNotification) {
        if let tab = notification.userInfo?["tab"] as? Int {
            self.selectedIndex = tab
        } else {
            self.selectedIndex = 0
        }
    }
    
    @objc func receiveLogoutPush(_ notification: NSNotification) {
        HomeAPI.shared.tokenCheck { (json, success) in
            if success {
                print("Token Check...")
                print(json)
            } else {
                self.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: false)
                UserInstance.userLogout()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ProgressHUD.showWarningWithStatus("您是从其他设备登录的!")
                }
            }
        }
    }
    
    @objc func versionUpdate(_ notification: NSNotification) {
        guard let versionUrl = notification.userInfo?["versionUrl"] as? String else { return }
        self.presentAlert("你想更新版本吗?", completionOK: {
            UIApplication.shared.open(URL.init(string: versionUrl)!, options: [:], completionHandler: nil)
        }) {
            //dismiss...
        }
    }
    
    @objc func homeDidLoad(_ notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            UIView.animate(withDuration: 1, animations: {
                self.launchImageView.alpha = 0.0
            }, completion: { (success) in
                self.launchImageView.isHidden = true
            })
        })
    }
    
    @objc func openTicket(_ notification: NSNotification) {
        guard let type = notification.userInfo?["type"] as? String else { return }
        if type == "openTicket" {
            print("Open ticket Push receive...")
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyHelpCenterVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        }        
    }
        
    @objc func receiveOrderPush(_ notification: NSNotification) {
        guard let orderId = notification.userInfo?["orderId"] as? Int64 else { return }
        if orderId > 0 {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderDetailVC.nameOfClass) as! MyStoreOrderDetailVC
            vc.orderId = orderId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func openProductDetail(_ notification: NSNotification) {
        guard let productId = notification.userInfo?["productId"] as? Int64 else { return }
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = productId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openPayment(_ notification: NSNotification) {
        guard let paymentId = notification.userInfo?["paymentId"] as? Int else { return }
        let parameters: [String : Any] = [
            "id" : paymentId
        ]
        MyAPI.shared.paymentDetail(params: parameters) { (json, success) in
            if success {
                DispatchQueue.main.async {
                    let paymentDetail = PaymentListModel.init(json["payment"])
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletRechargeDetailVC.nameOfClass) as! MyWalletRechargeDetailVC
                    vc.paymentDetail = paymentDetail
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                // try again...                
                MyAPI.shared.paymentDetail(params: parameters, completion: { (json, success1) in
                    if success1 {
                        DispatchQueue.main.async {
                            let paymentDetail = PaymentListModel.init(json["payment"])
                            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletRechargeDetailVC.nameOfClass) as! MyWalletRechargeDetailVC
                            vc.paymentDetail = paymentDetail
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                })
            }
        }
        
    }
    
    @objc func processDeepLink(_ notification: NSNotification) {
        guard let type = notification.userInfo?["type"] as? String else { return }
        guard let index = notification.userInfo?["index"] as? Int64 else { return }
        if type == "store" {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = index
            self.navigationController?.pushViewController(vc, animated: true)
        } else if type == "product" {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = index
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func changeTheme() {
        self.initTabBar()
    }
    
    @objc func openChat(_ notification: NSNotification) {
        guard let type = notification.userInfo?["type"] as? String else { return }
        if type == "openChat" {
            print("Open Chat Push receive...")
            let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: SocialVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setupLaunchImageView() {
        launchImageView = UIImageView()
        //launchImageView.contentMode = UIViewContentMode.scaleToFill
        self.view.addSubview(launchImageView)
        launchImageView.backgroundColor = UIColor.white
        launchImageView.translatesAutoresizingMaskIntoConstraints = false
        launchImageView.ts_height = UIScreen.ts_height
        launchImageView.ts_width = UIScreen.ts_width
        launchImageView.center = self.view.center
        launchImageView.contentMode = .scaleAspectFit
        self.view.layoutIfNeeded()
        
        let randomNumber = random(3)
        switch randomNumber {
        case 0:
            launchImageView.image = ImageAsset.splash_1.image.ts_resize(CGSize.init(width: UIScreen.ts_width, height: UIScreen.ts_height))
        case 1:
            launchImageView.image = ImageAsset.splash_1.image.ts_resize(CGSize.init(width: UIScreen.ts_width, height: UIScreen.ts_height))
        case 2:
            launchImageView.image = ImageAsset.splash_1.image.ts_resize(CGSize.init(width: UIScreen.ts_width, height: UIScreen.ts_height))
        default:
            launchImageView.image = ImageAsset.splash.image.ts_resize(CGSize.init(width: UIScreen.ts_width, height: UIScreen.ts_height))
        }        
        
    }
    
    func random(_ n:Int) -> Int
    {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    private func initTabBar() {
        /*self.tabBar.barTintColor = UIColor.white
        self.tabBar.isTranslucent = true
        let selectedColor   = UIColor.red
        let unselectedColor = UIColor.darkGray
        
        // Change tab bar text color
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: unselectedColor, NSAttributedStringKey.font: UIFont.init(name: "Helvetica", size: 12)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedColor, NSAttributedStringKey.font: UIFont.init(name: "Helvetica", size: 12)!], for: .selected)
        
        //change tab bar icon color
        self.tabBar.unselectedItemTintColor = UIColor.init(colorWithHexValue: 0x505051)
        self.tabBar.tintColor = UIColor.lightGray
        
        //set tab bar background 
        let layerGradient = CAGradientLayer()
        layerGradient.colors = [UIColor.init(colorWithHexValue: 0xddecf7).cgColor, UIColor.init(colorWithHexValue: 0xf1cbcc).cgColor]
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        self.tabBar.layer.addSublayer(layerGradient)*/
        
    
        /**** Background Change Tab Bar ***/
 /*
        if let tabBar = self.tabBar as? ESTabBar {
            if Utils.isIphoneX() {
                tabBar.itemCustomPositioning = ESTabBarItemPositioning.centered
            } else {
                tabBar.itemCustomPositioning = .fillIncludeSeparator
            }
        }
        
        let homeVC = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()
        let guideVC = UIStoryboard(name: "Guide", bundle: nil).instantiateInitialViewController()
        let socialVC = UIStoryboard(name: "Social", bundle: nil).instantiateInitialViewController()
        let shoppingCartVC = UIStoryboard(name: "ShoppingCart", bundle: nil).instantiateInitialViewController()
        let myVC = UIStoryboard(name: "My", bundle: nil).instantiateInitialViewController()
        
        homeVC?.tabBarItem = ESTabBarItem.init(HighlightableTabContentView(), title: "首页", image: UIImage(named: "tab_home"), selectedImage: UIImage(named: "tab_home"))
        guideVC?.tabBarItem = ESTabBarItem.init(HighlightableTabContentView(), title: "指南", image: UIImage(named: "tab_guide"), selectedImage: UIImage(named: "tab_guide"))
        socialVC?.tabBarItem = ESTabBarItem.init(HighlightableTabContentView(), title: "社交", image: UIImage(named: "tab_social"), selectedImage: UIImage(named: "tab_social"))
        shoppingCartVC?.tabBarItem = ESTabBarItem.init(HighlightableTabContentView(), title: "游戏", image: UIImage(named: "tab_game"), selectedImage: UIImage(named: "tab_game"))
        myVC?.tabBarItem = ESTabBarItem.init(HighlightableTabContentView(), title: "我的", image: UIImage(named: "tab_my"), selectedImage: UIImage(named: "tab_my"))
 */
        
        
        let tab1VC = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()
        let tab2VC = UIStoryboard(name: "Categories", bundle: nil).instantiateInitialViewController()
        let tab3VC = UIStoryboard(name: "Find", bundle: nil).instantiateInitialViewController()
        let tab4VC = UIStoryboard(name: "Nearby", bundle: nil).instantiateInitialViewController()
        let tab5VC = UIStoryboard(name: "My", bundle: nil).instantiateInitialViewController()
        
        tab1VC?.tabBarItem = ESTabBarItem.init(BouncesTabContentView(), title: "首页", image: UIImage(named: "tab_home"), selectedImage: UIImage(named: "tab_home"))
        tab2VC?.tabBarItem = ESTabBarItem.init(BouncesTabContentView(), title: "分类", image: UIImage(named: "tab_category"), selectedImage: UIImage(named: "tab_category"))
        tab3VC?.tabBarItem = ESTabBarItem.init(BouncesTabContentView(), title: "发现", image: UIImage(named: "tab_find"), selectedImage: UIImage(named: "tab_find"))
        tab4VC?.tabBarItem = ESTabBarItem.init(BouncesTabContentView(), title: "周边", image: UIImage(named: "tab_nearby"), selectedImage: UIImage(named: "tab_nearby"))
        tab5VC?.tabBarItem = ESTabBarItem.init(BouncesTabContentView(), title: "我的", image: UIImage(named: "tab_my"), selectedImage: UIImage(named: "tab_my"))
        
        
        self.viewControllers = [
            tab1VC!,
            tab2VC!,
            tab3VC!,
            tab4VC!,
            tab5VC!,
        ]
        
        
    }
    
    

}
