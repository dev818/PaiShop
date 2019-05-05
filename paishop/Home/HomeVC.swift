

import UIKit
import SDCycleScrollView
import MJRefresh
import Alamofire
import SwiftyJSON
import AssistantKit
import TimedSilver
import QRCodeReader
import swiftScan


class HomeVC: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var statusFrame: GradientView!
    @IBOutlet weak var navFrame: GradientView!
    @IBOutlet weak var searchView: RoundView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(HomeMainCycleCell.self)
            tableView.ts_registerCellNib(HomeNewsCell.self)
            tableView.ts_registerCellNib(HomeRecommendProductCell.self)
            tableView.ts_registerCellNib(HomeDirectCell.self)
            tableView.ts_registerCellNib(HomeLiveCell.self)
            tableView.ts_registerCellNib(HomeRecentProductCell1.self)
            tableView.ts_registerCellNib(HomeRecentProductCell2.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.tableFooterView = UIView()
            tableView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }
    @IBOutlet weak var topMoveView: RoundRectView! {
        didSet {
            topMoveView.isHidden = true
        }
    }
       
    
    var promotions: [PromotionModel] = []
    var categories: [CategoryModel] = []
    var productLists: [ProductListModel] = []
    var notificationLists: [NotificationListModel] = []
    
    var recommendItems: [ItemRecommendModel] = []
    var recommendDirects: [ProductListModel] = []
    var recommendVideos: [LiveVideoModel] = []
    
    var page = 1
    var isEndData = false
    var currentPage = 0
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupRefresh()
        self.setupUI()
        self.loadPromotions(true)
        self.loadCategories()
        self.loadNotificationLists()
        self.loadRecommends()
        self.loadProductLists(true, resetData: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            //self.showAnimate()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterForeground(_:)), name: NSNotification.Name(Notifications.APPLICATION_WILL_ENTER_FOREGROUND), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupTheme()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    //h.g.n => show popup View
    func showAnimate()
    {
        self.popupView.isHidden = false
        self.popupView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.popupView.alpha = 0.0;
        UIView.animate(withDuration: 2.5, animations: {
            self.popupView.alpha = 1.0
            self.popupView.transform = CGAffineTransform(scaleX: 4.0, y: 4.0)
        });
    }
    
    private func setupUI() {
        searchView.isUserInteractionEnabled = true
        let searchTap = UITapGestureRecognizer(target: self, action: #selector(selectSearch))
        searchView.addGestureRecognizer(searchTap)
        
        topMoveView.isUserInteractionEnabled = true
        let topMoveTap = UITapGestureRecognizer(target: self, action: #selector(selectTopMove))
        topMoveView.addGestureRecognizer(topMoveTap)
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timerDidFire), userInfo: nil, repeats: true)
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        statusFrame.startColor = MainColors.themeStartColors[selectedTheme]
        statusFrame.endColor = MainColors.themeEndColors[selectedTheme]
        navFrame.startColor = MainColors.themeStartColors[selectedTheme]
        navFrame.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func setupRefresh() {
        let refreshHeader = MJRefreshNormalHeader {
            self.headerRefreshing()
        }
        refreshHeader?.lastUpdatedTimeLabel.isHidden = true
        refreshHeader?.setTitle("拉下来刷新", for: MJRefreshState.idle)
        refreshHeader?.setTitle("释放以刷新", for: .pulling)
        refreshHeader?.setTitle("装载...", for: .refreshing)
        /*refreshHeader?.setImages([UIImage(named: "refresh.png")!], for: .idle)
         refreshHeader?.setImages([UIImage(named: "refresh.png")!], for: .pulling)
         refreshHeader?.setImages([UIImage(named: "refresh.png")!], for: .refreshing)*/
        self.tableView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_footer = refreshFooter
    }
    
    
    @objc func reloadData() {
        self.loadPromotions(true)
        self.loadCategories()
        self.loadNotificationLists()
        self.loadRecommends()
        self.loadProductLists(true, resetData: true)
    }
    
    
    //open qrcode vc...
    @IBAction func selectNavBtn1(_ sender: UIButton) {
        self.openSwiftScanVC()
    }
    
    //open shopping cart vc...
    @IBAction func selectNavBtn2(_ sender: UIButton) {
        if UserInstance.isLogin {
//            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ShoppingCartVC.nameOfClass)
//            self.navigationController?.pushViewController(vc, animated: true)
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
            vc.selectedIndex = 1
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.goToLoginVC()
        }
    }
    
    //open chat vc...
    @IBAction func selectNavBtn3(_ sender: UIButton) {
        if UserInstance.isLogin {
            let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: SocialVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.goToLoginVC()
        }
    }
    
    
    @objc func selectTopMove() {
        Utils.applyTouchEffect(topMoveView)
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func timerDidFire() {
        if self.notificationLists.count < 1 {
            return
        }
        guard let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) as? HomeNewsCell else { return }
        
        var contentOffset = CGPoint.zero
        
        if currentPage >= (self.notificationLists.count - 1) {
            currentPage = 0
            contentOffset = CGPoint(x: 0, y: 0)
            cell.tableView.setContentOffset(contentOffset, animated: false)
        }
        
        currentPage += 1
        contentOffset = CGPoint(x: 0, y: 44 * currentPage)
        
        if contentOffset != CGPoint.zero {
            cell.tableView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    @objc func applicationEnterForeground(_ notification: NSNotification) {
        if self.promotions.count < 1 || self.categories.count < 1 || self.productLists.count < 1 {
            self.loadPromotions(true)
            self.loadCategories()
            self.loadProductLists(true, resetData: true)
        }
        
    }
    
    @objc func selectSearch() {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeSearchVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func headerRefreshing() {
        //refresh data
        self.loadCategories()
        self.loadNotificationLists()
        self.loadPromotions(true)
        self.loadProductLists(false, resetData: true)
        self.loadRecommends()
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        //refresh data
        self.loadProductLists(true, resetData: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    private func setupCycleCell(_ cell: HomeMainCycleCell) {
        cell.setupCycleView(categories, vc: self)
        cell.cycleView.delegate = self
        
        var imageUrls = [String]()
        for promotion in self.promotions {
            let resizedUrl = Utils.getResizedImageUrlString(promotion.image!, width: "750")
            imageUrls.append(resizedUrl)
        }
        cell.setupImages(imageUrls)
    }
    
    
    private func loadPromotions(_ endRefresh: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            self.endHeaderRefresh()
            return
        }
        HomeAPI.shared.itemPromotions { (json, success) in
            if success {
                print("Item Promotions.........")
                print(json)
                self.promotions = PromotionModel.getPromotionsFromJson(json["promotions"])
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData {
                        if endRefresh {
                            self.endHeaderRefresh()
                        }
                    }
                })
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.HOME_DID_LOAD), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    if self.productLists.count < 1 {
                        self.loadProductLists(true, resetData: true)
                    }
                })
            } else {
                //load again...
                HomeAPI.shared.itemPromotions(completion: { (json1, success1) in
                    if success1 {
                        self.promotions = PromotionModel.getPromotionsFromJson(json["promotions"])
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData {
                                if endRefresh {
                                    self.endHeaderRefresh()
                                }
                            }
                        })
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.HOME_DID_LOAD), object: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                            if self.productLists.count < 1 {
                                self.loadProductLists(true, resetData: true)
                            }
                        })
                    } else {
                        if endRefresh {
                            self.endHeaderRefresh()
                        }
                    }
                })
            }
        }
    }
    
    private func loadCategories() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.categoryRoot { (json, success) in
            if success {
                print("Category Root............")
                print(json)
                self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.categories = self.categories
                
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData { }
                })
            } else {
                //load again...
                HomeAPI.shared.categoryRoot(completion: { (json, success1) in
                    if success1 {
                        self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.categories = self.categories
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData { }
                        })
                    }
                })
            }
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
    
    private func loadRecommends() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.Recommends { (json, success) in
            if success {
                print("Recommends...")
                print(json)
                
                self.recommendItems = ItemRecommendModel.getItemRecommendsFromJson(json["items"])
                self.recommendDirects = ProductListModel.getProductListsFromJson(json["directs"])
                self.recommendVideos = LiveVideoModel.getLiveVideosFromJson(json["videos"])
                
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData { }
                })
            } else {
                HomeAPI.shared.Recommends(completion: { (json1, success1) in
                    if success1 {
                        self.recommendItems = ItemRecommendModel.getItemRecommendsFromJson(json["items"])
                        self.recommendDirects = ProductListModel.getProductListsFromJson(json["directs"])
                        self.recommendVideos = LiveVideoModel.getLiveVideosFromJson(json["videos"])
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData { }
                        })
                    }
                })
            }
        }
    }
    
    private func loadProductLists(_ endRefresh: Bool, resetData: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            self.endFooterRefresh()
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
        }
        
        if self.isEndData {
            if endRefresh {
                self.endFooterRefresh()
            }
            return
        }
        
        HomeAPI.shared.itemHome(page: self.page) { (json, success) in
            if success {
                print("Item Home..............")
                print(json)
                if resetData {
                    self.productLists = []
                }
                let tempList = ProductListModel.getProductListsFromJson(json["data"])
                self.productLists.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                if self.page > 1 {
                    self.topMoveView.isHidden = false
                } else {
                    self.topMoveView.isHidden = true
                }
                DispatchQueue.main.async {
                    self.tableView.ts_reloadData {
                        if endRefresh {
                            self.endFooterRefresh()
                        }
                    }
                }
                
            } else {
                // try again...
                HomeAPI.shared.itemHome(page: self.page, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.productLists = []
                        }
                        let tempList = ProductListModel.getProductListsFromJson(json["data"])
                        self.productLists.append(contentsOf: tempList)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        if self.page > 1 {
                            self.topMoveView.isHidden = false
                        } else {
                            self.topMoveView.isHidden = true
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.ts_reloadData {
                            if endRefresh {
                                self.endFooterRefresh()
                            }
                        }
                    }
                })
            }
            
        }
    }
    
    func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        loginVC.isChangeTab = false
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
    
}



extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if notificationLists.count > 0 {
                return 1
            }
            return 0
        case 2:
            if recommendItems.count > 4 {
                return 1
            }
            return 0
        case 3:
            if recommendDirects.count > 4 {
                return 1
            }
            return 0
        case 4:
            if recommendVideos.count > 2 {
                return 1
            }
            return 0
        case 5:
            return productLists.count / 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: HomeMainCycleCell = tableView.ts_dequeueReusableCell(HomeMainCycleCell.self)
            self.setupCycleCell(cell)
            return cell
        case 1:
            let cell: HomeNewsCell = tableView.ts_dequeueReusableCell(HomeNewsCell.self)
            cell.setCellContent(self.notificationLists, vc: self)
            return cell
        case 2:
            let cell: HomeRecommendProductCell = tableView.ts_dequeueReusableCell(HomeRecommendProductCell.self)
            cell.setCellContent(self)
            return cell
        case 3:
            let cell: HomeDirectCell = tableView.ts_dequeueReusableCell(HomeDirectCell.self)
            
            return cell
        case 4:
            let cell: HomeLiveCell = tableView.ts_dequeueReusableCell(HomeLiveCell.self)
            
            return cell
        case 5:
            if indexPath.row == 0 {
                let cell: HomeRecentProductCell1 = tableView.ts_dequeueReusableCell(HomeRecentProductCell1.self)
                cell.setCellContent(self, row: indexPath.row)
                return cell
            }
            let cell: HomeRecentProductCell2 = tableView.ts_dequeueReusableCell(HomeRecentProductCell2.self)
            cell.setCellContent(self, row: indexPath.row)
            return cell
        default:
            let cell: HomeRecentProductCell2 = tableView.ts_dequeueReusableCell(HomeRecentProductCell2.self)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    
}


extension HomeVC: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        print("Selected image item at ", index)
        if index > promotions.count - 1 {
            return
        }
        let promotion = promotions[index]
        
        if promotion.itemId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = promotion.itemId!
            self.navigationController?.pushViewController(vc, animated: true)
        } else if promotion.storeId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = promotion.storeId!
            self.navigationController?.pushViewController(vc, animated: true)
        } else if promotion.siteUrl != nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
            vc.urlString = promotion.siteUrl!
            vc.navBarTitle = "服务条款"
            self.pushAndHideTabbar(vc)
        }
        
    }
}
















