
import UIKit
import MJRefresh

class MyFavorStoresVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyFavorStoreCell.self)
        }
    }    
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    var stores: [StoreDetailModel] = []
    var page = 1
    var isEndData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        self.loadFavoriteStores(resetData: true, loadFirst: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStoreDetailBack(_:)), name: NSNotification.Name(Notifications.STORE_DETAIL_CHANGE), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "收藏店铺"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func loadFavoriteStores(resetData: Bool, loadFirst: Bool) {
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
            //self.endHeaderRefresh()
            return
        }
        
        HomeAPI.shared.storeFavoriteList(page: self.page) { (json, success) in
            self.endFooterRefresh()
            //self.endHeaderRefresh()
            self.tableView.isUserInteractionEnabled = true
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Store Favorite List...")
                print(json)
                if resetData {
                    self.stores = []
                }
                let tempItems = StoreDetailModel.getStoreDetailsFromJson(json["data"])
                self.stores.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.ts_reloadData {  }
                }
                if self.stores.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
            } else {
                // try again...
                HomeAPI.shared.storeFavoriteList(page: self.page, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.stores = []
                        }
                        let tempItems = StoreDetailModel.getStoreDetailsFromJson(json["data"])
                        self.stores.append(contentsOf: tempItems)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
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
                    DispatchQueue.main.async {
                        self.tableView.ts_reloadData {  }
                    }
                    if self.stores.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
                    }
                })
            }            
        }
    }
    
    private func deleteFavor(_ storeId: Int64, indexPath: IndexPath) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        let parameters: [String : Any] = [
            "id" : storeId
        ]
        ProgressHUD.showWithStatus()
        HomeAPI.shared.storeFavoriteDelete(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                ProgressHUD.showSuccessWithStatus("成功!")
                self.stores.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                if self.stores.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
            } else {
                // try again...
                HomeAPI.shared.storeFavoriteDelete(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("成功!")
                        self.stores.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
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
                    
                    if self.stores.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
                    }
                })
            }
        }
    }
    
    @objc func receiveStoreDetailBack(_ notification: NSNotification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyFavorStoresVC.nameOfClass {
            return
        }
        
        guard let senderIndex = notification.userInfo?["senderIndex"] as? Int else { return }
        
        if let storeDetail = notification.userInfo?["storeDetail"] as? StoreDetailModel {
            if senderIndex < self.stores.count {
                let favorites = storeDetail.favorites!
                if favorites < 1 {
                    self.stores.remove(at: senderIndex)
                    self.tableView.ts_reloadData {
                        if self.stores.count > 0 {
                            self.noDataView.isHidden = true
                        } else {
                            self.noDataView.isHidden = false
                        }
                    }
                }
            }
        }
        
    }
    
    private func setupRefresh() {
        /*let refreshHeader = MJRefreshNormalHeader {
            self.headerRefreshing()
        }
        refreshHeader?.lastUpdatedTimeLabel.isHidden = true
        refreshHeader?.setTitle("拉下来刷新", for: MJRefreshState.idle)
        refreshHeader?.setTitle("释放以刷新", for: .pulling)
        refreshHeader?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_header = refreshHeader*/
        
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_footer = refreshFooter
    }
    
    /*private func headerRefreshing() {
        self.loadFavoriteStores(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }*/
    
    private func footerRefreshing() {
        self.loadFavoriteStores(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

}


extension MyFavorStoresVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyFavorStoresVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyFavorStoreCell = tableView.ts_dequeueReusableCell(MyFavorStoreCell.self)
        cell.setCellContent(stores[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
        vc.storeId = stores[indexPath.row].storeId!
        vc.senderVC = MyFavorStoresVC.nameOfClass
        vc.senderIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteFavor(stores[indexPath.row].storeId!, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}














