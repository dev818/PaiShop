

import UIKit
import SwiftyJSON
import MJRefresh
import XLActionController
import MapKit


class GuideVC: UIViewController {
    
    @IBOutlet weak var listFrame: UIView!
    @IBOutlet weak var buttonBarView: ButtonBarView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            //TableView Setup
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100
            tableView.ts_registerCellNib(GuideCell.self)
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var searchTableView: UITableView! {
        didSet {
            searchTableView.isHidden = true
            searchTableView.dataSource = self
            searchTableView.delegate = self
            searchTableView.rowHeight = UITableView.automaticDimension
            searchTableView.estimatedRowHeight = 100
            searchTableView.ts_registerCellNib(GuideCell.self)
            searchTableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var MapFrame: UIView!
    @IBOutlet weak var searchBar: LRSearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var citySelectView: UIStackView!
    @IBOutlet weak var cityLabel: UILabel! {
        didSet {
            cityLabel.text = "请选择"
        }
    }
    @IBOutlet weak var mapView: BMKMapView!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customStoreView: UIView!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeDistanceNameTitle: UILabel!
    @IBOutlet weak var storeDistanceLabel: UILabel!
    @IBOutlet weak var storeDescriptionTextView: UITextView!    
    @IBOutlet weak var degreeImageView: RoundImageView!
    
    @IBOutlet weak var citySelectImageView: UIImageView!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var customViewButton1Bg: GradientView!
    @IBOutlet weak var customViewButton2Bg: GradientView!
    
    
    
    
    var locationService: BMKLocationService!
    var geocodeSearch: BMKGeoCodeSearch!
    var settings = ButtonBarPagerTabStripSettings()
    var buttonBarItemSpec: ButtonBarItemSpec<UICollectionViewCell>!
    var currentIndex = 0
    var userLocationCoordinate: CLLocationCoordinate2D!
    
    
    var categories: [CategoryModel] = []
    var stores: [StoreDetailModel] = []
    var searchStores: [StoreDetailModel] = []
    var page = 1
    var isEndData = false
    var isMapDisplayMode = true // State for changing display mode
    var isCalledCity = false // City Selection State
    var mapStores: [StoreDetailModel] = []
    var storeAnnotations: [BMKPointAnnotation] = []
    var isSelectedCityView = false
    
    var searchText = ""
    var selectedStoreId: Int64!
    var selectedStore: StoreDetailModel!
    var isGoToStore = false
    
    var mapSearchText = ""
    var mapCityText = "请选择"
    var listSearchText = ""
    var listCityText = "请选择"
    var selectedCityId: Int! // city id for list mode
    
    var isSelectedMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupCustomView()
        self.setupTheme()
        
        locationService = BMKLocationService()
        //locationService.allowsBackgroundLocationUpdates = true
        geocodeSearch = BMKGeoCodeSearch()
        
        self.loadCategories()
        
        //ButtonBarView setup
        self.setupButtonBarView()
        self.setupRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeCity(_:)), name: NSNotification.Name(rawValue: Notifications.HOME_CITY_SELECT), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupCustomView()        
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        citySelectImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        storeDistanceLabel.textColor = MainColors.themeEndColors[selectedTheme]
        navigationButton.imageView?.setTintColor(MainColors.themeEndColors[selectedTheme])
        storeDescriptionTextView.textColor = MainColors.themeEndColors[selectedTheme]
        customViewButton1Bg.startColor = MainColors.themeStartColors[selectedTheme]
        customViewButton1Bg.endColor = MainColors.themeEndColors[selectedTheme]
        customViewButton2Bg.startColor = MainColors.themeStartColors[selectedTheme]
        customViewButton2Bg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationService.delegate = self
        geocodeSearch.delegate = self
        mapView.viewWillAppear()
        mapView.delegate = self
        
        isCalledCity = false
        if !isSelectedCityView && isMapDisplayMode {
            if isGoToStore {
                isGoToStore = false
            } else {
                self.isSelectedMyLocation = false
                self.getUserLocation()
                self.searchBar.text = ""
            }
        } else {
            isSelectedCityView = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationService.delegate = nil
        geocodeSearch.delegate = nil
        mapView.viewWillDisappear()
        mapView.delegate = nil
        
        locationService.stopUserLocationService()
        
        self.hideCustomStoreView()
        self.view.endEditing(true)
    }
    
    
    private func setupUI() {
        citySelectView.isUserInteractionEnabled = true
        let citySelectTap = UITapGestureRecognizer(target: self, action: #selector(selectCityView))
        citySelectView.addGestureRecognizer(citySelectTap)
    }
    
    private func setupCustomView() {
        self.view.addSubview(customStoreView)
        customStoreView.translatesAutoresizingMaskIntoConstraints = false
        customStoreView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(295)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
    }
    
    // change display mode between map and list
    @IBAction func selectDisplayMode(_ sender: UIButton) {
        if isMapDisplayMode {
            mapSearchText = searchText
            mapCityText = cityLabel.text!
            
            searchBar.text = listSearchText
            cityLabel.text = listCityText
            self.searchText = listSearchText
        } else {
            listSearchText = searchText
            listCityText = cityLabel.text!
            
            searchBar.text = mapSearchText
            cityLabel.text = mapCityText
            self.searchText = mapSearchText
        }
        
        isMapDisplayMode = !isMapDisplayMode
        if isMapDisplayMode {
            UIView.animate(withDuration: 0.3, animations: {
                self.MapFrame.alpha = 1
                self.listFrame.alpha = 0
            }, completion: { (finished) in
                self.MapFrame.isHidden = false
                self.listFrame.isHidden = true
                sender.setImage(ImageAsset.guide_to_list.image, for: .normal)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.MapFrame.alpha = 0
                self.listFrame.alpha = 1
            }, completion: { (finished) in
                self.MapFrame.isHidden = true
                self.listFrame.isHidden = false
                sender.setImage(ImageAsset.guide_to_map.image, for: .normal)
            })
        }
    }
    
    // select city and go to city select VC
    @objc func selectCityView() {
        Utils.applyTouchEffect(citySelectView)
        self.isSelectedCityView = true
        let cityRootVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: CityRootVC.nameOfClass) as! CityRootVC
        cityRootVC.mode = GuideVC.nameOfClass
        self.pushAndHideTabbar(cityRootVC)
    }
    
    //select my location button
    @IBAction func selectMyLocation(_ sender: Any) {
        self.isSelectedMyLocation = true
        self.getUserLocation()
    }
    
    // select zoom in button
    @IBAction func selectZoomIn(_ sender: Any) {
        mapView.zoomIn()
    }
    
    //select zoom out button
    @IBAction func selectZoomOut(_ sender: Any) {
        mapView.zoomOut()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // load categories from the server
    private func loadCategories() {
        self.buttonBarView.isHidden = true
        self.tableView.isHidden = true
        ProgressHUD.showWithStatus()
        HomeAPI.shared.categoryRoot { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.currentIndex = 0
                //print("Category Root............")
                //print(json)
                self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                self.buttonBarView.reloadData()
                
                self.buttonBarView.isHidden = false
                self.tableView.isHidden = false
                
                self.buttonBarView.moveTo(index: self.currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
                let selectedIndexPath = IndexPath(item: self.currentIndex, section: 0)
                self.buttonBarView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                
                self.loadStores(resetData: true, loadFirst: true)
            } else {
                // load again...
                HomeAPI.shared.categoryRoot(completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.currentIndex = 0
                        self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                        self.buttonBarView.reloadData()
                        
                        self.buttonBarView.isHidden = false
                        self.tableView.isHidden = false
                        
                        self.buttonBarView.moveTo(index: self.currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
                        let selectedIndexPath = IndexPath(item: self.currentIndex, section: 0)
                        self.buttonBarView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                        
                        self.loadStores(resetData: true, loadFirst: true)
                    }
                })
            }
        }
    }
    
    // table view header and footer refresh setup
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
    
    // load stores with category from the server
    func loadStores(resetData: Bool, loadFirst: Bool) {
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
            self.endHeaderRefresh()
            return
        }
        var parameters: [String : Any] = [
            "id" : categories[currentIndex].id!
        ]
        if self.selectedCityId != nil {
            parameters["city"] = self.selectedCityId
        }
        GuideAPI.shared.storeCategory(page: self.page, params: parameters) { (json, success) in
            self.tableView.isUserInteractionEnabled = true
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                //print("Store Category...")
                //print(json)
                if resetData {
                    self.stores = []
                }
                let tempStores = StoreDetailModel.getStoreDetailsFromJson(json["data"])
                self.stores.append(contentsOf: tempStores)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                DispatchQueue.main.async {
                    self.tableView.ts_reloadData { }
                }
            } else {
                GuideAPI.shared.storeCategory(page: self.page, params: parameters, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.stores = []
                        }
                        let tempStores = StoreDetailModel.getStoreDetailsFromJson(json["data"])
                        self.stores.append(contentsOf: tempStores)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.ts_reloadData { }
                    }
                })
            }
        }
    }
    
    private func headerRefreshing() {
        self.loadStores(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        //refresh data
        self.loadStores(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    // proces Notifications.HOME_CITY_SELECT notification
    @objc func changeCity(_ notification: NSNotification) {
        guard let mode = notification.userInfo?["mode"] as? String else { return }
        if mode != GuideVC.nameOfClass {
            return
        }
                
        if let city = notification.userInfo?["city"] as? CityModel {
            cityLabel.text = city.name
            searchText = ""
            searchBar.text = ""
            
            if isMapDisplayMode { //map mode
                let parameters: [String: Any] = [
                    "id" : city.id!
                ]
                GuideAPI.shared.storeCity(params: parameters, completion: { (json, success) in
                    if success {
                        print("Store City...")
                        print(json)
                        self.mapStores = StoreDetailModel.getStoreDetailsFromJson(json["data"])
                        self.setupMarkers()
                    } else {
                        // try again...
                        GuideAPI.shared.storeCity(params: parameters, completion: { (json, success1) in
                            if success1 {
                                self.mapStores = StoreDetailModel.getStoreDetailsFromJson(json["data"])
                                self.setupMarkers()
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
                    }
                })
            } else { //list mode
                self.searchTableView.isHidden = true
                self.tableView.isHidden = false
                
                self.selectedCityId = city.id!
                self.loadStores(resetData: true, loadFirst: true)
            }
            
        }
    }
    
    @IBAction func closeCustomView(_ sender: UIButton) {
        self.hideCustomStoreView()
    }
    
    @IBAction func selectToStore(_ sender: UIButton) {
        self.hideCustomStoreView()
        self.isGoToStore = true
        // go to Store Detail Page...
        if self.selectedStoreId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = self.selectedStoreId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func showDarkView(_ state: Bool) {
        if state {
            self.darkView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.8
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { (finished) in
                self.darkView.isHidden = true
            })
        }
    }
    
    func hideCustomStoreView() {
        customStoreView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    func searchStoreInMapMode(_ parameters: [String: Any]) {
        GuideAPI.shared.storeSearch(params: parameters) { (json, success) in
            if success {
                //print("Store Search...")
                //print(json)
                self.mapStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                self.setupMarkers()
            } else {
                // try again...
                GuideAPI.shared.storeSearch(params: parameters, completion: { (json, success1) in
                    if success1 {
                        self.mapStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                        self.setupMarkers()
                    }
                })
            }
        }
    }
    
    func searchStoreInListMode(_ parameters: [String: Any]) {
        ProgressHUD.showWithStatus()
        GuideAPI.shared.storeSearch(params: parameters, completion: { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.searchStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                DispatchQueue.main.async {
                    self.searchTableView.ts_reloadData {  }
                }
            } else {
                //try again...
                GuideAPI.shared.storeSearch(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.searchStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                        DispatchQueue.main.async {
                            self.searchTableView.ts_reloadData {  }
                        }
                    } else {
                        self.searchStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                        DispatchQueue.main.async {
                            self.searchTableView.ts_reloadData {  }
                        }
                    }
                })
            }
        })
    }
    
    
    @IBAction func selectNavigation(_ sender: UIButton) {
        if self.selectedStore == nil {
            return
        }
        
        if self.userLocationCoordinate == nil {
            ProgressHUD.showWarningWithStatus("无法获得您的位置!")
            return
        }
        
        self.hideCustomStoreView()
        
        let actionController = PeriscopeActionController()
        actionController.addAction(Action.init("通过苹果地图导航", style: .default, handler: { (action) in
            let coordinate = CLLocationCoordinate2D(latitude: (self.selectedStore.lat)!, longitude: (self.selectedStore.lng)!)
            let regionDistance: CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue.init(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue.init(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.selectedStore.name
            mapItem.openInMaps(launchOptions: options)
        }))
        actionController.addAction(Action.init("通过百度地图导航", style: .default, handler: { (action) in
            let urlString = String.init(format: "baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&rc=cab", self.userLocationCoordinate.latitude, self.userLocationCoordinate.longitude, (self.selectedStore.lat)!, (self.selectedStore.lng)!)
            let url = URL.init(string: urlString)
            if url != nil {
                print("URL...", url!)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    ProgressHUD.showWarningWithStatus("请安装百度地图应用程序!")
                }
            }
        }))
        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action("取消", style: .cancel, handler:nil))
        
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    
}



extension GuideVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return self.searchStores.count
        }
        return self.stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchTableView {
            let cell: GuideCell = tableView.ts_dequeueReusableCell(GuideCell.self)
            let store = self.searchStores[indexPath.row]
            cell.setContent(store, vc: self, indexPath: indexPath)
            return cell
        }
        let cell: GuideCell = tableView.ts_dequeueReusableCell(GuideCell.self)
        let store = self.stores[indexPath.row]
        cell.setContent(store, vc: self, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == searchTableView {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = self.searchStores[indexPath.row].storeId!
            self.pushAndHideTabbar(vc)
        } else {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = self.stores[indexPath.row].storeId!
            self.pushAndHideTabbar(vc)
        }
    }
}


extension GuideVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchText.count > 0 {
            if isMapDisplayMode {
                let parameters: [String : Any] = [
                    "keyword" : searchText,
                    //"city" : self.cityLabel.text! //"东丰县"
                ]
                self.searchStoreInMapMode(parameters)
            } else {
                let parameters: [String : Any] = [
                    "keyword" : searchText,
                    "category" : categories[currentIndex].id!
                ]
                self.searchStoreInListMode(parameters)
            }
        } else {
            if !isMapDisplayMode {
                self.tableView.isHidden = false
                self.searchTableView.isHidden = true
                self.stores = []
                self.tableView.ts_reloadData {
                    self.loadStores(resetData: true, loadFirst: true)
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.cityLabel.text = "请选择"
        if !isMapDisplayMode { //list mode
            self.selectedCityId = nil
            self.searchStores = []
            self.searchTableView.ts_reloadData { }
            self.searchTableView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
}













