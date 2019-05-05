

import UIKit
import AssistantKit

class MyVC: UIViewController {
    
    @IBOutlet weak var statusView: GradientView!    
    @IBOutlet weak var headerView: GradientView!
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var paiLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var navButton1: UIButton!
    @IBOutlet weak var navButton2: UIButton!
    @IBOutlet weak var navButton3: UIButton!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(MyVCOrderCell.self)
            tableView.ts_registerCellNib(MyVCWalletCell.self)
            //tableView.ts_registerCellNib(MyVCStoreCell.self)
            tableView.ts_registerCellNib(MyVCAddCell.self)
            tableView.ts_registerCellNib(MyVCToolCell.self)
            tableView.ts_registerCellNib(MyVCRecommendCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 65
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var contentFrame: RoundRectView!
    
    
    var notificationLists: [NotificationListModel] = []
    var itemRecommends: [ItemRecommendModel] = []
    var allItemRecms: [ItemRecommendModel] = []
    var nTotal = 0
    var nAll = 0
    
    var timer: Timer!
    var currentPage = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecommends()
        
    }
    
    deinit {        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTheme()
        self.showUI(false)
        if UserInstance.isLogin {
            self.showUI(true)
            if !NetworkUtil.isReachable() {
                ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
                return
            }
            ProgressHUD.showWithStatus()
            AuthAPI.shared.profileGet(completion: { (json, success) in
                if success {
                    ProgressHUD.dismiss()
                    UserInstance.userLoginSuccess(json["profile"])
                    /*if UserInstance.loginName!.isEmpty {
                        UserInstance.userLoginSuccess(json)
                    }*/
                    print("Profile Get...")
                    print(json)
                    DispatchQueue.main.async {
                        self.setupUI()
                    }
                } else {
                    // try again...
                    AuthAPI.shared.profileGet(completion: { (json, success1) in
                        ProgressHUD.dismiss()
                        if success1 {
                            UserInstance.userLoginSuccess(json["profile"])
                            if UserInstance.loginName!.isEmpty {
                                //UserInstance.userLoginSuccess(json)
                            }
                            DispatchQueue.main.async {
                                self.setupUI()
                            }
                        } else {
                            self.showUI(false)
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("无法获取您的个人资料.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("无法获取您的个人资料.")
                            }
                        }
                    })
                    
                }
            })
            
            loadNotificationLists()
            
        } else {
            self.showUI(false)
            self.goToLoginVC()
        }
    }
    
