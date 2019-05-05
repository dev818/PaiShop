

import UIKit
import MJRefresh
import SwiftyJSON
import XLPagerTabStrip


class MyOrderMineVC: ButtonBarPagerTabStripViewController {
    
    var selectedIndex = 0
    
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        
        settings.style.buttonBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = UIColor.white
        settings.style.selectedBarBackgroundColor = MainColors.themeEndColors[selectedTheme]
        //settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.buttonBarItemFont = .systemFont(ofSize: 15)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.moveToVC()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //moveToViewController(at: selectedIndex, animated: false)
    }
    
    private func moveToVC() {
        loadRecmFirst = true
        moveToViewController(at: self.selectedIndex, animated: false)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "我的订单"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let tab1 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineTab1VC.nameOfClass) as!MyOrderMineTab1VC
        tab1.itemInfo = "全部"
        let tab2 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineTab2VC.nameOfClass) as!MyOrderMineTab2VC
        tab2.itemInfo = "待付款"
        let tab3 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineTab3VC.nameOfClass) as!MyOrderMineTab3VC
        tab3.itemInfo = "待发货"
        let tab4 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineTab4VC.nameOfClass) as!MyOrderMineTab4VC
        tab4.itemInfo = "待收货"
        let tab5 = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineTab5VC.nameOfClass) as!MyOrderMineTab5VC
        tab5.itemInfo = "待评价"
        
        
        return [tab1, tab2, tab3, tab4, tab5]
        
    }
    
    
}


extension MyOrderMineVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}




/*
class MyOrderMineVC: UIViewController {
    
    var selectedSegmentedIndex = 0
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            //tableView.tableFooterView?.backgroundColor = UIColor(colorWithHexValue: 0xECEBEB)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyOrderMineCell.self)
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var orderItems: [OrderItemModel] = []
    var page = 1
    var isEndData = false
    var selectedOrderIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        
        segmentedControl.selectedSegmentIndex = self.selectedSegmentedIndex
        segmentedControl.sendActions(for: .valueChanged)
        
        self.loadOrderItems(resetData: true, loadFirst: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderDetailChange(_:)), name: NSNotification.Name(Notifications.MINE_ORDER_CHANGE), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "我的订单"
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
            "type" : false
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
                print("Order Mine...")
                print(json)
                if resetData {
                    self.orderItems = []
                }
                let tempItems = self.getOrders(json["data"])
                self.orderItems.append(contentsOf: tempItems)
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
                        let tempItems = self.getOrders(json["data"])
                        self.orderItems.append(contentsOf: tempItems)
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
                        self.tableView.ts_reloadData { }
                    }
                    if self.orderItems.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
                        self.tableView.isHidden = true
                    }
                })
            }
        }
        
    }

    private func getOrders(_ jsons: JSON) -> [OrderItemModel] {
        var tempItems: [OrderItemModel] = []
        for orderJson in jsons.arrayValue {
            let product = ProductListModel.init(orderJson["item"])
            let order = OrderModel.init(orderJson)
            let orderItem = OrderItemModel.init(product: product, order: order)
            tempItems.append(orderItem)
        }
        return tempItems
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        self.selectedOrderIndex = selectedIndex
        self.loadOrderItems(resetData: true, loadFirst: true)
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
        self.loadOrderItems(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }*/
    
    private func footerRefreshing() {
        self.loadOrderItems(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    @objc func orderDetailChange(_ notification: NSNotification) {
        guard let orderIndex = notification.userInfo?["orderIndex"] as? Int else { return }
        if self.orderItems.count > orderIndex {
            self.orderItems[orderIndex].order.status = 1
            self.tableView.ts_reloadData {      }
        }
    }

}



extension MyOrderMineVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyOrderMineCell = tableView.ts_dequeueReusableCell(MyOrderMineCell.self)
        cell.setCellContent(orderItems[indexPath.row], vc: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let orderId = orderItems[indexPath.row].order.id!
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineDetailVC.nameOfClass) as! MyOrderMineDetailVC
        vc.orderId = orderId
        vc.orderIndex = indexPath.row
        self.pushAndHideTabbar(vc) 
    }
}


extension MyOrderMineVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
*/










