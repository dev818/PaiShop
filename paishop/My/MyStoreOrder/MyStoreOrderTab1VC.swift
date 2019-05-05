//
//  MyStoreOrderTab1VC.swift
//  paishop
//
//  Created by SeniorCorder on 6/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MJRefresh
import SwiftyJSON

class MyStoreOrderTab1VC: UIViewController {
    
    var itemInfo: IndicatorInfo = "Tab1"
    var status = 0 // 0->all, 2->pending, 3->delivering, 1->completed, 4->refund

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupRefresh()

        NotificationCenter.default.addObserver(self, selector: #selector(orderDetailChange(_:)), name: NSNotification.Name(Notifications.STORE_ORDER_CHANGE), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadOrderItems(resetData: true, loadFirst: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func orderDetailChange(_ notification: NSNotification) {
        //guard let orderIndex = notification.userInfo?["orderIndex"] as? Int else { return }
        //guard let orderStatus = notification.userInfo?["orderStatus"] as? Int else { return }
        guard let originOrderStatus = notification.userInfo?["originOrderStatus"] as? Int else { return }
        if originOrderStatus == self.status {
            //reload Data...
            loadOrderItems(resetData: true, loadFirst: true)
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
        
        var parameters: [String : Any] = [
            "type" : true
        ]
        if status > 0 {
            parameters["status"] = self.status
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

extension MyStoreOrderTab1VC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}


extension MyStoreOrderTab1VC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyStoreOrderCell = tableView.ts_dequeueReusableCell(MyStoreOrderCell.self)
        cell.setupUI(selectedTab: self.status)
        cell.setCellContent(orderItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderId = orderItems[indexPath.row].order.id!
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderDetailVC.nameOfClass) as! MyStoreOrderDetailVC
        vc.orderId = orderId
        vc.orderIndex = indexPath.row
        vc.originOrderStatus = self.status
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}








