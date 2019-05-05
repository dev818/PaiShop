
import UIKit
import SnapKit
import TimedSilver
import MJRefresh

class HomeListVC: UIViewController {
    
    let menuItemData: [(name: String, iconImage: UIImage)] = [
        ("家电", ImageAsset.home_menu_bar1.image),
        ("化妆", ImageAsset.home_menu_bar2.image),
        ("百货", ImageAsset.home_menu_bar3.image),
        ("服装", ImageAsset.home_menu_bar4.image),
        ("箱包", ImageAsset.home_menu_bar5.image),
        ("家纺", ImageAsset.home_menu_bar6.image),
        ("食晶", ImageAsset.home_menu_bar7.image),
        ("家装", ImageAsset.home_menu_bar8.image),
        ("电子", ImageAsset.home_menu_bar9.image),
        ("更多", ImageAsset.home_menu_bar10.image),
    ]
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBarView: ButtonBarView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //Tableview Setup
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(HomeListCell.self)
            tableView.tableFooterView = UIView()
            tableView.decelerationRate = UIScrollView.DecelerationRate.fast
        }
    }
    
    @IBOutlet weak var topMoveView: RoundRectView! {
        didSet {
            topMoveView.isHidden = true
        }
    }
    
    var settings = ButtonBarPagerTabStripSettings()
    var buttonBarItemSpec: ButtonBarItemSpec<UICollectionViewCell>!
    lazy private var cachedCellWidths: [CGFloat]? = { [unowned self] in
        //return self.calculateWidths()
        var itemNames = [String]()
        for (name, _) in self.menuItemData {
            itemNames.append(name)
        }
        return buttonBarView.calculateWidths(itemNames, buttonBarSpec: buttonBarItemSpec, settings: settings)
        }()
    var currentIndex = 0
    
    var categoryItems: [ProductListModel] = [] //var productLists: [ProductListModel] = []
    var categories: [CategoryModel] = []
    var page = 1
    var isEndData = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Nav bar set up
        navBar.lblTitle.text = "商品分类"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        
        self.setupButtonBarView()
        self.setupRefresh()
        self.loadCategoryItems(resetData: true, loadFirst: true)
        
        let topMoveTap = UITapGestureRecognizer(target: self, action: #selector(selectTopMove))
        topMoveView.isUserInteractionEnabled = true
        topMoveView.addGestureRecognizer(topMoveTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveProductDetailBack(_:)), name: NSNotification.Name(Notifications.PRODUCT_DETAIL_CHANGE), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadCategoryItems(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
            self.tableView.isUserInteractionEnabled = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            self.endHeaderRefresh()
            return
        }
        HomeAPI.shared.itemCategory(page: self.page, categoryId: self.categories[self.currentIndex].id!) { (json, success) in            
            if success {
                self.tableView.isUserInteractionEnabled = true
                self.endFooterRefresh()
                self.endHeaderRefresh()
                if loadFirst {
                    ProgressHUD.dismiss()
                }
                print("Item Category..........")
                print(json)
                if resetData {
                    self.categoryItems = []
                }
                let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                self.categoryItems.append(contentsOf: tempItems)
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
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData {  }
                })
            } else {
                // try again...
                HomeAPI.shared.itemCategory(page: self.page, categoryId: self.categories[self.currentIndex].id!, completion: { (json, success1) in
                    self.tableView.isUserInteractionEnabled = true
                    self.endFooterRefresh()
                    self.endHeaderRefresh()
                    if loadFirst {
                        ProgressHUD.dismiss()
                    }
                    if success1 {
                        if resetData {
                            self.categoryItems = []
                        }
                        let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                        self.categoryItems.append(contentsOf: tempItems)
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
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData {  }
                        })
                    }
                })
            }
        }
    }
    
    @objc func selectTopMove() {
        Utils.applyTouchEffect(topMoveView)
        
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func receiveProductDetailBack(_ notification: NSNotification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != HomeListVC.nameOfClass {
            return
        }
        
        guard let senderIndex = notification.userInfo?["senderIndex"] as? Int else { return }
        
        if let productDetail = notification.userInfo?["productDetail"] as? ProductDetailModel {
            if senderIndex < self.categoryItems.count {
                var categoryListItem = self.categoryItems[senderIndex]
                categoryListItem.views = productDetail.views
                categoryListItem.favoritesCount = productDetail.favoritesCount
                categoryListItem.favorites = productDetail.favorites
                categoryListItem.commentsCount = productDetail.commentsCount
                self.categoryItems[senderIndex] = categoryListItem
                
                self.tableView.ts_reloadData { }
            }
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    private func setupRefresh() {
        let refreshHeader = MJRefreshNormalHeader {
            self.headerRefreshing()
        }
        refreshHeader?.lastUpdatedTimeLabel.isHidden = true
        refreshHeader?.setTitle("拉下来刷新", for: MJRefreshState.idle)
        refreshHeader?.setTitle("释放以刷新", for: .pulling)
        refreshHeader?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_footer = refreshFooter
    }
    
    private func headerRefreshing() {
        self.loadCategoryItems(resetData: true, loadFirst: false)
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.endHeaderRefresh()
        }*/
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        //refresh data
        self.loadCategoryItems(resetData: false, loadFirst: false)
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.endFooterRefresh()
        }*/
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    
    private func setupButtonBarView() {
        if Utils.isIpad() {
            buttonBarView.snp.makeConstraints({ (make) in
                make.height.equalTo(120)
            })
        } else {
            buttonBarView.snp.makeConstraints({ (make) in
                make.height.equalTo(80)
            })
        }
        
        settings.style.buttonBarBackgroundColor = MainColors.buttonBarBgColor
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: ButtonBarTitleAndImageCell.nameOfClass, bundle: Bundle(for: ButtonBarTitleAndImageCell.self), width: { [weak self] (itemTitle) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont
            label.text = itemTitle
            let labelSize = label.intrinsicContentSize
            return labelSize.width + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
        })
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.style.buttonBarMinimumInteritemSpacing
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: settings.style.buttonBarLeftContentInset , bottom: sectionInset.bottom, right: settings.style.buttonBarRightContentInset )
        //let cellWidth = UIScreen.ts_width / 5
        //flowLayout.itemSize = CGSize(width: cellWidth, height: self.buttonBarView.ts_height + 50)
        
        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor 
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        
        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight
        buttonBarView.selectedBarVerticalAlignment = settings.style.selectedBarVerticalAlignment
        
        //register button bar item cell
        switch buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"ButtonBarViewCell")
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: ButtonBarTitleAndImageCell.customId)
        case .cellClass:
            buttonBarView.register(ButtonBarTitleAndImageCell.self, forCellWithReuseIdentifier:ButtonBarTitleAndImageCell.customId)
        }
        
        self.view.layoutIfNeeded()
        
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
        let selectedIndexPath = IndexPath(item: currentIndex, section: 0)
        self.buttonBarView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func cellForItems(at indexPaths: [IndexPath], reloadIfNotVisible reload: Bool = true) -> [ButtonBarTitleAndImageCell?] {
        let cells = indexPaths.map { buttonBarView.cellForItem(at: $0) as? ButtonBarTitleAndImageCell }
        
        if reload {
            let indexPathsToReload = cells.enumerated()
                .compactMap { (arg) -> IndexPath? in
                    let (index, cell) = arg
                    return cell == nil ? indexPaths[index] : nil
                }
                .compactMap { (indexPath: IndexPath) -> IndexPath? in
                    return (indexPath.item >= 0 && indexPath.item < buttonBarView.numberOfItems(inSection: indexPath.section)) ? indexPath : nil
            }
            
            if !indexPathsToReload.isEmpty {
                buttonBarView.reloadItems(at: indexPathsToReload)
            }
        }
        
        return cells
    }

}


