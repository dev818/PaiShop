//
//  NearbyStoreDetailVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MJRefresh
import SKPhotoBrowser
import MonkeyKing

class NearbyStoreDetailVC: UIViewController {

    var senderVC: String?
    var senderIndex: Int!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(NearbyStoreDetailTopCell.self)
            tableView.ts_registerCellNib(NearbyStoreDetailProductCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.tableFooterView = UIView()
        }
    }
    
    var storeId: Int64!
    var storeDetail: StoreDetailModel!
    var storeItems: [ProductListModel] = []
    var page = 1
    var isEndData = false
    
    var locationService: BMKLocationService!
    var userLocationCoordinate: CLLocationCoordinate2D!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationService = BMKLocationService()
        self.getUserLocation()
        
        self.tableView.isHidden = true
        setupRefresh()
        self.loadStoreDetail()
        
        self.setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationService.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationService.delegate = nil
        self.locationService.stopUserLocationService()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "店铺详情页"
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
                        self.navBar.alpha = 1
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
                self.tableView.isHidden = false
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
                }
                self.tableView.ts_reloadData {  }
            } else {
                // try again...
                HomeAPI.shared.itemStore(page: self.page, storeId: self.storeDetail.storeId!, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.storeItems = []
                        }
                        self.tableView.isHidden = false
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
                        }
                        self.tableView.ts_reloadData {  }
                    } else {
                        if resetData {
                            self.navBar.alpha = 1
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

    

}



extension NearbyStoreDetailVC: UITableViewDataSource, UITableViewDelegate {
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
            let cell: NearbyStoreDetailTopCell = tableView.ts_dequeueReusableCell(NearbyStoreDetailTopCell.self)
            if self.storeDetail != nil {
                cell.setCellContent(self.storeDetail, vc: self)
            }
            return cell
        }
        let cell: NearbyStoreDetailProductCell = tableView.ts_dequeueReusableCell(NearbyStoreDetailProductCell.self)
        cell.setCellContent(self.storeItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = self.storeItems[indexPath.row].id!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension NearbyStoreDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}












