
import UIKit
import MJRefresh
import SKPhotoBrowser

class MyStoreProductManageVC: UIViewController {
    
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    let itemsPerRow = 2
    
    @IBOutlet weak var plsBtnImage: UIImageView! {
        didSet {
            plsBtnImage.setTintColor(UIColor.white)
        }
    }
    @IBOutlet weak var searchImage: UIImageView! {
        didSet {
            plsBtnImage.setTintColor(UIColor.white)
        }
    }    
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.ts_registerCellNib(MyStoreProductManageCell.self)
        }
    }
    @IBOutlet weak var productTableView: UITableView! {
        didSet {
            productTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            productTableView.isHidden = true
            productTableView.ts_registerCellNib(MyStoreProductManageListCell.self)
        }
    }
    
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    @IBOutlet weak var navBarHeightConstraint1: NSLayoutConstraint!
    @IBOutlet weak var allUnderline: UIView!
    @IBOutlet weak var subUnderline: UIView! {
        didSet {
            subUnderline.isHidden = true
        }
    }
    
    @IBOutlet weak var categoryTableView: UITableView! {
        didSet {
            categoryTableView.isHidden = true
        }
    }
    
    var products: [ProductListModel] = []
    var page = 1
    var isEndData = true
    var editingIndex = -1
    var categoryName: [String] = ["食品","家用电器"]
    var isListLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        
        SKPhotoBrowserOptions.displayAction = false
        
        self.loadProducts(resetData: true, loadFirst: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveEditingNotification(_:)), name: NSNotification.Name(Notifications.STORE_ITEM_EDIT), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "商品管理"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
            navBarHeightConstraint1.constant = 88
        }
    }

    private func loadProducts(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
            self.collectionView.isUserInteractionEnabled = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            self.endHeaderRefresh()
            return
        }
        MyAPI.shared.itemMine(page: self.page) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if resetData {
                self.collectionView.isUserInteractionEnabled = true
            }
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Item Mine...")
                print(json)
                if resetData {
                    self.products = []
                }
                let tempList = ProductListModel.getProductListsFromJson(json["data"])
                self.products.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.productTableView.reloadData()
                }
                if self.products.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
            } else {
                // try again...
                MyAPI.shared.itemMine(page: self.page, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.products = []
                        }
                        let tempList = ProductListModel.getProductListsFromJson(json["data"])
                        self.products.append(contentsOf: tempList)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    if self.products.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
                    }
                })
            }            
        }
        
    }
    
    
    @objc func receiveEditingNotification(_ notification: Notification) {
        if let success = notification.userInfo?["success"] as? Bool, success {
            self.loadProducts(resetData: true, loadFirst: false)
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
        self.collectionView.mj_header = refreshHeader
        
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.collectionView.mj_footer = refreshFooter
    }
    
    private func headerRefreshing() {
        self.loadProducts(resetData: true, loadFirst: false)
    }
    
    private func footerRefreshing() {
        self.loadProducts(resetData: false, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.collectionView.mj_header.endRefreshing()
    }
    
    private func endFooterRefresh() {
        self.collectionView.mj_footer.endRefreshing()
    }
    
    @IBAction func showAllSelected(_ sender: UIButton) {
        allUnderline.isHidden = false
        subUnderline.isHidden = true
        categoryTableView.isHidden = true
    }
    
    @IBAction func showCateSelected(_ sender: UIButton) {
        allUnderline.isHidden = true
        subUnderline.isHidden = false
    }
    
    @IBAction func cateDropdownTapped(_ sender: UIButton) {
        categoryTableView.isHidden = !(categoryTableView.isHidden)
        allUnderline.isHidden = true
        subUnderline.isHidden = false
    }
    
    @IBAction func showMethodTapped(_ sender: UIButton) {
        self.isListLayout = !self.isListLayout
        if !(self.isListLayout) {
            self.productTableView.isHidden = true
            self.collectionView.isHidden =  false
            self.collectionView.reloadData()
        } else {
            self.collectionView.isHidden =  true
            self.productTableView.isHidden = false
            self.productTableView.reloadData()
        }
    }
    
}


extension MyStoreProductManageVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == categoryTableView {
            return categoryName.count
        } else {
            return self.products.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == categoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyStoreProductCateCell
            cell.productCategoryLabel.text = categoryName[indexPath.row]
            return cell
        } else {
            let cell: MyStoreProductManageListCell = tableView.ts_dequeueReusableCell(MyStoreProductManageListCell.self)
            cell.setCellContent(self.products[indexPath.item], index: indexPath.item, vc: self)
            return cell  
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == categoryTableView {
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .checkmark
                }
            }
        }
    }
    
}

extension MyStoreProductManageVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyStoreProductManageCell = collectionView.ts_dequeueReusableCell(MyStoreProductManageCell.self, forIndexPath: indexPath)
        cell.setCellContent(self.products[indexPath.item], index: indexPath.item, vc: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = self.view.ts_width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        
        let heightPerItem = widthPerItem + 70
        
        return CGSize(width: widthPerItem - 1, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}


extension MyStoreProductManageVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

















