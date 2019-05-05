//
//  ShowSimilarProductsVC.swift
//  paishop
//
//  Created by h.g.n on 8/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MJRefresh

class ShowSimilarProductsVC: UIViewController {

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(ShowSimilarProductCell.self)
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }    
    
    var productList: [ProductListModel] = []
    var page = 1
    var isEndData = false
    var keyword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.setupNavBar()
        self.setupRefresh()
        self.loadProductLists(resetData: true, loadFirst: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "同款商品"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
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
        self.loadProductLists(resetData: true, loadFirst: false)
    }
    
    private func footerRefreshing() {
        self.loadProductLists(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    func loadProductLists(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        
        var parameters: [String : Any] = [:]
        let loadAll = false
        
        parameters["category"] = 4
        
        if self.keyword != "" {
            parameters["keyword"] = self.keyword
        }
        
        
        CategoryAPI.shared.itemFind(loadAll: loadAll, page: self.page, params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.endFooterRefresh()
                self.endHeaderRefresh()
                if resetData {
                    self.productList = []
                }
                let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                self.productList.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                self.tableView.ts_reloadData {
                    if self.productList.count > 0 && loadFirst {
                        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
                    }
                }
                
                if self.productList.count > 0 {
                    self.noDataView.isHidden = true
                    self.tableView.backgroundColor = MainColors.defaultBackground
                } else {
                    self.noDataView.isHidden = false
                    self.tableView.backgroundColor = UIColor.white
                }
                
            } else {
                CategoryAPI.shared.itemFind(loadAll: loadAll, page: self.page, params: parameters, completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    self.endFooterRefresh()
                    self.endHeaderRefresh()
                    if success1 {
                        if resetData {
                            self.productList = []
                        }
                        let tempItems = ProductListModel.getProductListsFromJson(json1["data"])
                        self.productList.append(contentsOf: tempItems)
                        let lastPage = json1["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        self.tableView.ts_reloadData {
                            if self.productList.count > 0 && loadFirst {
                                self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
                            }
                        }
                        
                        if self.productList.count > 0 {
                            self.noDataView.isHidden = true
                            self.tableView.backgroundColor = MainColors.defaultBackground
                        } else {
                            self.noDataView.isHidden = false
                            self.tableView.backgroundColor = UIColor.white
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
                })
            }
            
        }
        
    }
}

extension ShowSimilarProductsVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ShowSimilarProductsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShowSimilarProductCell = tableView.ts_dequeueReusableCell(ShowSimilarProductCell.self)
        cell.setCellContent(productList[indexPath.row])
        return cell
    }    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //searchBar.resignFirstResponder()
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = productList[indexPath.row].id!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
