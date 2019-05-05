

import UIKit
import MJRefresh
import SKPhotoBrowser
import MonkeyKing

class HomeStoreDetailVC: UIViewController {
    
    var senderVC: String?
    var senderIndex: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(HomeStoreDetailTopCell.self)
            tableView.ts_registerCellNib(HomeStoreDetailProductCell.self)
            tableView.ts_registerCellNib(HomeStoreDetailHeaderCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    
    var storeId: Int64!
    var storeDetail: StoreDetailModel!
    var storeBestItems: [ProductListModel] = []
    var storeItems: [ProductListModel] = []
    var storeCategories: [CategoryModel] = []
    var page = 1
    var isEndData = false
    
    var selectedIndex: NSInteger = 0
    var selectedCategoryId: Int64? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.isHidden = true
        setupRefresh()
        self.loadStoreDetail(index: 1, categoryId: 0)
        
        self.setupNavBar()
    }
    
    
    
    private func setupNavBar() {
        navBar.lblTitle.text = "店铺详情页"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    
    private func loadStoreDetail(index: NSInteger, categoryId: Int64) {
        selectedIndex = index
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        HomeAPI.shared.storeDetail(storeId: self.storeId) { (json, success) in
            if success {
//                print("Store Detail.......")
//                print(json)
                self.storeDetail = StoreDetailModel(json["store"])
                self.loadStoreItems(resetData: true, index: index, categoryId: categoryId)
                self.loadStoreBestItems(index: index, categoryId: categoryId)
            } else {
                // load again...
                HomeAPI.shared.storeDetail(storeId: self.storeId, completion: { (json1, success1) in
                    if success1 {
                        self.storeDetail = StoreDetailModel(json1["store"])
                        self.loadStoreItems(resetData: true, index: index, categoryId: categoryId)
                        self.loadStoreBestItems(index: index, categoryId: categoryId)
                    } else {
                        self.navBar.alpha = 1
                        ProgressHUD.dismiss()
                        let errors = json1["errors"].dictionaryValue
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
    
    private func loadStoreBestItems(index: NSInteger, categoryId: Int64) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : self.storeId!
        ]
        HomeAPI.shared.itemStoreBest(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
//                print("Item Store Best...", json)

                self.storeBestItems.removeAll()
                
                for listModel in ProductListModel.getProductListsFromJson(json["items"]) {
                    
                    if index == 1 && listModel.propertyAll == true {
                        if categoryId == 0  {
                            self.storeBestItems.append(listModel)

                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeBestItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 2 {
                        if categoryId == 0  {
                            self.storeBestItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeBestItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 3 && listModel.propertyRecent == true {
                        if categoryId == 0  {
                            self.storeBestItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeBestItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 4 && listModel.propertyActive == true {
                        if categoryId == 0  {
                            self.storeBestItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeBestItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 5 {
                        if categoryId == 0  {
                            self.storeBestItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeBestItems.append(listModel)
                            }
                        }
                    }
                    
                }
                
                self.tableView.reloadData()
                
            } else {
                //try again...
                HomeAPI.shared.itemStoreBest(params: parameters, completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.storeBestItems = ProductListModel.getProductListsFromJson(json1["items"])
                        self.tableView.reloadData()
                    } else {
                        let errors = json1["errors"].dictionaryValue
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
    
    
    private func loadStoreItems(resetData: Bool, index: NSInteger, categoryId: Int64) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
        }
//        if isEndData {
//            self.endFooterRefresh()
//            return
//        }
        
        HomeAPI.shared.itemStore(page: self.page, storeId: storeDetail.storeId!) { (json, success) in
            self.endFooterRefresh()
            if success {
                print("Item Store......")
                print(json)
                if resetData {
                    self.storeItems = []
                }
                self.tableView.isHidden = false
                
                self.storeCategories.removeAll()

                for listModel in ProductListModel.getProductListsFromJson(json["data"]) {

                    // get categories
                    if self.storeCategories.count == 0 {
                        self.storeCategories.append(listModel.category!)

                    } else {
                        
                        var isContains: Bool = false
                        
                        for category in self.storeCategories {
                            
                            if category.id == listModel.category?.id {
                               isContains = true
                                break
                            } else {
                                isContains = false
                            }
                        }
                        
                        if isContains == false {
                            self.storeCategories.append(listModel.category!)
                        }
                        
                    }
                    
                    self.storeItems.removeAll()
                    
                    // get items
                    if index == 1 && listModel.propertyAll == true {
                        if categoryId == 0  {
                            self.storeItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 2 {
                        if categoryId == 0  {
                            self.storeItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 3 && listModel.propertyRecent == true {
                        if categoryId == 0  {
                            self.storeItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 4 && listModel.propertyActive == true {
                        if categoryId == 0  {
                            self.storeItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeItems.append(listModel)
                            }
                        }
                    }
                    
                    if index == 5 {
                        if categoryId == 0  {
                            self.storeItems.append(listModel)
                            
                        } else {
                            if listModel.category?.id == categoryId {
                                self.storeItems.append(listModel)
                            }
                        }
                    }
                    
                }
                
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                if resetData {
                    ProgressHUD.dismiss()
                }
                self.tableView.ts_reloadData {  }
            } else {
                // try again...
                HomeAPI.shared.itemStore(page: self.page, storeId: self.storeDetail.storeId!, completion: { (json1, success1) in
                    if success1 {
                        if resetData {
                            self.storeItems = []
                        }
                        self.tableView.isHidden = false
                        let tempItems = ProductListModel.getProductListsFromJson(json1["data"])
                        self.storeItems.append(contentsOf: tempItems)
                        let lastPage = json1["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        if resetData {
                            ProgressHUD.dismiss()
                        }
                        self.tableView.ts_reloadData {  }
                    } else {
                        if resetData {
                            self.navBar.alpha = 1
                            ProgressHUD.dismiss()
                            let errors = json1["errors"].dictionaryValue
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
                    }
                })
            }
        }
    }
    
    private func setupRefresh() {
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_footer = refreshFooter
    }
    
    private func footerRefreshing() {
        self.loadStoreItems(resetData: false, index: selectedIndex, categoryId: selectedCategoryId!)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    // Footer bar
    @IBAction func tapBtnCallService(_ sender: Any) {
        if !UserInstance.isLogin {
            self.goToLoginVC()
            return
        }
        if storeDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        self.presentAlert("你真的想聊天吗?") {
            self.presentChatVC()
        }
    }
    
    func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        loginVC.isChangeTab = false
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
    private func presentChatVC() {
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        //Create Chat Room
        let userId = storeDetail.user?.id
        if let id = userId, id > 0 {
            let parameters: [String : Any] = [
                "ids" : [id]
            ]
            ProgressHUD.showWithStatus()
            SocialAPI.shared.chatCreate(params: parameters, completion: { (json, success) in
                if success {
//                    print(json)
                    let chatListItem = ChatListModel(json["room"])
                    self.sendChatText(chatListItem)
                } else {
                    ProgressHUD.dismiss()
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
    
    private func sendChatText(_ chatListItem: ChatListModel) {
        let productName = storeDetail.name!
        let productId = storeDetail.storeId!
        //let deepLink = "http://paikepaifu.product.cn/\(productId)"//"paishop://product/\(productId)"
//        let deepLink = "http://paikepaifu.cn/share?product=\(productId)"
        let deepLink = "http://paikepaifu.cn/share?store=\(productId)"
        let chatText = productName + "\n" + deepLink
        let parameters: [String : Any] = [
            "id" : chatListItem.id,
            "message" : chatText,
            "type" : MessageContentType.Text.rawValue
        ]
        SocialAPI.shared.chatMessageSend(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            if success {
                //print("Chat Message Send....")
                //print(json)
                let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: ChatVC.nameOfClass) as! ChatVC
                vc.chatListModel = chatListItem
                self.pushViewController(vc, animated: true, hideTabbar: false)
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
        }
    }
    
    @IBAction func tapBtnCategory(_ sender: Any) {
        print(">>> category")
        
        self.loadPopoverViewController(index: 0, sender: sender)
    }
    
    func loadPopoverViewController(index: NSInteger, sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        print(">>> self.storeCategories:", self.storeCategories)
        
        for category in self.storeCategories {
            let defalutAction = UIAlertAction(title: category.name, style: .default) { (alert: UIAlertAction) in
                print(">>>> selected category:", category.name!)
                
                self.loadStoreDetail(index: self.selectedIndex, categoryId: category.id!)
            }
            
            alertController.addAction(defalutAction)
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (alert: UIAlertAction) in
            print(">>>> cancel")
        }
        alertController.addAction(cancelAction)

        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
//            popoverController.sourceView = self.view
//            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//            popoverController.permittedArrowDirections = [.down]
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

extension HomeStoreDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            let count = self.storeBestItems.count
            if count % 2 > 0 {
                return count / 2 + 1
            } else {
                return count / 2
            }
        case 2:
            let count = self.storeItems.count
            if count % 2 > 0 {
                return count / 2 + 1
            } else {
                return count / 2
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: HomeStoreDetailTopCell = tableView.ts_dequeueReusableCell(HomeStoreDetailTopCell.self)
            if self.storeDetail != nil {
                cell.setCellContent(self.storeDetail, vc: self)
            }
            cell.delegate = self
            
            return cell
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell: HomeStoreDetailHeaderCell = tableView.ts_dequeueReusableCell(HomeStoreDetailHeaderCell.self)
                cell.setCellContent(self, indexPath: indexPath)
                return cell
            } else {
                let cell: HomeStoreDetailProductCell = tableView.ts_dequeueReusableCell(HomeStoreDetailProductCell.self)
                cell.setCellContent(self, indexPath: indexPath)
                return cell
            }
        }
        
        if indexPath.row == 0 {
            let cell: HomeStoreDetailHeaderCell = tableView.ts_dequeueReusableCell(HomeStoreDetailHeaderCell.self)
            cell.setCellContent(self, indexPath: indexPath)
            return cell
        } else {
            let cell: HomeStoreDetailProductCell = tableView.ts_dequeueReusableCell(HomeStoreDetailProductCell.self)
            cell.setCellContent(self, indexPath: indexPath)
            return cell
        }
        
        
    }
    
}


extension HomeStoreDetailVC: NavBarDelegate {
    func didSelectBack() {
        if self.senderVC != nil && self.senderIndex != nil {
            let info: [String : Any] = [
                "senderVC" : self.senderVC!,
                "senderIndex" : self.senderIndex,
                "storeDetail" : self.storeDetail
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_DETAIL_CHANGE), object: nil, userInfo: info)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension HomeStoreDetailVC: HomeStoreDetailTopCellDelegate {
    func didTapButtonHomeStoreDetailTopCell(index: NSInteger) {
        print(">>>> index:", index)
        
        self.loadStoreDetail(index: index, categoryId: selectedCategoryId!)
    }
}

/*
class HomeStoreDetailVC: UIViewController {
    
    var senderVC: String?
    var senderIndex: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(HomeStoreDetailCell.self)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 300
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var degreeImageView: UIImageView! /*{
        didSet {
            degreeImageView.clipsToBounds = true
            degreeImageView.layer.borderWidth = 1
            degreeImageView.layer.borderColor = UIColor.init(colorWithHexValue: 0xFF3E03).cgColor
        }
    }*/
    @IBOutlet weak var viewsLabel: UILabel!
    
    
    @IBOutlet weak var storeOpeningLabel: UILabel!
    @IBOutlet weak var storeAddressView: UIView!
    @IBOutlet weak var pinImageView: UIImageView! {
        didSet {
            pinImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    @IBOutlet weak var storeAddressLabel: UILabel!
    @IBOutlet weak var phoneNumberView: UIView!    
    @IBOutlet weak var phoneNumerLabel: UILabel!
    @IBOutlet weak var shareView: UIStackView!
    @IBOutlet weak var favorLabel: UILabel!
    @IBOutlet weak var favorPlusLabel: UILabel!
    
    
    @IBOutlet weak var overlayView: UIView!
    
    
    var storeId: Int64!
    var storeDetail: StoreDetailModel!
    var storeItems: [ProductListModel] = []
    var page = 1
    var isEndData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Nav bar set up
        navBar.lblTitle.text = "店铺详情页"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }        
        
        self.overlayView.isHidden = false
        
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(selectShare))
        shareView.isUserInteractionEnabled = true
        shareView.addGestureRecognizer(shareTap)
        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(selectPhone))
        phoneNumberView.isUserInteractionEnabled = true
        phoneNumberView.addGestureRecognizer(phoneTap)
        
        setupRefresh()
        self.loadStoreDetail()
        
        SKPhotoBrowserOptions.displayAction = false
        
    }
    
    
    private func loadStoreDetail() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        HomeAPI.shared.storeDetail(storeId: self.storeId) { (json, success) in
            if success {
                print("Store Detail.......")
                print(json)
                self.storeDetail = StoreDetailModel(json["store"])
                self.loadStoreItems(resetData: true)
            } else {
                // load again...
                HomeAPI.shared.storeDetail(storeId: self.storeId, completion: { (json, success1) in
                    if success1 {
                        self.storeDetail = StoreDetailModel(json["store"])
                        self.loadStoreItems(resetData: true)
                    } else {
                        ProgressHUD.dismiss()
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
    
    
    private func loadStoreItems(resetData: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        HomeAPI.shared.itemStore(page: self.page, storeId: storeDetail.storeId!) { (json, success) in
            self.endFooterRefresh()
            if success {
                //print("Item Store......")
                //print(json)
                if resetData {
                    self.storeItems = []
                }
                self.overlayView.isHidden = true
                let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                self.storeItems.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                if resetData {
                    ProgressHUD.dismiss()
                    self.setupUI()
                } else {
                    self.tableView.ts_reloadData {  }
                }
            } else {
                // try again...
                HomeAPI.shared.itemStore(page: self.page, storeId: self.storeDetail.storeId!, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.storeItems = []
                        }
                        self.overlayView.isHidden = true
                        let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                        self.storeItems.append(contentsOf: tempItems)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        if resetData {
                            ProgressHUD.dismiss()
                            self.setupUI()
                        } else {
                            self.tableView.ts_reloadData {  }
                        }
                    } else {
                        if resetData {
                            ProgressHUD.dismiss()
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
                    }
                })
            }
        }
    }
    
    private func setupUI() {
        if let storeUrl = storeDetail.image, storeUrl != "" {
            let resizedStoreUrl = Utils.getResizedImageUrlString(storeUrl, width: "100")
            storeImageView.setImageWithURLString(resizedStoreUrl, placeholderImage: ImageAsset.icon_store.image)
        } else {
            storeImageView.setImageWithURLString(storeDetail.image, placeholderImage: ImageAsset.icon_store.image)
        }
        
        storeNameLabel.text = storeDetail.name
        viewsLabel.text = "浏览" + String(storeDetail.views!)
        
        storeOpeningLabel.text = storeDetail.opening
        storeAddressLabel.text = storeDetail.address
        if storeDetail.address!.isEmpty {
            storeAddressLabel.text = storeDetail.user?.address
        }
        phoneNumerLabel.text = storeDetail.phoneNumber
        if storeDetail.phoneNumber!.isEmpty {
            phoneNumerLabel.text = storeDetail.user?.phoneNumber
        }
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        let degreeId = storeDetail.user!.degreeId!
        degreeImageView.isHidden = true
        if degreeImages.count > 0 && degreeId > 0 {
            if degreeImages.count >= degreeId {
                degreeImageView.isHidden = false
                degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
            }
        }
        
        tableView.ts_reloadData {
            
        }
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(goToMap))
        storeAddressView.isUserInteractionEnabled = true
        storeAddressView.addGestureRecognizer(addressTap)
        
        let storeImageTap = UITapGestureRecognizer(target: self, action: #selector(tapStoreImageView))
        storeImageView.isUserInteractionEnabled = true
        storeImageView.addGestureRecognizer(storeImageTap)
        
        if storeDetail.favorites! > 0 {
            favorLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
            favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
        } else {
            favorLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
            favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
        }
    }
    
    private func setupRefresh() {
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_footer = refreshFooter
    }
    
    private func footerRefreshing() {
        self.loadStoreItems(resetData: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    @IBAction func selectFavor(_ sender: UIButton) {
        Utils.applyTouchEffect(favorLabel)
        Utils.applyTouchEffect(favorPlusLabel)
        
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录!")
            return
        }
        
        if Int64(UserInstance.storeId!) == self.storeDetail.storeId! {
            ProgressHUD.showSuccessWithStatus("这是你的商店!")
            return
        }
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : self.storeDetail.storeId!
        ]
        if storeDetail.favorites! > 0 {
            /*HomeAPI.shared.storeFavoriteDelete(params: parameters, completion: { (json, success) in
                if success {
                    print("Store Favorite Delete...")
                    print(json)
                    self.storeDetail.favorites = 0
                    self.favorLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
                    self.favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
                } else {
                    // try again...
                    HomeAPI.shared.storeFavoriteDelete(params: parameters, completion: { (json, success1) in
                        if success1 {
                            self.storeDetail.favorites = 0
                            self.favorLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
                            self.favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
                        }
                    })
                }
            })*/
        } else {
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            HomeAPI.shared.storeFavoriteAdd(params: parameters) { (json, success) in
                sender.isEnabled = true
                ProgressHUD.dismiss()
                if success {
                    print("Store Favorite Add...")
                    print(json)
                    self.storeDetail.favorites = 1
                    self.favorLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
                    self.favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
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
            }
        }
    }
    
    
    @objc func selectShare() {
        Utils.applyTouchEffect(shareView)
        
        MonkeyKing.registerAccount(.weChat(appID: "wx987358b52f62b2ad", appKey: "e215123acf16ce7cee560820fdad895e", miniAppID: nil))
        let shareText = storeDetail.name!
        //let deepLinkString = "paishop://store/\(storeId!)"
        let deepLinkString = "http://paikepaifu.cn/share?store=\(storeId!)"
        
        let deepLinkUrl = URL.init(string: deepLinkString)!
        let info = MonkeyKing.Info(
            title: shareText,
            description: storeDetail.introduction,
            thumbnail: nil,
            media: .url(deepLinkUrl)//.image(UIImage(named: "wechat_timeline")!)//nil
        )
        let sessionMessage = MonkeyKing.Message.weChat(.session(info: info))
        let weChatSessionActivity = AnyActivity(
            type: UIActivityType(rawValue: "com.longcai.paishop.WeChat.Session"),
            title: NSLocalizedString("微信", comment: ""),
            image: UIImage(named: "wechat_session")!,
            message: sessionMessage) { (success) in
                print("Session success: \(success)")
        }
        let vc = UIActivityViewController(activityItems: [shareText, deepLinkUrl], applicationActivities: [weChatSessionActivity])
        if let popoverController = vc.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func selectPhone() {
        if storeDetail.user?.id == UserInstance.userId {
            return
        }
        Utils.applyTouchEffect(phoneNumberView)
        let phoneString = storeDetail.phoneNumber
        if let phoneStr = phoneString, !phoneStr.isEmpty {
            if let phoneCallURL:URL = URL(string: "tel://\(phoneStr)") {
                print("call phone=\(phoneStr)")
                let application:UIApplication = UIApplication.shared
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func goToMap() {
        let latitude = storeDetail.lat!
        let longitude = storeDetail.lng!
        if latitude != 0.0 && longitude != 0.0 {
            Utils.applyTouchEffect(storeAddressView)
            
            let guideMapVC = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: GuideMapVC.nameOfClass) as! GuideMapVC
            guideMapVC.markerName = storeDetail.name!
            guideMapVC.markerLat = latitude
            guideMapVC.markerLon = longitude
            guideMapVC.makerDescription = storeDetail.introduction
            guideMapVC.storeImage = storeDetail.image
            guideMapVC.storeId = storeDetail.storeId!
            guideMapVC.isFromStoreDetail = true
            guideMapVC.degree = storeDetail.user?.degreeId
            self.pushAndHideTabbar(guideMapVC)
        }
    }
    
    @objc func tapStoreImageView() {
        Utils.applyTouchEffect(storeImageView)
        
        var skPhotoes = [SKPhoto]()
        
        if let storeImage = storeDetail.image, storeImage != "" {
            let photo = SKPhoto.photoWithImageURL(storeImage, holder: nil)
            skPhotoes.append(photo)
        }
        
        if let storeImages = storeDetail.images {
            for storeImage in storeImages {
                let photo = SKPhoto.photoWithImageURL(storeImage, holder: nil)
                skPhotoes.append(photo)//SKPhoto.photoWithImageURL(API.IMAGE_URL + storeImage, holder: nil)
                skPhotoes.append(photo)
            }
        }
        
        if skPhotoes.count > 0 {
            let browser = SKPhotoBrowser(photos: skPhotoes)
            browser.initializePageIndex(0)
            self.present(browser, animated: true, completion: {  })
        }
    }
    
    

}




extension HomeStoreDetailVC: NavBarDelegate {
    func didSelectBack() {
        if self.senderVC != nil {
            let info: [String : Any] = [
                "senderVC" : self.senderVC!,
                "senderIndex" : self.senderIndex,
                "storeDetail" : self.storeDetail
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_DETAIL_CHANGE), object: nil, userInfo: info)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}


extension HomeStoreDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.storeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "所有商品"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            return cell
        }
        let cell: HomeStoreDetailCell = tableView.ts_dequeueReusableCell(HomeStoreDetailCell.self)
        cell.setContent(self.storeItems[indexPath.row], vc: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = self.storeItems[indexPath.row].id!
        self.pushAndHideTabbar(vc)
    }
}
*/


















