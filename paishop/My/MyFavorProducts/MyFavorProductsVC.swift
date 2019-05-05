//
//  MyFavorProductsVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MJRefresh

class MyFavorProductsVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyFavorProductCell.self)
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    var products: [ProductListModel] = []
    var page = 1
    var isEndData = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        self.loadFavoriteProducts(resetData: true, loadFirst: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveProductDetailBack(_:)), name: NSNotification.Name(Notifications.PRODUCT_DETAIL_CHANGE), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "收藏商品"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @objc func receiveProductDetailBack(_ notification: NSNotification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyFavorProductsVC.nameOfClass {
            return
        }
        
        guard let senderIndex = notification.userInfo?["senderIndex"] as? Int else { return }
        
        if let productDetail = notification.userInfo?["productDetail"] as? ProductDetailModel {
            if senderIndex < self.products.count {
                let favorites = productDetail.favorites!
                if favorites < 1 {
                    self.products.remove(at: senderIndex)
                    self.tableView.ts_reloadData {
                        if self.products.count > 0 {
                            self.noDataView.isHidden = true
                        } else {
                            self.noDataView.isHidden = false
                        }
                    }
                }
            }
        }
        
    }
    
    private func loadFavoriteProducts(resetData: Bool, loadFirst: Bool) {
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
        
        HomeAPI.shared.itemFavoriteList(page: self.page) { (json, success) in
            self.endFooterRefresh()
            //self.endHeaderRefresh()
            self.tableView.isUserInteractionEnabled = true
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Item Favorite List...")
                print(json)
                if resetData {
                    self.products = []
                }
                let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                self.products.append(contentsOf: tempItems)
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
                HomeAPI.shared.storeFavoriteList(page: self.page, completion: { (json1, success1) in
                    if success1 {
                        if resetData {
                            self.products = []
                        }
                        let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                        self.products.append(contentsOf: tempItems)
                        let lastPage = json1["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                    } else {
                        let errors = json1["errors"].dictionaryValue
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
        self.loadFavoriteProducts(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    //h.g.n
    @objc func cellFindBtnTapped(_ sender: Any?) {
        
        print("tapped!")
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ShowSimilarProductsVC.nameOfClass) as! ShowSimilarProductsVC
//        vc.itemId = products[indexPath.row].id!
//        vc.senderVC = MyFavorProductsVC.nameOfClass
//        vc.senderIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}


extension MyFavorProductsVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyFavorProductsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyFavorProductCell = tableView.ts_dequeueReusableCell(MyFavorProductCell.self)
        cell.setCellContent(products[indexPath.row])
        cell.findProductBtn.addTarget(self, action: #selector(cellFindBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = products[indexPath.row].id!
        vc.senderVC = MyFavorProductsVC.nameOfClass
        vc.senderIndex = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}












