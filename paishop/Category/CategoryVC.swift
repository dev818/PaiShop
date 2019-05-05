//
//  CategoryVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/15/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh
import DropDown


class CategoryVC: UIViewController {
    
    
    @IBOutlet weak var searchBar: LRSearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var tab1Frame: UIView!
    @IBOutlet weak var tab1Label: UILabel!
    @IBOutlet weak var tab2Frame: UIView!
    @IBOutlet weak var tab2Label: UILabel!
    @IBOutlet weak var tab3Frame: UIView!
    @IBOutlet weak var tab3Label: UILabel!
    @IBOutlet weak var tab4Frame: UIView!
    @IBOutlet weak var tab4Label: UILabel!
    
    @IBOutlet weak var tab1AnchorView: UIView!
    @IBOutlet weak var tab2AnchorView: UIView!
    @IBOutlet weak var tab3AnchorView: UIView!
    @IBOutlet weak var tab4AnchorView: UIView!
    
    @IBOutlet weak var tabViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(CategoryListCell.self)
            tableView.ts_registerCellNib(CategoryGridCell.self)
        }
    }
    @IBOutlet weak var noDataImageView: UIImageView! {
        didSet {
            noDataImageView.isHidden = true
        }
    }
    
    
    var categories: [CategoryModel] = []
    var isListLayout = true
    var productList: [ProductListModel] = []
    var page = 1
    var isEndData = false
    
    var locationService: BMKLocationService!
    var userLocationCoordinate: CLLocationCoordinate2D!
    
    var tab1DropDown: DropDown!
    var tab2DropDown: DropDown!
    var tab3DropDown: DropDown!
    
    var selectedTab = 0 // 0-> no select, 1- tab1, 2 ....
    var selectedCategoryId: Int64!
    var selectedTab1Index = 0
    var selectedTab3Index = 0
    var keyword = ""
    var isSub = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationService = BMKLocationService()
        tab1Frame.isHidden = true
        tab2Frame.isHidden = true
        tab3Frame.isHidden = true

        if isSub == true {
            tabViewConstraint.constant = 44
            setupRefresh()
            //        self.loadCategories()
            selectedTab = 3
            self.loadProductLists(resetData: true, loadFirst: true)
            
            //        setupTab1DropDown()
            setupTab3DropDown()
            
        } else {
            tabViewConstraint.constant = 0
            tab4Frame.isHidden = true
            searchBar.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationService.delegate = self
        self.getUserLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.locationService.delegate = nil
        self.locationService.stopUserLocationService()
    }
    
    
    @IBAction func selectLayoutChange(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        self.isListLayout = !self.isListLayout
        self.tableView.reloadData()
    }
    
    @IBAction func selectTab1(_ sender: UIButton) {
        self.tableView.isHidden = false
        self.noDataImageView.isHidden = true
        self.noDataImageView.image = UIImage(named: "no_image_blank")
        
        searchBar.resignFirstResponder()
        if userLocationCoordinate != nil {
            resetTabLabels()
            self.selectedTab = 1
//            self.loadProductLists(resetData: true, loadFirst: true)
            self.tab1DropDown.show()
        } else {
            ProgressHUD.showWarningWithStatus("无法获得您的位置!")
        }
    }
    
    @IBAction func selectTab2(_ sender: UIButton) {
        self.tableView.isHidden = false
        self.noDataImageView.isHidden = true
        self.noDataImageView.image = UIImage(named: "no_image_blank")
        
        searchBar.resignFirstResponder()
        if tab2DropDown != nil {
            self.tab2DropDown.show()
        } else {
            ProgressHUD.showWarningWithStatus("无法获得类别!")
        }
    }
    
    @IBAction func selectTab3(_ sender: UIButton) {
        self.tableView.isHidden = false
        self.noDataImageView.isHidden = true
        self.noDataImageView.image = UIImage(named: "no_image_blank")
        
        searchBar.resignFirstResponder()
        if tab3DropDown != nil {
            self.tab3DropDown.show()
        }
    }
    
    @IBAction func selectTab4(_ sender: UIButton) {
        searchBar.resignFirstResponder()
        
        self.tableView.isHidden = true
        self.noDataImageView.isHidden = false
        self.noDataImageView.image = UIImage(named: "no_image_development")
    }
    
    @IBAction func tapBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        self.loadProductLists(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
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
        var loadAll = false
        
        switch selectedTab {
        case 0:
            parameters["category"] = 0
            loadAll = true
        case 1:
//            parameters["lat"] = userLocationCoordinate.latitude
//            parameters["lng"] = userLocationCoordinate.longitude
//            parameters["radius"] = 5000
            if selectedTab1Index == 0 {
                parameters["sort"] = "recommends"
            } else if selectedTab1Index == 1 {
                parameters["sort"] = "views"
            } else if selectedTab1Index == 2 {
                parameters["sort"] = "sales"
            } else {
                parameters["sort"] = "recommends"
            }
        case 2:
            parameters["category"] = self.selectedCategoryId
        case 3:
            parameters["category"] = self.selectedCategoryId
            if selectedTab3Index == 0 {
                parameters["sort"] = "recommends"
            } else if selectedTab3Index == 1 {
                parameters["sort"] = "views"
            } else {
                parameters["sort"] = "sales"
            }
        default:
            parameters["category"] = 0
            loadAll = true
        }
        
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
                    self.noDataImageView.isHidden = true
                    self.tableView.backgroundColor = MainColors.defaultBackground
                } else {
                    self.noDataImageView.isHidden = false
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
                            self.noDataImageView.isHidden = true
                            self.tableView.backgroundColor = MainColors.defaultBackground
                        } else {
                            self.noDataImageView.isHidden = false
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
    
    private func loadCategories() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.categoryRoot { (json, success) in
            if success {
                self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                self.setupTab2DropDown()
            } else {
                //load again...
                HomeAPI.shared.categoryRoot(completion: { (json, success1) in
                    if success1 {
                        self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                        self.setupTab2DropDown()
                    }
                })
            }
        }
    }
    
    func resetTabLabels() {
        tab1Label.text = "5000米"
        tab2Label.text = "全部分类"
        tab3Label.text = "推荐排序"
    }
    
    

}



extension CategoryVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isListLayout {
            return productList.count
        } else {
            return productList.count / 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isListLayout {
            let cell: CategoryListCell = tableView.ts_dequeueReusableCell(CategoryListCell.self)
            cell.setCellContent(productList[indexPath.row])
            return cell
        } else {
            let cell: CategoryGridCell = tableView.ts_dequeueReusableCell(CategoryGridCell.self)
            cell.setCellContent(self, row: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        if isListLayout {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = productList[indexPath.row].id!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}


extension CategoryVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.loadProductLists(resetData: true, loadFirst: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.keyword = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
}











