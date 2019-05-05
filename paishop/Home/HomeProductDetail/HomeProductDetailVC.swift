
import UIKit
import RxSwift
import SKPhotoBrowser
import MJRefresh
import MonkeyKing


class HomeProductDetailVC: UIViewController {
    
    var itemId: Int64!
    var senderVC: String?
    var senderIndex: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(HomeProductDetailTopCell.self)
            tableView.ts_registerCellNib(HomeProductDetailTabCell.self)
            tableView.ts_registerCellNib(HomeProductDetailImageCell.self)
            tableView.ts_registerCellNib(HomeProductDetailCommentCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.tableFooterView = UIView()
        }
    }
    
    
    @IBOutlet weak var commentFrame: UIView! {
        didSet {
            commentFrame.isHidden = true
        }
    }
    @IBOutlet weak var commentTextView: UITextView! {
        didSet {
            commentTextView.delegate = self
            commentTextView.returnKeyType = .send
            commentTextView.placeholder = "评论"
            commentTextView.placeholderColor = UIColor.black
        }
    }
    @IBOutlet weak var commentWriteImageView: UIImageView!
    @IBOutlet weak var commentTextBorder: UIView!
    @IBOutlet weak var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentFrameBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentSendButton: UIButton!
    @IBOutlet weak var commentSendImageView: UIImageView! {
        didSet {
            commentSendImageView.setTintColor(UIColor.init(colorWithHexValue: 0x97977, alpha: 0.15))
        }
    }
    
    @IBOutlet weak var commentSendRoundView: RoundRectView!
    @IBOutlet weak var commentFrameHeightConstranit: NSLayoutConstraint! {
        didSet {
            commentFrameHeightConstranit.constant = 0
        }
    }
    
    @IBOutlet weak var tabBarFrame: UIView! {
        didSet {
            tabBarFrame.isHidden = true
        }
    }
    @IBOutlet weak var toolbar1ImageView: UIImageView! {
        didSet {
            toolbar1ImageView.setTintColor(UIColor.black)
        }
    }
    @IBOutlet weak var toolbar3ImageView: UIImageView! {
        didSet {
            toolbar3ImageView.setTintColor(UIColor.black)
        }
    }
    
    @IBOutlet var cartView: UIView!
    @IBOutlet weak var cartViewLabel: UILabel!
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.alpha = 0
            darkView.isHidden = true
        }
    }
    
    
    let disposeBag = DisposeBag()
    
    var productDetail: ProductDetailModel!
    var cartOrderCount = 1
    var productImageStrings: [String] = []
    var totalComments: Int = 0
    var comments: [CommentModel] = []
    var page = 1
    var isEndData = false
    
    var isSelectedCart = true // true - Cart, false - Order
    var isSelectedImageDetails = true // true - show Images, false - show review
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.isHidden = true
        self.showCommentFrame(false)
        self.setupRefresh()
        self.loadData()
        self.setupNavBar()
        
        SKPhotoBrowserOptions.displayAction = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        self.productImageStrings = productDetail.images!
        self.tableView.ts_reloadData { }
        
        let darkViewTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(darkViewTap)
        
        self.setupCustomView()
        self.keyboardControl()
        self.setupCommentSendButton()
        
        if productDetail.user?.id == UserInstance.userId {
            commentTextView.isUserInteractionEnabled = false
            commentSendButton.isEnabled = false
            //orderButton.isEnabled = false
        }
        if !UserInstance.isLogin {
            commentTextView.isUserInteractionEnabled = false
            commentSendButton.isEnabled = false
        }
        
        if self.productDetail.favorites! > 0 {
            self.toolbar3ImageView.image = UIImage(named: "ic_home_star_filled")
            self.toolbar3ImageView.setTintColor(UIColor.init(colorWithHexValue: 0xff3e03))
        } else {
            self.toolbar3ImageView.image = UIImage(named: "ic_home_star")
            self.toolbar3ImageView.setTintColor(UIColor.black)
        }
        
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "派世界"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        
        navBar.alpha = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            let offsetY = scrollView.contentOffset.y
            let alpha = offsetY / (Constants.SCREEN_WIDTH * 0.4) > 0 ? offsetY / (Constants.SCREEN_WIDTH * 0.4) : 0
            if offsetY > Constants.SCREEN_WIDTH / 320 {
                self.navBar.alpha = alpha
            } else {
                self.navBar.alpha = 0
            }
        }
    }
    
    private func loadData() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        HomeAPI.shared.itemDetail(itemId: self.itemId) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                print("Item Detail.......")
                print(json)
                self.productDetail = ProductDetailModel.init(json["item"])
                self.commentFrame.isHidden = false
                self.tabBarFrame.isHidden = false
                self.tableView.isHidden = false
                self.setupUI()
            } else {
                //load again...
                HomeAPI.shared.itemDetail(itemId: self.itemId, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.productDetail = ProductDetailModel.init(json["item"])
                        self.commentFrame.isHidden = false
                        self.tabBarFrame.isHidden = false
                        self.tableView.isHidden = false
                        self.setupUI()
                    } else {
                        self.navBar.alpha = 1
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
        
        //self.loadComments(resetData: true, loadFirst: true)
    }
    
    private func loadComments(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        
        let parameters: [String : Any] = [
            "id" : self.itemId
        ]
        
        HomeAPI.shared.commentItem(page: self.page, params: parameters) { (json, success) in
            if success {
                self.endFooterRefresh()
                print("Comment Item...")
                print(json)
                
                if resetData {
                    self.comments = []
                    ProgressHUD.dismiss()
                }
                let tempList = CommentModel.getCommentsFromJson(json["data"])
                self.comments.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                self.totalComments = json["total"].intValue
                DispatchQueue.main.async {
                    if self.productDetail != nil {
                        self.tableView.ts_reloadData { }
                    }
                }
            } else {
                // try again...
                HomeAPI.shared.commentItem(page: self.page, params: parameters, completion: { (json, success1) in
                    self.endFooterRefresh()
                    if success1 {
                        if resetData {
                            self.comments = []
                            ProgressHUD.dismiss()
                        }
                        let tempList = CommentModel.getCommentsFromJson(json["data"])
                        self.comments.append(contentsOf: tempList)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        self.totalComments = json["total"].intValue
                    }
                    DispatchQueue.main.async {
                        if self.productDetail != nil {
                            self.tableView.ts_reloadData { }
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
        
        if isSelectedImageDetails {
            self.tableView.mj_footer = nil
        } else {
            self.tableView.mj_footer = refreshFooter
        }
        
    }
    
    private func footerRefreshing() {
        self.loadComments(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    private func setupCustomView() {
        self.view.addSubview(cartView)
        cartView.translatesAutoresizingMaskIntoConstraints = false
        cartView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.height.equalTo(150)
            make.bottom.equalTo(self.view).offset(150)
        }
        cartViewLabel.text = "\(cartOrderCount)"
    }
    
    @IBAction func selectToolbar1(_ sender: UIButton) {
        if let store = productDetail.store, !store.name!.isEmpty {
            
            if senderVC != nil && senderVC == NearbyVC.nameOfClass {
                let vc = UIStoryboard(name: "Nearby", bundle: nil).instantiateViewController(withIdentifier: NearbyStoreDetailVC.nameOfClass) as! NearbyStoreDetailVC
                vc.storeId = self.productDetail.store?.storeId
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
                vc.storeId = self.productDetail.store?.storeId
                self.navigationController?.pushViewController(vc, animated: true)
            }            
        }
    }
    
    @IBAction func selectToolbar2(_ sender: UIButton) {
        if !UserInstance.isLogin {
            goToLoginVC()
            return
        }
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        self.presentAlert("你真的想聊天吗?") {
            self.presentChatVC()
        }
    }
    
    // go to bucket!
    @IBAction func selectToolbar3(_ sender: UIButton) {
        if !UserInstance.isLogin {
           goToLoginVC()
            return
        }
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        //self.processItemFavorite()
        
        // Changing Favorite to Bucket!
        if let store = productDetail.store, !store.name!.isEmpty {
            let parameters: [String : Any] = [
                "id" : self.productDetail.id!,
                "count" : 1
            ]
            MyAPI.shared.cartAdd(params: parameters) { (json, success) in
                if success {
                    ProgressHUD.showSuccessWithStatus("添加成功")
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
    
    //click cart view
    @IBAction func selectToolbar4(_ sender: UIButton) {
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录添加到购物车!")
            return
        }
        
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        
        if let store = productDetail.store, !store.name!.isEmpty {
            self.isSelectedCart = true
            self.showCartView()
        }
    }
    
    //click order view
    @IBAction func selectToolbar5(_ sender: UIButton) {
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录立即购买!")
            return
        }
        
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        
        if let store = productDetail.store, !store.name!.isEmpty {
            self.isSelectedCart = false
            self.showCartView()
        }
    }
    
       
    
    @IBAction func selectCartViewClose(_ sender: Any) {
        self.hideCartView()
    }
    
    @IBAction func selectCartViewConfirm(_ sender: Any) {
        self.hideCartView()
        if self.isSelectedCart {
            let parameters: [String : Any] = [
                "id" : self.productDetail.id!,
                "count" : self.cartOrderCount
            ]
            MyAPI.shared.cartAdd(params: parameters) { (json, success) in
                if success {
                    ProgressHUD.showSuccessWithStatus("添加成功")
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
        } else {
            /*if productDetail.qrimage! != "" {
             presentOrderAlert()
             } else {
             goToBuyVC()
             }*/
            goToBuyVC()
        }
        
    }
    
    @IBAction func selectCartViewPlus(_ sender: Any) {
        self.cartOrderCount += 1
        self.cartViewLabel.text = "\(cartOrderCount)"
    }
    
    @IBAction func selectCartViewMinus(_ sender: Any) {
        if self.cartOrderCount > 1 {
            self.cartOrderCount -= 1
            self.cartViewLabel.text = "\(cartOrderCount)"
        }
    }
    
    
    
    @objc func selectDarkView() {
        self.hideCartView()
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
    
    private func hideCartView() {
        cartView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(150)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    private func showCartView() {
        self.cartOrderCount = 1
        self.cartViewLabel.text = "\(cartOrderCount)"
        
        self.cartView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    func tapProductImageView(_ index: Int) {
        var images = [SKPhoto]()
        for imageUrl in productDetail.images! {
            let photo = SKPhoto.photoWithImageURL(imageUrl, holder: nil)//SKPhoto.photoWithImageURL(API.IMAGE_URL + imageUrl, holder: nil)
            images.append(photo)
        }
        
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: index)
        self.present(browser, animated: true) { }
    }
    
    func sendComment() {
        commentTextView.resignFirstResponder()
        let commentText = commentTextView.text.trimmingCharacters(in: CharacterSet.whitespaces)
        if commentText.count == 0 {
            ProgressHUD.showWarningWithStatus("不能发送空白消息")
            return
        }
        
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录添加到评论!")
            self.commentTextView.text = ""
            self.commentHeightConstraint.constant = commentTextView.contentSize.height
            self.commentTextView.layoutSubviews()
            return
        }
        
        let parameters: [String : Any] = [
            "id" : productDetail.id!,
            "text" : commentText,
            "rate" : 4
        ]
        HomeAPI.shared.commentAdd(params: parameters) { (json, success) in
            if success {
                self.commentTextView.text = ""
                self.commentHeightConstraint.constant = self.commentTextView.contentSize.height
                self.commentTextView.layoutSubviews()
                print("Comment Add...")
                print(json)
                ProgressHUD.showSuccessWithStatus("成功添加评论")
                self.productDetail.commentsCount! += 1
                self.loadComments(resetData: true, loadFirst: false)
            } else {
                // try again...
                HomeAPI.shared.commentAdd(params: parameters, completion: { (json, success1) in
                    self.commentTextView.text = ""
                    self.commentHeightConstraint.constant = self.commentTextView.contentSize.height
                    self.commentTextView.layoutSubviews()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功添加评论")
                        self.productDetail.commentsCount! += 1
                        self.loadComments(resetData: true, loadFirst: false)
                    } else {
                        ProgressHUD.showErrorWithStatus("未能添加评论")
                    }
                })
            }
        }
    }
    
    func goToBuyVC() {
        let itemString = "[\"[" + String(self.productDetail.id!) + ", \(self.cartOrderCount)]\"]"
        print("Item String...", itemString)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyVC.nameOfClass) as! MyBuyVC
        vc.items = itemString
        vc.products = [self.productDetail]
        vc.productCounts = [self.cartOrderCount]
        vc.paymentType = self.productDetail.paymentType!
        
        self.pushAndHideTabbar(vc)
    }
    
    func showCommentFrame(_ show: Bool) {
        commentFrame.isHidden = !show
        commentTextView.isHidden = !show
        commentWriteImageView.isHidden = !show
        commentTextBorder.isHidden = !show
        commentSendButton.isHidden = !show
        commentSendImageView.isHidden = !show
        commentSendRoundView.isHidden = !show
        
        if show {
            commentFrameHeightConstranit.constant = 44
        } else {
            commentFrameHeightConstranit.constant = 0
        }
    }
    
    
    func changeTab(_ index: Int) { // index 0 -> images, 1 -> comments
        if index == 0 {
            self.isSelectedImageDetails = true
            //self.showCommentFrame(false)
            self.setupRefresh()
            self.tableView.reloadData()
        } else {
            self.isSelectedImageDetails = false
            //self.showCommentFrame(true)
            self.setupRefresh()
            self.loadComments(resetData: true, loadFirst: true)
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
        let userId = productDetail.user?.id
        if let id = userId, id > 0 {
            let parameters: [String : Any] = [
                "ids" : [id]
            ]
            ProgressHUD.showWithStatus()
            SocialAPI.shared.chatCreate(params: parameters, completion: { (json, success) in
                if success {
                    print("Chat Create...")
                    print(json)
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
        let productName = productDetail.name!
        let productId = productDetail.id!
        //let deepLink = "http://paikepaifu.product.cn/\(productId)"//"paishop://product/\(productId)"
        let deepLink = "http://paikepaifu.cn/share?product=\(productId)"
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
    
    private func processItemFavorite() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        let parameters: [String : Any] = [
            "id" : self.itemId
        ]
        ProgressHUD.showWithStatus()
        if self.productDetail.favorites! > 0 {
            // favorite delete
            HomeAPI.shared.itemFavoriteDelete(params: parameters) { (json, success) in
                ProgressHUD.dismiss()
                if success {
                    self.productDetail.favorites = 0
                    if self.productDetail.favoritesCount! > 0 {
                        self.productDetail.favoritesCount = self.productDetail.favoritesCount! - 1
                    }
                    self.toolbar3ImageView.image = UIImage(named: "ic_home_star")
                    self.toolbar3ImageView.setTintColor(UIColor.black)
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
        } else {
            //favorite add
            HomeAPI.shared.itemFavoriteAdd(params: parameters) { (json, success) in
                ProgressHUD.dismiss()
                if success {
                    self.productDetail.favorites = 1
                    self.productDetail.favoritesCount = self.productDetail.favoritesCount! + 1
                    self.toolbar3ImageView.image = UIImage(named: "ic_home_star_filled")
                    self.toolbar3ImageView.setTintColor(UIColor.init(colorWithHexValue: 0xff3e03))
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
    
}


extension HomeProductDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        commentHeightConstraint.constant = textView.contentSize.height
        textView.layoutSubviews()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView == commentTextView {
                //send comment
                self.sendComment()
            }
            return false
        }
        return true
    }
}

extension HomeProductDetailVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        commentTextView.resignFirstResponder()
        commentTextView.text = ""
    }
}

extension HomeProductDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            if isSelectedImageDetails {
                return self.productImageStrings.count
            }
            return self.comments.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: HomeProductDetailTopCell = tableView.ts_dequeueReusableCell(HomeProductDetailTopCell.self)
            if self.productDetail != nil {
                cell.setCellContent(productDetail, vc: self)
            }
            return cell
        case 1:
            let cell: HomeProductDetailTabCell = tableView.ts_dequeueReusableCell(HomeProductDetailTabCell.self)
            cell.setCellContent(self)
            return cell
        case 2:
            if isSelectedImageDetails {
                let cell: HomeProductDetailImageCell = tableView.ts_dequeueReusableCell(HomeProductDetailImageCell.self)
                let index = indexPath.row
                cell.setCellContent(self.productImageStrings[index], index: index, vc: self)
                return cell
            }
            let cell: HomeProductDetailCommentCell = tableView.ts_dequeueReusableCell(HomeProductDetailCommentCell.self)
            cell.setCellContent(comments[indexPath.row], parentVC: self)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
}

extension HomeProductDetailVC: NavBarDelegate {
    func didSelectBack() {
        if self.senderVC != nil && self.senderIndex != nil {
            let info: [String : Any] = [
                "senderVC" : self.senderVC!,
                "senderIndex" : self.senderIndex,
                "productDetail" : self.productDetail
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PRODUCT_DETAIL_CHANGE), object: nil, userInfo: info)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}


/*
class HomeProductDetailVC: UIViewController {
    
    var itemId: Int64!
    var senderVC: String?
    var senderIndex: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(HomeProductDetailCell.self)
            tableView.ts_registerCellNib(HomeProductDetailImageCell.self)
            tableView.ts_registerCellNib(HomeProductDetailInfoCell.self)
            tableView.ts_registerCellNib(HomeProductDetailCommentTitleCell.self)
            tableView.ts_registerCellNib(HomeProductDetailCommentCell.self)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 300
            tableView.tableFooterView = UIView()
        }
    }
    
    
    //Comment Post View
    @IBOutlet weak var commentFrame: UIView!
    @IBOutlet weak var commentTextView: UITextView! {
        didSet {
            commentTextView.delegate = self
            commentTextView.returnKeyType = .send
            commentTextView.placeholder = "评论"
            commentTextView.placeholderColor = UIColor.black
        }
    }
    @IBOutlet weak var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentFrameBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentSendButton: UIButton! 
    @IBOutlet weak var commentSendImageView: UIImageView! {
        didSet {
            commentSendImageView.setTintColor(UIColor.init(colorWithHexValue: 0x97977, alpha: 0.15))
        }
    }
    
    //Bottom Tab Bar
    @IBOutlet weak var tabBarFrame: UIView!
    @IBOutlet weak var cartButtonView: UIView!
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var chatButtonView: UIView!
    @IBOutlet weak var orderButton: UIButton!
    
    // Custom View
    @IBOutlet var cartView: UIView!
    @IBOutlet weak var cartViewLabel: UILabel!
    @IBOutlet weak var darkView: UIView!
    
    //Chat View
    @IBOutlet var chatPostView: UIView!
    @IBOutlet weak var chatTextView: UITextView! 
    
    //QRCode View
    @IBOutlet var qrcodeView: UIView!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    
    
    let disposeBag = DisposeBag()
    
    var productDetail: ProductDetailModel!
    var cartOrderCount = 1
    var productImageStrings: [String] = []
    var totalComments: Int = 0
    var comments: [CommentModel] = []
    var page = 1
    var isEndData = false
    
    var isSelectedCart = true // true - Cart, false - Order
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Nav bar set up
        navBar.lblTitle.text = "派世界"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        
        self.commentFrame.isHidden = true
        self.tabBarFrame.isHidden = true
        self.tableView.isHidden = true
        
        darkView.alpha = 0
        darkView.isHidden = true        
        
        self.setupRefresh()
        self.loadData()
        
        SKPhotoBrowserOptions.displayAction = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        self.productImageStrings = productDetail.images!
        self.tableView.ts_reloadData { }
        
        let cartTap = UITapGestureRecognizer(target: self, action: #selector(selectCart))
        cartButtonView.isUserInteractionEnabled = true
        cartButtonView.addGestureRecognizer(cartTap)
        
        let darkViewTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(darkViewTap)
        
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(selectShare))
        shareButtonView.isUserInteractionEnabled = true
        shareButtonView.addGestureRecognizer(shareTap)
        
        let chatTap = UITapGestureRecognizer(target: self, action: #selector(selectChat))
        chatButtonView.isUserInteractionEnabled = true
        chatButtonView.addGestureRecognizer(chatTap)
        
        self.setupCustomView()
        self.keyboardControl()
        self.setupCommentSendButton()
        
        if productDetail.user?.id == UserInstance.userId {
            commentTextView.isUserInteractionEnabled = false
            //orderButton.isEnabled = false
        }        
    }
    
    private func loadData() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        HomeAPI.shared.itemDetail(itemId: self.itemId) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                print("Item Detail.......")
                print(json)
                self.productDetail = ProductDetailModel.init(json["item"])
                self.commentFrame.isHidden = false
                self.tabBarFrame.isHidden = false
                self.tableView.isHidden = false
                self.setupUI()
            } else {
                //load again...
                HomeAPI.shared.itemDetail(itemId: self.itemId, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.productDetail = ProductDetailModel.init(json["item"])
                        self.commentFrame.isHidden = false
                        self.tabBarFrame.isHidden = false
                        self.tableView.isHidden = false
                        self.setupUI()
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
        
        self.loadComments(resetData: true, loadFirst: true)
    }
    
    private func loadComments(resetData: Bool, loadFirst: Bool) {
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
        
        let parameters: [String : Any] = [
            "id" : self.itemId
        ]
        HomeAPI.shared.commentItem(page: self.page, params: parameters) { (json, success) in
            if success {
                self.endFooterRefresh()
                print("Comment Item...")
                print(json)
                
                if resetData {
                    self.comments = []
                }
                let tempList = CommentModel.getCommentsFromJson(json["data"])
                self.comments.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                self.totalComments = json["total"].intValue
                DispatchQueue.main.async {
                    if self.productDetail != nil {
                        self.tableView.ts_reloadData { }
                    }
                }
            } else {
                // try again...
                HomeAPI.shared.commentItem(page: self.page, params: parameters, completion: { (json, success1) in
                    self.endFooterRefresh()
                    if success1 {
                        if resetData {
                            self.comments = []
                        }
                        let tempList = CommentModel.getCommentsFromJson(json["data"])
                        self.comments.append(contentsOf: tempList)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        self.totalComments = json["total"].intValue
                    }
                    DispatchQueue.main.async {
                        if self.productDetail != nil {
                            self.tableView.ts_reloadData { }
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
        self.loadComments(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    private func setupCustomView() {
        self.view.addSubview(cartView)
        cartView.translatesAutoresizingMaskIntoConstraints = false
        cartView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.height.equalTo(150)
            make.bottom.equalTo(self.view).offset(150)
        }
        cartViewLabel.text = "\(cartOrderCount)"
        
        self.view.addSubview(chatPostView)
        chatPostView.translatesAutoresizingMaskIntoConstraints = false
        chatPostView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(282)
            make.width.equalTo(300)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        chatTextView.placeholder = "请在这里写下"
        chatTextView.delegate = self
        
        let chatPostTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        chatPostView.isUserInteractionEnabled = true
        chatPostView.addGestureRecognizer(chatPostTap)
        
        self.view.addSubview(qrcodeView)
        qrcodeView.translatesAutoresizingMaskIntoConstraints = false
        qrcodeView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.width.height.equalTo(300)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        if productDetail.qrimage! != "" {
            qrcodeImageView.setImageWithURLString(productDetail.qrimage)
        }
        
        
        let qrcodeImageTap = UITapGestureRecognizer(target: self, action: #selector(presentQrcodeSheet))
        qrcodeImageView.isUserInteractionEnabled = true
        qrcodeImageView.addGestureRecognizer(qrcodeImageTap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @objc func selectDarkView() {
        self.hideCartView()
        self.hideChatView()
        self.hideQrcodeView()
    }
    
    @objc func selectCart() {
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录添加到购物车!")
            return
        }
        
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        
        if let store = productDetail.store, !store.name!.isEmpty {
            self.isSelectedCart = true
            self.showCartView()
        }
    }

    @IBAction func selectCartViewClose(_ sender: Any) {
        self.hideCartView()
    }
    
    @IBAction func selectCartViewConfirm(_ sender: Any) {
        self.hideCartView()
        if self.isSelectedCart {
            let parameters: [String : Any] = [
                "id" : self.productDetail.id!,
                "count" : self.cartOrderCount
            ]
            MyAPI.shared.cartAdd(params: parameters) { (json, success) in
                if success {
                    ProgressHUD.showSuccessWithStatus("添加成功")
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
        } else {
            /*if productDetail.qrimage! != "" {
                presentOrderAlert()
            } else {
                goToBuyVC()
            }*/
            goToBuyVC()
        }
        
    }
    
    @IBAction func selectCartViewPlus(_ sender: Any) {
        self.cartOrderCount += 1
        self.cartViewLabel.text = "\(cartOrderCount)"
    }
    
    @IBAction func selectCartViewMinus(_ sender: Any) {
        if self.cartOrderCount > 1 {
            self.cartOrderCount -= 1
            self.cartViewLabel.text = "\(cartOrderCount)"
        }
    }
    
    @objc func selectShare() {
        Utils.applyTouchEffect(shareButtonView)
        
        MonkeyKing.registerAccount(.weChat(appID: "wx987358b52f62b2ad", appKey: "e215123acf16ce7cee560820fdad895e", miniAppID: nil))
        let shareText = productDetail.name!
        //let deepLinkString = "paishop://product/\(itemId!)"
        let deepLinkString = "http://paikepaifu.cn/share?product=\(itemId!)"
        
        let deepLinkUrl = URL.init(string: deepLinkString)!
        
        print("DeepLink String,", deepLinkUrl)
        
        let info = MonkeyKing.Info(
            title: shareText,
            description: productDetail.description!,
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
    
    @objc func selectChat() {
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录聊天!")
            return
        }
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        Utils.applyTouchEffect(chatButtonView)
        self.presentAlert("你真的想聊天吗?") {
            self.presentChatVC()
        }
    }
    
    
    @objc func selectHeaderView() {
        if let store = productDetail.store, !store.name!.isEmpty {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = self.productDetail.store?.storeId
            self.pushAndHideTabbar(vc)
        }
    }
    
    @IBAction func selectOrder(_ sender: UIButton) {
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录立即购买!")
            return
        }
        
        if productDetail.user?.id == UserInstance.userId {
            ProgressHUD.showWarningWithStatus("这是你的产品!")
            return
        }
        
        if let store = productDetail.store, !store.name!.isEmpty {
            self.isSelectedCart = false
            self.showCartView()
        }        
    }
    
    @IBAction func selectChatClose(_ sender: UIButton) {
        self.hideChatView()
    }
    
    @IBAction func selectChatPost(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        let postText = chatTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if postText.count < 2 {
            ProgressHUD.showErrorWithStatus("请输入有效的内容.")
            return
        }
        
        //Create Chat Room
        let userId = productDetail.user?.id
        if let id = userId, id > 0 {
            let parameters: [String : Any] = [
                "ids" : [id]
            ]
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            SocialAPI.shared.chatCreate(params: parameters, completion: { (json, success) in
                if success {
                    print("Chat Create...")
                    print(json)
                    let chatListItem = ChatListModel(json["room"])
                    self.sendChatText(chatListItem)
                } else {
                    sender.isEnabled = true
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
        let productName = productDetail.name!
        let productId = productDetail.id!
        //let deepLink = "http://paikepaifu.product.cn/\(productId)"//"paishop://product/\(productId)"
        let deepLink = "http://paikepaifu.cn/share?product=\(productId)"
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
                self.hideChatView()
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
    
    
    
    func tapProductImageView(_ index: Int) {
        var images = [SKPhoto]()
        for imageUrl in productDetail.images! {
            let photo = SKPhoto.photoWithImageURL(imageUrl, holder: nil)//SKPhoto.photoWithImageURL(API.IMAGE_URL + imageUrl, holder: nil)
            images.append(photo)
        }
                
        let browser = SKPhotoBrowser(photos: images, initialPageIndex: index)
        self.present(browser, animated: true) { }
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
    
    private func hideCartView() {
        cartView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(150)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    private func showCartView() {
        self.cartOrderCount = 1
        self.cartViewLabel.text = "\(cartOrderCount)"
        
        Utils.applyTouchEffect(self.cartButtonView)
        self.cartView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func showQrcodeView() {
        qrcodeView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func hideQrcodeView() {
        qrcodeView.snp.updateConstraints { (make) in
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
    
    private func hideChatView() {
        chatTextView.text = ""
        chatTextView.resignFirstResponder()
        chatPostView.snp.updateConstraints { (make) in
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
    
    private func showChatView() {
        chatPostView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    func sendComment() {
        commentTextView.resignFirstResponder()
        let commentText = commentTextView.text.trimmingCharacters(in: CharacterSet.whitespaces)
        if commentText.count == 0 {
            ProgressHUD.showWarningWithStatus("不能发送空白消息")
            return
        }
        
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录添加到评论!")
            self.commentTextView.text = ""
            self.commentHeightConstraint.constant = commentTextView.contentSize.height
            self.commentTextView.layoutSubviews()
            return
        }
        
        let parameters: [String : Any] = [
            "id" : productDetail.id!,
            "text" : commentText,
            "rate" : 4
        ]
        HomeAPI.shared.commentAdd(params: parameters) { (json, success) in
            if success {
                self.commentTextView.text = ""
                self.commentHeightConstraint.constant = self.commentTextView.contentSize.height
                self.commentTextView.layoutSubviews()
                print("Comment Add...")
                print(json)
                ProgressHUD.showSuccessWithStatus("成功添加评论")
                self.productDetail.commentsCount! += 1
                self.loadComments(resetData: true, loadFirst: false)
            } else {
                // try again...
                HomeAPI.shared.commentAdd(params: parameters, completion: { (json, success1) in
                    self.commentTextView.text = ""
                    self.commentHeightConstraint.constant = self.commentTextView.contentSize.height
                    self.commentTextView.layoutSubviews()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功添加评论")
                        self.productDetail.commentsCount! += 1
                        self.loadComments(resetData: true, loadFirst: false)
                    } else {
                        ProgressHUD.showErrorWithStatus("未能添加评论")
                    }
                })
            }
        }
    }
        
    
    private func presentChatVC() {
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        //Create Chat Room
        let userId = productDetail.user?.id
        if let id = userId, id > 0 {
            let parameters: [String : Any] = [
                "ids" : [id]
            ]
            ProgressHUD.showWithStatus()
            SocialAPI.shared.chatCreate(params: parameters, completion: { (json, success) in
                if success {
                    //print("Chat Create...")
                    //print(json)
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
    
    func presentOrderAlert() {
        let alert = UIAlertController(title: title, message: "直接购买或使用二维码?", preferredStyle: .alert)
        let qrcodeAction = UIAlertAction(title: "二维码", style: .default) { (action) in
            self.showQrcodeView()
        }
        let buyAction = UIAlertAction(title: "立即购买", style: .default) { (action) in
            self.goToBuyVC()
        }
        alert.addAction(buyAction)
        alert.addAction(qrcodeAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToBuyVC() {
        let itemString = "[\"[" + String(self.productDetail.id!) + ", \(self.cartOrderCount)]\"]"
        print("Item String...", itemString)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyVC.nameOfClass) as! MyBuyVC
        vc.items = itemString
        vc.products = [self.productDetail]
        vc.productCounts = [self.cartOrderCount]
        vc.paymentType = self.productDetail.paymentType!
        
        self.pushAndHideTabbar(vc)
    }
    
    @objc func presentQrcodeSheet() {
        let sheet = UIAlertController(title: "二维码", message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "存储图像", style: .default) { (action) in
            self.hideQrcodeView()
            let qrcodeImage = self.qrcodeImageView.image!
            UIImageWriteToSavedPhotosAlbum(qrcodeImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            //self.hideQrcodeView()
        }
        sheet.addAction(saveAction)
        sheet.addAction(cancelAction)
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(sheet, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            ProgressHUD.showErrorWithStatus(error.localizedDescription)
        } else {
            ProgressHUD.showSuccessWithStatus("保存成功")
        }
    }
    
    
    func getFormattedDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: dateString)!
        let timeAgo = Date.timeAgoSinceDate(date, numericDates: true)
        
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([
            NSCalendar.Unit.minute,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.day,
            NSCalendar.Unit.weekOfYear,
            NSCalendar.Unit.month,
            NSCalendar.Unit.year,
            NSCalendar.Unit.second
            ], from: date)
        
        let dateString = timeAgo + "  " + String(components.month!) + "月" + String(components.day!) + "日  " + String(components.hour!) + ":" + String(components.minute!)
        return dateString
    }
}

extension HomeProductDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        commentHeightConstraint.constant = textView.contentSize.height
        textView.layoutSubviews()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView == chatTextView {
                self.view.endEditing(true)
            } else {
                //send comment
                self.sendComment()
            }
            return false
        }
        return true
    }
}

extension HomeProductDetailVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        commentTextView.resignFirstResponder()
    }
}



extension HomeProductDetailVC: NavBarDelegate {
    func didSelectBack() {
        if self.senderVC != nil {
            let info: [String : Any] = [
                "senderVC" : self.senderVC!,
                "senderIndex" : self.senderIndex,
                "productDetail" : self.productDetail
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PRODUCT_DETAIL_CHANGE), object: nil, userInfo: info)
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
}



extension HomeProductDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.productImageStrings.count
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return self.comments.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: HomeProductDetailCell = tableView.ts_dequeueReusableCell(HomeProductDetailCell.self)
            if self.productDetail != nil {
                cell.setCellContent(productDetail, vc: self)
            }
            return cell
        case 1:
            let cell: HomeProductDetailImageCell = tableView.ts_dequeueReusableCell(HomeProductDetailImageCell.self)
            let index = indexPath.row
            cell.setCellContent(self.productImageStrings[index], index: index, vc: self)//cell.setCellContent(API.IMAGE_URL + self.productImageStrings[index], index: index, vc: self)
            return cell
        case 2:
            let cell: HomeProductDetailInfoCell = tableView.ts_dequeueReusableCell(HomeProductDetailInfoCell.self)
            if self.productDetail != nil {
                cell.setCellContent(productDetail, vc: self)
            }
            return cell
        case 3:
            let cell: HomeProductDetailCommentTitleCell = tableView.ts_dequeueReusableCell(HomeProductDetailCommentTitleCell.self)
            cell.setCellContent(totalComments)
            return cell
        case 4:
            let cell: HomeProductDetailCommentCell = tableView.ts_dequeueReusableCell(HomeProductDetailCommentCell.self)
            cell.setCellContent(comments[indexPath.row], parentVC: self)
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
}

*/
















