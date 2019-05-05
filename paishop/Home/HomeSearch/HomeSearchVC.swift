
import UIKit
import MJRefresh

class HomeSearchVC: UIViewController {
    
    @IBOutlet weak var searchBar: LRSearchBar! {
        didSet {
            searchBar.delegate = self
            //searchBar.showsCancelButton = true
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(HomeListCell.self)
            tableView.decelerationRate = UIScrollView.DecelerationRate.fast
            tableView.isHidden = true
        }
    }
    
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    var products: [ProductListModel] = []
    var searchController: UISearchController!
    var page = 1
    var isEndData = false
    var keyword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.setupSearchController()
        self.setupRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveProductDetailBack(_:)), name: NSNotification.Name(Notifications.PRODUCT_DETAIL_CHANGE), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

   
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    @IBAction func selectBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func receiveProductDetailBack(_ notification: NSNotification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != HomeSearchVC.nameOfClass {
            return
        }
        
        guard let senderIndex = notification.userInfo?["senderIndex"] as? Int else { return }
        
        if let productDetail = notification.userInfo?["productDetail"] as? ProductDetailModel {
            if senderIndex < self.products.count {
                var productListItem = self.products[senderIndex]
                productListItem.views = productDetail.views
                productListItem.favoritesCount = productDetail.favoritesCount
                productListItem.favorites = productDetail.favorites
                productListItem.commentsCount = productDetail.commentsCount
                self.products[senderIndex] = productListItem
                
                self.tableView.ts_reloadData { }
            }
            
        }
        
    }
    
    private func loadProducts(resetData: Bool) {
        if self.keyword.count < 1 {
            self.endFooterRefresh()
            return
        }
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        if resetData {
            self.page = 1
            self.isEndData = false
            self.tableView.isHidden = true
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        let parameters: [String : Any] = [
            "keyword" : keyword
        ]
        HomeAPI.shared.itemSearch(page: self.page, params: parameters) { (json, success) in
            
            if success {
                self.endFooterRefresh()
                if resetData {
                    self.tableView.isHidden = false
                }
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
                    self.tableView.ts_reloadData {  }
                }
                
                if self.products.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
            } else {
                // try again...
                HomeAPI.shared.itemSearch(page: self.page, params: parameters, completion: { (json, success1) in
                    self.endFooterRefresh()
                    if resetData {
                        self.tableView.isHidden = false
                    }
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
                    
                    if self.products.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
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
        self.loadProducts(resetData: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension HomeSearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.count > 0 {
                self.keyword = searchText
                self.loadProducts(resetData: true)
            }
        }
    }
}

extension HomeSearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.keyword = searchText
            self.loadProducts(resetData: true)
        }
    }
}


extension HomeSearchVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeListCell = tableView.ts_dequeueReusableCell(HomeListCell.self)
        cell.setCellContent(products[indexPath.row], vc: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = self.products[indexPath.row].id!
        vc.senderVC = HomeSearchVC.nameOfClass
        vc.senderIndex = indexPath.row
        self.pushAndHideTabbar(vc)
    }
    
}