    private func loadNotificationLists() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.notificationList { (json, success) in
            if success {
                self.notificationLists = NotificationListModel.getNotificationListsFromJson(json["notifications"])
                if self.notificationLists.count > 0 {
                    self.notificationLists.insert(self.notificationLists.last!, at: 0)
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData { }
                })
            } else {
                //load again...
                HomeAPI.shared.notificationList(completion: { (json1, success1) in
                    if success1 {
                        self.notificationLists = NotificationListModel.getNotificationListsFromJson(json1["notifications"])
                        if self.notificationLists.count > 0 {
                            self.notificationLists.insert(self.notificationLists.last!, at: 0)
                        }
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData { }
                        })
                    }
                })
            }
        }
    }
    
    //h.g.n
    @objc func cellBtnTapped(_ sender: Any?) {
        
        loadPartOfRecms(nFirst: self.nAll)
    }
    
    //h.g.n
    func loadPartOfRecms(nFirst: Int) {
        if self.nTotal <= 15 {
            return
        } else {
            self.itemRecommends = []
            var nLast = nFirst + 15
            if nLast >= self.nTotal {
                nLast = self.nTotal
            }
            for j in nFirst..<nLast {
                self.itemRecommends.append(self.allItemRecms[j])
                self.nAll += 1
            }
            if self.nAll >= nTotal {
                self.nAll = 0
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.ts_reloadData { }
            })
        }
    }
    
    private func loadRecommends() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.itemRecommend { (json, success) in //Recommends
            if success {
                print("Recommends...")
                print(json)
                //self.storeRecommends = StoreRecommendModel.getStoreRecommendsFromJson(json["stores"])
                self.itemRecommends = ItemRecommendModel.getItemRecommendsFromJson(json["items"])
                //h.g.n
//                self.allItemRecms = ItemRecommendModel.getItemRecommendsFromJson(json["items"])
//                self.nTotal = self.allItemRecms.count
//
//                if self.nTotal <= 15 {
//                    self.itemRecommends = self.allItemRecms
//                    DispatchQueue.main.async(execute: {
//                        self.tableView.ts_reloadData { }
//                    })
//                } else {
//                    self.loadPartOfRecms(nFirst: self.nAll)
//                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData { }
                })
            } else {
                HomeAPI.shared.itemRecommend (completion: { (json1, success1) in //Recommends
                    if success1 {
                        //self.storeRecommends = StoreRecommendModel.getStoreRecommendsFromJson(json1["stores"])
                        self.itemRecommends = ItemRecommendModel.getItemRecommendsFromJson(json1["items"])
                        //h.g.n
//                        self.allItemRecms = ItemRecommendModel.getItemRecommendsFromJson(json1["items"])
//                        self.nTotal = self.allItemRecms.count
//
//                        if self.nTotal <= 15 {
//                            self.itemRecommends = self.allItemRecms
//                            DispatchQueue.main.async(execute: {
//                                self.tableView.ts_reloadData { }
//                            })
//                        } else {
//                            self.loadPartOfRecms(nFirst: self.nAll)
//                        }
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData { }
                        })
                    }
                })
            }
        }
    }
    
    
    
    private func setupUI() {
        self.nameLabel.text = Utils.getNickName()
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.paiLabel.text = "π:" + UserInstance.paiBalance!
        // h.g.n
        let point = Double(UserInstance.point!)
        let point_exchange30 = Double(UserInstance.poinr_exchange30!)
        let jifen: Double = point! + point_exchange30!
        //self.pointLabel.text = "π积分:" + String(format:"%.2f", jifen)
        self.pointLabel.text = "π积分:" + UserInstance.point!
                
        self.tableView.reloadData()
        
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        headerView.startColor = MainColors.themeStartColors[selectedTheme]
        headerView.endColor = MainColors.themeEndColors[selectedTheme]
        statusView.startColor = MainColors.themeStartColors[selectedTheme]
        statusView.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    
    @IBAction func selectAvatar(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectNavButton1(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MySettingVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectNavButton2(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyHelpCenterVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectNavButton3(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyThemeSettingVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func handleLogout() {
        ProgressHUD.showWithStatus()
        let parameters: [String : Any] = [
            "token" : UserInstance.deviceToken!
        ]
        AuthAPI.shared.logout(params: parameters) { (success) in
            if success {
                print("Logout......")
            }
        }
        UserInstance.userLogout()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ProgressHUD.dismiss()
            let tab: [String : Any] = ["tab" : 0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil, userInfo: tab)
        }
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGOUT_APPLICATION), object: nil)
    }
    
    private func showUI(_ show: Bool) {
        self.statusView.isHidden = !show
        self.headerView.isHidden = !show
        self.contentFrame.isHidden = !show
        
        if !show {
            //self.tableView.scrollToTopAnimated(false)
        }
    }
    
    private func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
    
}



extension MyVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell: MyVCOrderCell = tableView.ts_dequeueReusableCell(MyVCOrderCell.self)
            cell.setCellContent(self)
            return cell
        case 1:
            let cell: MyVCWalletCell = tableView.ts_dequeueReusableCell(MyVCWalletCell.self)
            cell.setCellContent(self, notifications: notificationLists)
            return cell
//        case 2:
//            let cell: MyVCStoreCell = tableView.ts_dequeueReusableCell(MyVCStoreCell.self)
//            cell.setCellContent(self)
//            return cell
        case 2:
            let cell: MyVCAddCell = tableView.ts_dequeueReusableCell(MyVCAddCell.self)
            cell.setCellContent(self)
            return cell
        case 3:
            let cell: MyVCToolCell = tableView.ts_dequeueReusableCell(MyVCToolCell.self)
            cell.setCellContent(self)
            return cell
        case 4:
            let cell: MyVCRecommendCell = tableView.ts_dequeueReusableCell(MyVCRecommendCell.self)
            cell.setCellContent(self, items: itemRecommends)
            cell.loadRecmButton.addTarget(self, action: #selector(MyVC.cellBtnTapped(_:)), for: .touchUpInside)
            return cell
        default:
            let cell: MyVCOrderCell = tableView.ts_dequeueReusableCell(MyVCOrderCell.self)
            return cell
        }
        
    }
    
}













