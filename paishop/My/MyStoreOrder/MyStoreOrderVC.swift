

import UIKit
import MJRefresh
import SwiftyJSON
import XLPagerTabStrip

class MyStoreOrderVC: ButtonBarPagerTabStripViewController {
    //var selectedIndex = 0
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        
        settings.style.buttonBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = UIColor.white
        settings.style.selectedBarBackgroundColor = MainColors.themeEndColors[selectedTheme]
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = {(oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = .black
            
        }
        
        super.viewDidLoad()
        self.setupNavBar()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "店铺订单"  //"所有订单"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let tab1 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderTab1VC.nameOfClass) as! MyStoreOrderTab1VC
        tab1.itemInfo = "全部"
        tab1.status = 0
        
        let tab2 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderTab1VC.nameOfClass) as! MyStoreOrderTab1VC
        tab2.itemInfo = "待发货"
        tab2.status = 2
        
        let tab3 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderTab1VC.nameOfClass) as! MyStoreOrderTab1VC
        tab3.itemInfo = "已发货"
        tab3.status = 3
        
        let tab4 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderTab1VC.nameOfClass) as! MyStoreOrderTab1VC
        tab4.itemInfo = "已完成"
        tab4.status = 1
        
        let tab5 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderTab1VC.nameOfClass) as! MyStoreOrderTab1VC
        tab5.itemInfo = "退货申请"
        tab5.status = 4
        
        return [ tab1, tab2, tab3, tab4, tab5]
    }
    
    
}

extension MyStoreOrderVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


/*
class MyStoreOrderVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyStoreOrderCell.self)
        }
    }    
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    
    var orderItems: [OrderItemModel] = []
    var page = 1
    var isEndData = false
    var selectedOrderIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.setupRefresh()
        self.loadOrderItems(resetData: true, loadFirst: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderDetailChange(_:)), name: NSNotification.Name(Notifications.STORE_ORDER_CHANGE), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "所有订单"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func loadOrderItems(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showErrorWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
            self.tableView.isHidden = true
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            //self.endHeaderRefresh()
            return
        }
        
        var status = 0
        switch selectedOrderIndex {
        case 0:
            status = 0
        case 1:
            status = 2
        case 2:
            status = 3
        case 3:
            status = 1
        default:
            break
        }
        
        var parameters: [String : Any] = [
            "type" : true
        ]
        if status > 0 {
            parameters["status"] = status
        }
        MyAPI.shared.orderList(page: self.page, params: parameters) { (json, success) in
            if success {
                self.endFooterRefresh()
                //self.endHeaderRefresh()
                self.tableView.isHidden = false
                if loadFirst {
                    ProgressHUD.dismiss()
                }
                print("Order All...")
                print(json)
                if resetData {
                    self.orderItems = []
                }
                let orderAllJson = json["data"].arrayValue
                if orderAllJson.count > 0 {
                    let tempItems = self.getOrderItems(orderAllJson)
                    self.orderItems.append(contentsOf: tempItems)
                }
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.ts_reloadData { }
                }
                if self.orderItems.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                    self.tableView.isHidden = true
                }
            } else {
                // try again...
                MyAPI.shared.orderList(page: self.page, params: parameters, completion: { (json, success1) in
                    self.endFooterRefresh()
                    //self.endHeaderRefresh()
                    self.tableView.isHidden = false
                    if loadFirst {
                        ProgressHUD.dismiss()
                    }
                    if success1 {
                        if resetData {
                            self.orderItems = []
                        }
                        let orderAllJson = json["data"].arrayValue
                        if orderAllJson.count > 0 {
                            let tempItems = self.getOrderItems(orderAllJson)
                            self.orderItems.append(contentsOf: tempItems)
                        }
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
                })
                
                DispatchQueue.main.async {
                    self.tableView.ts_reloadData { }
                }
                if self.orderItems.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                    self.tableView.isHidden = true
                }
            }
        }        
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        self.selectedOrderIndex = selectedIndex
        self.loadOrderItems(resetData: true, loadFirst: true)
    }
    
    
    @objc func orderDetailChange(_ notification: NSNotification) {
        guard let orderIndex = notification.userInfo?["orderIndex"] as? Int else { return }
        guard let orderStatus = notification.userInfo?["orderStatus"] as? Int else { return }
        if self.orderItems.count > orderIndex {
            self.orderItems[orderIndex].order.status = orderStatus
            self.tableView.ts_reloadData {      }
        }
    }
    
    private func getOrderItems(_ jsons: [JSON]) -> [OrderItemModel] {
        var tempItems: [OrderItemModel] = []
        for json in jsons {
            let product = ProductListModel.init(json["item"])
            let order = OrderModel.init(json)
            let orderItem = OrderItemModel.init(product: product, order: order)
            tempItems.append(orderItem)
        }
        
        return tempItems
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
        self.loadOrderItems(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

}


extension MyStoreOrderVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyStoreOrderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyStoreOrderCell = tableView.ts_dequeueReusableCell(MyStoreOrderCell.self)
        cell.setCellContent(orderItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderId = orderItems[indexPath.row].order.id!
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderDetailVC.nameOfClass) as! MyStoreOrderDetailVC
        vc.orderId = orderId
        vc.orderIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

*/











