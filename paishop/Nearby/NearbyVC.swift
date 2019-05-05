//
//  NearbyVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import MJRefresh

class NearbyVC: UIViewController {
    
    @IBOutlet weak var searchBar: LRSearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var displayChangeButton: UIButton!
    
    
    @IBOutlet weak var buttonBarView: ButtonBarView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //TableView Setup
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100
            tableView.ts_registerCellNib(NearbyTopCell.self)
            tableView.ts_registerCellNib(NearbyBottomTitleCell.self)
            tableView.ts_registerCellNib(NearbyBottomCell.self)
            tableView.tableFooterView = UIView()
        }
    }
    
    
    var categories: [CategoryModel] = []
    var currentIndex = 0
    var storeList: [StoreDetailModel] = []
    var storeItems: [ProductListModel] = []
    var page = 1
    var isEndData = false
    
    var settings = ButtonBarPagerTabStripSettings()
    var buttonBarItemSpec: ButtonBarItemSpec<UICollectionViewCell>!
    
    var selectedTheme = 0
    var locationService: BMKLocationService!
    var userLocationCoordinate: CLLocationCoordinate2D!
    var keyword = ""
    var selectedStoreId: Int64!
    var isDisplayModeMap = false
    var isSelectedUserLocation = false
    
    var allStoreList: [StoreDetailModel] = []
    var nTotal = 0
    var nAll = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationService = BMKLocationService()
        self.getUserLocation()

        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        self.setupButtonBarView()
        self.setupRefresh()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.categories = appDelegate.categories
        self.buttonBarView.reloadData()
        self.buttonBarView.moveTo(index: self.currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
        let selectedIndexPath = IndexPath(item: self.currentIndex, section: 0)
        self.buttonBarView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        
        self.loadStoreLists()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.locationService.delegate = self
        
        if let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)), cell is NearbyTopCell {
            (cell as! NearbyTopCell).mapView.viewWillAppear()
            (cell as! NearbyTopCell).mapView.delegate = (cell as! NearbyTopCell)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationService.delegate = nil
        self.locationService.stopUserLocationService()
        
        if let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)), cell is NearbyTopCell {
            (cell as! NearbyTopCell).mapView.viewWillDisappear()
            (cell as! NearbyTopCell).mapView.delegate = nil
        }
        
    }

    @IBAction func selectDisplayChange(_ sender: UIButton) {
        isDisplayModeMap = !isDisplayModeMap
        self.tableView.reloadData()
    }
    
    
    
    func loadStoreLists() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        ProgressHUD.showWithStatus()
        
        var parameters: [String : Any] = [:]
        var loadAll = false
        
        if currentIndex == 0 {
            parameters["recommend"] = true
        } else if currentIndex == (categories.count + 1) {
            loadAll = true
            parameters["category"] = 0
        } else {
            parameters["category"] = categories[currentIndex - 1].id!
        }
        
        if self.keyword != "" {
            parameters["keyword"] = self.keyword
        }
        
        NearbyAPI.shared.storeAround(loadAll: loadAll, params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                //h.g.n
                //self.storeList = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                self.allStoreList = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                self.nTotal = self.allStoreList.count
                
                if self.nTotal <= 5 {
                    self.storeList = self.allStoreList
                    self.storeListReload()
                } else {
                    self.loadPartOfStores(nFirst: self.nAll)
                }
                
            } else {
                NearbyAPI.shared.storeAround(loadAll: loadAll, params: parameters, completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        //self.storeList = StoreDetailModel.getStoreDetailsFromJson(json1["stores"])
                        //h.g.n
                        self.allStoreList = StoreDetailModel.getStoreDetailsFromJson(json1["stores"])
                        self.nTotal = self.allStoreList.count
                        
                        if self.nTotal <= 5 {
                            self.storeList = self.allStoreList
                            self.storeListReload()
                        } else {
                            self.loadPartOfStores(nFirst: self.nAll)
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
    
    //h.g.n
    @objc func cellLoadStoreBtnTapped(_ sender: Any?) {
        
        loadPartOfStores(nFirst: self.nAll)
    }
    
    //h.g.n
    func loadPartOfStores(nFirst: Int) {
        if self.nTotal <= 5 {
            return
        } else {
            self.storeList = []
            var nLast = nFirst + 5
            if nLast >= self.nTotal {
                nLast = self.nTotal
            }
            for j in nFirst..<nLast {
                self.storeList.append(self.allStoreList[j])
                self.nAll += 1
            }
            if self.nAll >= nTotal {
                self.nAll = 0
            }
            
            self.storeListReload()
        }
    }
    
    //h.g.n
    func storeListReload() {
        self.tableView.reloadData {
            if self.storeList.count > 0 {
                if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)), cell is NearbyTopCell {
                    (cell as! NearbyTopCell).collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .left, animated: true)
                }
                self.selectedStoreId = self.storeList[0].storeId!
                self.loadStoreItems(self.selectedStoreId, resetData: true)
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
        if selectedStoreId != nil {
            self.loadStoreItems(selectedStoreId, resetData: false)
        } else {
            endFooterRefresh()
        }
        
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    func loadStoreItems(_ id: Int64, resetData: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        HomeAPI.shared.itemStore(page: self.page, storeId: id) { (json, success) in
            if success {
                self.endFooterRefresh()
                ProgressHUD.dismiss()
                if resetData {
                    self.storeItems = []
                }
                let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                self.storeItems.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                self.tableView.reloadData()
            } else {
                HomeAPI.shared.itemStore(page: self.page, storeId: id, completion: { (json1, success1) in
                    self.endFooterRefresh()
                    ProgressHUD.dismiss()
                    if success1 {
                        if resetData {
                            self.storeItems = []
                        }
                        let tempItems = ProductListModel.getProductListsFromJson(json1["data"])
                        self.storeItems.append(contentsOf: tempItems)
                        let lastPage = json1["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        self.tableView.reloadData()
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


extension NearbyVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 1
        }
        
        return storeItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: NearbyTopCell = tableView.ts_dequeueReusableCell(NearbyTopCell.self)
            cell.setCellContent(self, storeList: self.storeList)
            cell.loadStoreBtn.addTarget(self, action: #selector(cellLoadStoreBtnTapped(_:)), for: .touchUpInside)
            return cell
        }
        if indexPath.section == 1 {
            let cell: NearbyBottomTitleCell = tableView.ts_dequeueReusableCell(NearbyBottomTitleCell.self)
            return cell
        }
        
        let cell: NearbyBottomCell = tableView.ts_dequeueReusableCell(NearbyBottomCell.self)
        cell.setCellContent(storeItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = storeItems[indexPath.row].id!
            vc.senderVC = NearbyVC.nameOfClass
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*if cell is NearbyTopCell {
            (cell as! NearbyTopCell).mapView.viewWillDisappear()
            (cell as! NearbyTopCell).mapView.delegate = nil
        }*/
    }
}



extension NearbyVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.loadStoreLists()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.keyword = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
}



