/*
class MyVC: UIViewController {
    
    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var paiLabel: UILabel!
    @IBOutlet weak var rmbLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var degreeImageview: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
    
    @IBOutlet weak var paiView: UIStackView!
    @IBOutlet weak var rmbView: UIStackView!
    @IBOutlet weak var pointView: UIStackView!
    @IBOutlet weak var degreeView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var shoppingCartView: UIView!
    @IBOutlet weak var helpCenterView: UIView!
    @IBOutlet weak var orderMineView: UIView!
    @IBOutlet weak var favorStoresView: UIView!
    @IBOutlet weak var billingView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var videoPlayView: UIView!
    @IBOutlet weak var videoImageView: UIImageView! {
        didSet {
            videoImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarImageView.layer.borderColor = UIColor(colorWithHexValue: 0x2486cb).cgColor
        avatarImageView.layer.borderWidth = 4
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showUI(false)
        if UserInstance.isLogin {
            self.statusView.isHidden = false
            self.headerView.isHidden = false
            self.nameLabel.text = Utils.getNickName()
            self.avatarImageView.setImageWithURLStringNoCache(UserInstance.avatar, placeholderImage: ImageAsset.icon_avatar.image)
            if !NetworkUtil.isReachable() {
                ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
                return
            }
            ProgressHUD.showWithStatus()
            AuthAPI.shared.profileGet(completion: { (json, success) in
                if success {
                    ProgressHUD.dismiss()
                    UserInstance.userLoginSuccess(json["profile"])
                    /*if UserInstance.loginName!.isEmpty {
                     UserInstance.userLoginSuccess(json)
                     }*/
                    print("Profile Get...")
                    print(json)
                    DispatchQueue.main.async {
                        self.setupUI()
                    }
                    self.showUI(true)
                } else {
                    // try again...
                    AuthAPI.shared.profileGet(completion: { (json, success1) in
                        ProgressHUD.dismiss()
                        if success1 {
                            UserInstance.userLoginSuccess(json["profile"])
                            if UserInstance.loginName!.isEmpty {
                                //UserInstance.userLoginSuccess(json)
                            }
                            DispatchQueue.main.async {
                                self.setupUI()
                            }
                            self.showUI(true)
                        } else {
                            let errors = json["errors"].dictionaryValue
                            if let error = errors.values.first {
                                if let firstError =  error.arrayObject?.first as? String {
                                    ProgressHUD.showErrorWithStatus(firstError)
                                } else {
                                    ProgressHUD.showErrorWithStatus("无法获取您的个人资料.")
                                }
                            } else {
                                ProgressHUD.showErrorWithStatus("无法获取您的个人资料.")
                            }
                        }
                    })
                    
                }
            })
        } else {
            self.showUI(false)
            self.goToLoginVC()
        }
    }
    
    
    private func setupButtons() {
        let walletTap = UITapGestureRecognizer(target: self, action: #selector(selectWallet))
        walletView.isUserInteractionEnabled = true
        walletView.addGestureRecognizer(walletTap)
        
        let degreeTap = UITapGestureRecognizer(target: self, action: #selector(selectDegree))
        degreeView.isUserInteractionEnabled = true
        degreeView.addGestureRecognizer(degreeTap)
        
        let storeTap = UITapGestureRecognizer(target: self, action: #selector(selectStore))
        storeView.isUserInteractionEnabled = true
        storeView.addGestureRecognizer(storeTap)
        
        let shoppingCartTap = UITapGestureRecognizer(target: self, action: #selector(selectShoppingCart))
        shoppingCartView.isUserInteractionEnabled = true
        shoppingCartView.addGestureRecognizer(shoppingCartTap)
        
        let helpCenterTap = UITapGestureRecognizer(target: self, action: #selector(selectHelpCenter))
        helpCenterView.isUserInteractionEnabled = true
        helpCenterView.addGestureRecognizer(helpCenterTap)
        
        let orderMineTap = UITapGestureRecognizer(target: self, action: #selector(selectOrderMine))
        orderMineView.isUserInteractionEnabled = true
        orderMineView.addGestureRecognizer(orderMineTap)
        
        let favorStoresTap = UITapGestureRecognizer(target: self, action: #selector(selectFavorStores))
        favorStoresView.isUserInteractionEnabled = true
        favorStoresView.addGestureRecognizer(favorStoresTap)
        
        let billingTap = UITapGestureRecognizer(target: self, action: #selector(selectBilling))
        billingView.isUserInteractionEnabled = true
        billingView.addGestureRecognizer(billingTap)
        
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(selectShare))
        shareView.isUserInteractionEnabled = true
        shareView.addGestureRecognizer(shareTap)
        
        let notificationTap = UITapGestureRecognizer(target: self, action: #selector(selectNotification))
        notificationView.isUserInteractionEnabled = true
        notificationView.addGestureRecognizer(notificationTap)
        
        let videoPlayTap = UITapGestureRecognizer(target: self, action: #selector(selectMyVideo))
        videoPlayView.isUserInteractionEnabled = true
        videoPlayView.addGestureRecognizer(videoPlayTap)
        
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(selectAvatar))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarTap)
        
        let paiTap = UITapGestureRecognizer(target: self, action: #selector(selectWallet))
        paiView.isUserInteractionEnabled = true
        paiView.addGestureRecognizer(paiTap)
        
        let rmbTap = UITapGestureRecognizer(target: self, action: #selector(selectWallet))
        rmbView.isUserInteractionEnabled = true
        rmbView.addGestureRecognizer(rmbTap)
        
        let pointTap = UITapGestureRecognizer(target: self, action: #selector(selectWallet))
        pointView.isUserInteractionEnabled = true
        pointView.addGestureRecognizer(pointTap)
    }
    
    private func setupUI() {
        self.nameLabel.text = Utils.getNickName()
        self.avatarImageView.setImageWithURLStringNoCache(UserInstance.avatar, placeholderImage: ImageAsset.icon_avatar.image)
        self.paiLabel.text = "π : " + UserInstance.paiBalance!
        self.rmbLabel.text = "余额 : " + UserInstance.rmbBalance!
        self.pointLabel.text = "π积分 : " + UserInstance.point!
        
        let degreeId = UserInstance.degreeId!
        self.degreeImageview.image = UIImage(named: "my_total.png")
        if degreeId  > 0 {
            var degreeImages: [String] = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.degreeImageArray.count > 0 {
                degreeImages = appDelegate.degreeImageArray
            } else {
                degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
            }
            if degreeImages.count >= degreeId {
                self.degreeImageview.setImageWithURLString(degreeImages[degreeId - 1])
            }
            self.degreeLabel.text = UserInstance.degreePeriod
            self.degreeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        } else {
            self.degreeLabel.text = "  商家 : 免费版"
            self.degreeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
        self.setupButtons()
        
    }
    
    @IBAction func selectSetting(_ sender: UIButton) {
        Utils.applyTouchEffect(settingImageView)
        self.performSegue(withIdentifier: MySettingVC.nameOfClass, sender: self)
    }
    
    @IBAction func selectQuestion(_ sender: UIButton) {
        Utils.applyTouchEffect(questionImageView)
        
        /*let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: AboutUsVC.nameOfClass)
         self.navigationController?.pushViewController(vc, animated: true)*/
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
        vc.urlString = API.WEB_LINK + "/aboutus"
        vc.navBarTitle = "服务介绍"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectWallet() {
        Utils.applyTouchEffect(walletView)
        self.performSegue(withIdentifier: MyWalletVC.nameOfClass, sender: self)
    }
    
    @objc func selectDegree() {
        Utils.applyTouchEffect(degreeView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoUpgradeVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectStore() {
        Utils.applyTouchEffect(storeView)
        self.performSegue(withIdentifier: MyStoreVC.nameOfClass, sender: self)
    }
    
    @objc func selectShoppingCart() {
        Utils.applyTouchEffect(shoppingCartView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ShoppingCartVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectHelpCenter() {
        Utils.applyTouchEffect(helpCenterView)
        self.performSegue(withIdentifier: MyHelpCenterVC.nameOfClass, sender: self)
    }
    
    @objc func selectOrderMine() {
        Utils.applyTouchEffect(orderMineView)
        self.performSegue(withIdentifier: MyOrderMineVC.nameOfClass, sender: self)
    }
    
    @objc func selectAvatar() {
        Utils.applyTouchEffect(avatarImageView)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectFavorStores() {
        Utils.applyTouchEffect(favorStoresView)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyFavorStoresVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectBilling() {
        Utils.applyTouchEffect(billingView)
        self.performSegue(withIdentifier: MyBillingVC.nameOfClass, sender: self)
    }
    
    @objc func selectShare() {
        Utils.applyTouchEffect(shareView)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
        vc.urlString = API.WEB_LINK + "/qrcode" // "http://192.168.0.100/paishop/public/qrcode"
        vc.navBarTitle = "分享派世界"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectNotification() {
        Utils.applyTouchEffect(notificationView)
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: NotificationVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectMyVideo() {
        Utils.applyTouchEffect(videoPlayView)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyVideoPlayVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func selectLogout(_ sender: Any) {
        ProgressHUD.showWithStatus()
        let parameters: [String : Any] = [
            "token" : UserInstance.deviceToken!
        ]
        AuthAPI.shared.logout(params: parameters) { (success) in
            if success {
                print("Logout......")
            }
        }
        UserInstance.userLogout()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ProgressHUD.dismiss()
            let tab: [String : Any] = ["tab" : 0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil, userInfo: tab)
        }
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGOUT_APPLICATION), object: nil)
    }
    
    private func showUI(_ show: Bool) {
        self.statusView.isHidden = !show
        self.headerView.isHidden = !show
        self.scrollView.isHidden = !show
    }
    
    private func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
}

*/

