extension HomeListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonBarTitleAndImageCell.customId, for: indexPath) as? ButtonBarTitleAndImageCell else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        
        let category = self.categories[indexPath.item]
        
        cell.itemLabel.text = category.name
        cell.itemLabel.font = settings.style.buttonBarItemFont
        // h.g.n
        cell.itemImage.image = checkImgExtention(imageURL: category.imageURL!)
        //cell.itemImage.setImageWithURLString(category.imageURL)
        
        if indexPath.item == self.currentIndex {
            cell.itemLabel.textColor = settings.style.buttonBarItemSelectedTitleColor
            //cell.itemImage.setTintColor(settings.style.buttonBarItemSelectedTitleColor)
        } else {
            cell.itemLabel.textColor = settings.style.buttonBarItemTitleColor
            //cell.itemImage.setTintColor(UIColor.white)
        }
        
        cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor
        cell.backgroundColor = settings.style.buttonBarItemBackgroundColor
        
        return cell
    }
    
    @objc open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        /*guard let cellWidthValue = cachedCellWidths?[indexPath.row] else {
            fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
        }
        return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)*/
        
        let cellWidth = UIScreen.ts_width / 5
        /*var cellHeight: CGFloat = 70
        if Utils.isIpad() {
            cellHeight = 100
        }*/
        return CGSize(width: cellWidth, height: self.buttonBarView.ts_height - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //guard indexPath.item != currentIndex else { return }
        
        buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        
        //let oldIndexPath = IndexPath(item: currentIndex, section: 0)
        //let newIndexPath = IndexPath(item: indexPath.item, section: 0)
        if currentIndex != indexPath.item {
            self.categoryItems = []
            self.currentIndex = indexPath.item
            self.tableView.ts_reloadData {
                self.loadCategoryItems(resetData: true, loadFirst: true)
            }
            
        }
        
        /*let oldCell = self.buttonBarView.cellForItem(at: oldIndexPath)
        if oldCell != nil {
            (oldCell as! ButtonBarTitleAndImageCell).itemLabel.textColor = settings.style.buttonBarItemTitleColor
            (oldCell as! ButtonBarTitleAndImageCell).itemImage.setTintColor(UIColor.white)
        }
        let newCell = collectionView.cellForItem(at: newIndexPath) as! ButtonBarTitleAndImageCell
        newCell.itemLabel.textColor = settings.style.buttonBarItemSelectedTitleColor
        newCell.itemImage.setTintColor(settings.style.buttonBarItemSelectedTitleColor)*/
        
        self.buttonBarView.reloadData()
        
    }
    
}



extension HomeListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeListCell = tableView.ts_dequeueReusableCell(HomeListCell.self)
        let productList = self.categoryItems[indexPath.row]
        cell.setCellContent(productList, vc: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = self.categoryItems[indexPath.row].id!
        vc.senderVC = HomeListVC.nameOfClass
        vc.senderIndex = indexPath.row
        self.pushAndHideTabbar(vc)
    }
    
}





extension HomeListVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }    
}


















