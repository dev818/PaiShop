//
//  MyOrderMineTab1VC.swift
//  paishop
//
//  Created by SeniorCorder on 6/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import MJRefresh
import SwiftyJSON


class MyOrderMineTab1VC: UIViewController {
    
    var itemInfo: IndicatorInfo = "Tab1"
    var itemRecommends: [ItemRecommendModel] = []
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(MyOrderMineTab1Cell.self)
            tableView.ts_registerCellNib(MyOrderMineTab3Cell.self)
            tableView.ts_registerCellNib(MyOrderMineTab4Cell.self)
            tableView.ts_registerCellNib(MyOrderMineTab5Cell.self)
            tableView.ts_registerCellNib(MyOrderRecmCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
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
        self.loadRecommends()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderDetailChange(_:)), name: NSNotification.Name(Notifications.MINE_ORDER_CHANGE), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadOrderItems(resetData: true, loadFirst: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadOrderItems(resetData: Bool, loadFirst: Bool) {
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
            return
        }
        
        let parameters: [String : Any] = [
            "type" : false // pai product order
        ]
        MyAPI.shared.orderList(page: self.page, params: parameters) { (json, success) in
            if success {
                self.endFooterRefresh()
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
    
    @objc func orderDetailChange(_ notification: NSNotification) {
        guard let orderIndex = notification.userInfo?["orderIndex"] as? Int else { return }
        if self.orderItems.count > orderIndex {
            self.orderItems[orderIndex].order.status = 1
            self.tableView.ts_reloadData {      }
        }
    }

    private func loadRecommends() {
        if !(loadRecmFirst) { return }
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.itemRecommend { (json, success) in //Recommends
            if success {
                print("Recommends...")
                print(json)
                //self.storeRecommends = StoreRecommendModel.getStoreRecommendsFromJson(json["stores"])
                self.itemRecommends = ItemRecommendModel.getItemRecommendsFromJson(json["items"])
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData { }
                })
            } else {
                HomeAPI.shared.itemRecommend (completion: { (json1, success1) in //Recommends
                    if success1 {
                        //self.storeRecommends = StoreRecommendModel.getStoreRecommendsFromJson(json1["stores"])
                        self.itemRecommends = ItemRecommendModel.getItemRecommendsFromJson(json1["items"])
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData { }
                        })
                    }
                })
            }
        }
        
    }

}


extension MyOrderMineTab1VC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}


extension MyOrderMineTab1VC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.orderItems.count {
            let cell: MyOrderRecmCell = tableView.ts_dequeueReusableCell(MyOrderRecmCell.self)
            cell.setCellContent(self, items: itemRecommends)
            
            return cell
        } else {
            let orderItem = self.orderItems[indexPath.row]
            switch orderItem.order.status! {
            case 1: //completed
                let cell: MyOrderMineTab5Cell = tableView.ts_dequeueReusableCell(MyOrderMineTab5Cell.self)
                cell.setCellContent(orderItem, vc: self)
                return cell
            case 2: // pending
                let cell: MyOrderMineTab3Cell = tableView.ts_dequeueReusableCell(MyOrderMineTab3Cell.self)
                cell.setCellContent(orderItem, vc: self)
                return cell
            case 3: // delivering
                let cell: MyOrderMineTab4Cell = tableView.ts_dequeueReusableCell(MyOrderMineTab4Cell.self)
                cell.setCellContent(orderItem, vc: self)
                return cell
            default:
                let cell = UITableViewCell()
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderId = orderItems[indexPath.row].order.id!
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineDetailVC.nameOfClass) as! MyOrderMineDetailVC
        vc.orderId = orderId
        vc.orderIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


















