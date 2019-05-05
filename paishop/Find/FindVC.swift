
import UIKit
import MJRefresh
import Alamofire
import SwiftyJSON;

class FindVC: UIViewController {
    
    @IBOutlet weak var navRightImageView: UIImageView! {
        didSet {
            navRightImageView.setTintColor(UIColor.white)
        }
    }
    @IBOutlet weak var navRightButton: UIButton!
    
    @IBOutlet weak var tab1Bg: UIView!
    @IBOutlet weak var tab2Bg: UIView!
    @IBOutlet weak var tab3Bg: UIView!
    @IBOutlet weak var tab4Bg: UIView!
    @IBOutlet weak var tab5Bg: UIView!
    
    @IBOutlet weak var tab1Label: UILabel!
    @IBOutlet weak var tab2Label: UILabel!
    @IBOutlet weak var tab3Label: UILabel!
    @IBOutlet weak var tab4Label: UILabel!
    @IBOutlet weak var tab5Label: UILabel!
    
    @IBOutlet weak var topFrame: GradientView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(FindVideoCell.self)
            tableView.ts_registerCellNib(FeaturedCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    
    var selectedTheme = 0
    var selectedTabIndex = 2 // start from 1
    
    var videoList: [LiveVideoModel] = []
    var featuredList: [FeaturedModel] = []
    var page = 1
    var isEndData = false
    var arrayFeature = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayFeature = NSMutableArray.init()
        
        self.setupRefresh()
        self.setupTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        noDataView.isHidden = true
        if UserInstance.isLogin {
            self.updateTab()
            self.showUI(true)
        } else {
            self.showUI(false)
            self.goToLoginVC()
        }
    }
    
    private func setupTheme() {
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        topFrame.startColor = MainColors.themeStartColors[selectedTheme]
        topFrame.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func showUI(_ show: Bool) {
        self.topFrame.isHidden = !show
        self.tableView.isHidden = !show
    }
    
    @IBAction func selectNavRight(_ sender: UIButton) {
        Utils.applyTouchEffect(navRightImageView)
        
        switch selectedTabIndex {
        case 1:
            return
        case 2:
            let vc = UIStoryboard(name: "Find", bundle: nil).instantiateViewController(withIdentifier: FeaturedPostVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            return
        case 5:
            return
        case 4:
            if Utils.isIpad() {
                ProgressHUD.showWarningWithStatus("视频直播推流不支持ipad!")
                return
            }
            
            if UserInstance.degreeId! < 1 {
                ProgressHUD.showWarningWithStatus("请升级您的帐户!")
            } else if !UserInstance.hasVerifiedStore() {
                ProgressHUD.showWarningWithStatus("你没有你的商店或你的商店仍在审查中!")
            } else {
                let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: LiveVideoPostVC.nameOfClass) as! LiveVideoPostVC
                let navVC = UINavigationController(rootViewController: vc)
                navVC.isNavigationBarHidden = true
                self.present(navVC, animated: true, completion: nil)
            }
        default:
            break
        }
        
        
    }
    
    @IBAction func selectTab1(_ sender: UIButton) {
        selectedTabIndex = 1
        updateTab()
    }
    
    @IBAction func selectTab2(_ sender: UIButton) {
        selectedTabIndex = 2
        updateTab()
    }
    
    @IBAction func selectTab3(_ sender: UIButton) {
        selectedTabIndex = 3
        updateTab()
    }
    
    @IBAction func selectTab4(_ sender: UIButton) {
        selectedTabIndex = 4
        updateTab()
    }
    
    @IBAction func selectTab5(_ sender: UIButton) {
        selectedTabIndex = 5
        updateTab()
    }
    
    private func updateTab() {
        tab1Bg.isHidden = true
        tab2Bg.isHidden = true
        tab3Bg.isHidden = true
        tab4Bg.isHidden = true
        tab5Bg.isHidden = true
        
        tab1Label.textColor = UIColor.white
        tab2Label.textColor = UIColor.white
        tab3Label.textColor = UIColor.white
        tab4Label.textColor = UIColor.white
        tab5Label.textColor = UIColor.white
        
        switch selectedTabIndex {
        case 1:
            noDataView.isHidden = true
            tab1Bg.isHidden = false
            tab1Label.textColor = MainColors.themeEndColors[selectedTheme]
            navRightImageView.isHidden = true
            loadFavoritedList()
            
        case 2:
            noDataView.isHidden = true
            tab2Bg.isHidden = false
            tab2Label.textColor = MainColors.themeEndColors[selectedTheme]
            navRightImageView.isHidden = false
            navRightImageView.image = UIImage(named: "my_shopping_calc_plus")
            navRightImageView.setTintColor(UIColor.white)
            loadFeaturedList(resetData: true, loadFirst: true)
        case 3:
            noDataView.isHidden = false
            tab3Bg.isHidden = false
            tab3Label.textColor = MainColors.themeEndColors[selectedTheme]
            navRightImageView.isHidden = true
            loadVideoList()
        case 4:
            noDataView.isHidden = true
            tab4Bg.isHidden = false
            tab4Label.textColor = MainColors.themeEndColors[selectedTheme]
            loadLiveVideoList(resetData: true, loadFirst: true)
            navRightImageView.isHidden = false
            navRightImageView.image = UIImage(named: "social_chat_video")
            navRightImageView.setTintColor(UIColor.white)
        case 5:
            noDataView.isHidden = true
            tab5Bg.isHidden = false
            tab5Label.textColor = MainColors.themeEndColors[selectedTheme]
            navRightImageView.isHidden = true
            loadPostsMine()
        default:
            noDataView.isHidden = false
            tab4Bg.isHidden = false
            tab4Label.textColor = MainColors.themeEndColors[selectedTheme]
        }
    }
    
    private func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
    private func loadLiveVideoList(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
//            self.tableView.isUserInteractionEnabled = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            self.endHeaderRefresh()
            return
        }
        SocialAPI.shared.liveList(page: self.page) { (json, success) in
            if success {
                self.tableView.isUserInteractionEnabled = true
                self.endFooterRefresh()
                self.endHeaderRefresh()
                ProgressHUD.dismiss()
                print("Live Video List............")
                print(json)
                if resetData {
                    self.videoList = []
                }
                let tempList = LiveVideoModel.getLiveVideosFromJson(json["data"])
                self.videoList.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                self.tableView.reloadData()
            } else {
                // try again...
                SocialAPI.shared.liveList(page: self.page, completion: { (json1, success1) in
                    self.tableView.isUserInteractionEnabled = true
                    self.endFooterRefresh()
                    self.endHeaderRefresh()
                    ProgressHUD.dismiss()
                    if success1 {
                        if resetData {
                            self.videoList = []
                        }
                        let tempList = LiveVideoModel.getLiveVideosFromJson(json1["data"])
                        self.videoList.append(contentsOf: tempList)
                        let lastPage = json1["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        self.tableView.reloadData()
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
        }
    }
    
    private func loadFeaturedList(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
//            self.tableView.isUserInteractionEnabled = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
//        if isEndData {
//            self.endFooterRefresh()
//            self.endHeaderRefresh()
//            return
//        }
        
        ProgressHUD.showWithStatus()
        FindAPI.shared.getPosts() { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                
                print("Posts...:", dic)
                self.arrayFeature.removeAllObjects()
                let arrayVideo = NSArray.init(array: dic["posts"] as! NSArray)
                
                if arrayVideo.count > 0 {
                    for dicFeature in arrayVideo {
                        
                        if (dicFeature as! NSDictionary)["deleted_at"] is NSNull {
                            self.arrayFeature.add(dicFeature as! NSDictionary)
                        }
                        
                    }
                    
                }
                
                self.tableView.reloadData()
                
                self.endFooterRefresh()
                self.endHeaderRefresh()

            } else {
                ProgressHUD.showErrorWithStatus("失败.")
                self.endFooterRefresh()
                self.endHeaderRefresh()

            }
        }
        
        
    }
    
    private func loadVideoList() {
        ProgressHUD.showWithStatus()
        FindAPI.shared.getPosts() { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                
                self.arrayFeature.removeAllObjects()
                print("Video Posts...:", dic)
                let arrayVideo = NSArray.init(array: dic["posts"] as! NSArray)
                
                if arrayVideo.count > 0 {
                    for dicFeature in arrayVideo {
                        let strArrayImage = (dicFeature as! NSDictionary)["images"] as! String

                        do {
                            let data  = try JSONSerialization.jsonObject(with: strArrayImage.data(using: .utf8)!, options: .allowFragments) as? NSArray
                            let arrayImage = NSArray.init(array: data!)
                            
                            for dicImage in arrayImage {
                                if (dicImage as! NSDictionary)["type"] as! NSInteger == 1 {
                                    self.arrayFeature.add(dicFeature as! NSDictionary)
                                    break
                                }
                            }
                            
                        }
                        catch {
                        }
                        
                    }
                }
                
                print(">>> video list:", self.arrayFeature)
                self.tableView.reloadData()
                
                self.endFooterRefresh()
                self.endHeaderRefresh()
                
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
                
                self.endFooterRefresh()
                self.endHeaderRefresh()
            }
        }
    }
    
    private func loadFavoritedList() {
        ProgressHUD.showWithStatus()
        FindAPI.shared.getFavorites() { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                
                print("favorites...:", dic)
                self.arrayFeature = NSMutableArray.init(array: dic["data"] as! NSArray)
                self.tableView.reloadData()
                
                self.endFooterRefresh()
                self.endHeaderRefresh()
                
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
                
                self.endFooterRefresh()
                self.endHeaderRefresh()
            }
        }
    }
    
    private func loadPostsMine() {
        ProgressHUD.showWithStatus()
        FindAPI.shared.getPostsMine() { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                
                print("posts mine...:", dic)
                self.arrayFeature = NSMutableArray.init(array: dic["data"] as! NSArray)
                self.tableView.reloadData()
                
                self.endFooterRefresh()
                self.endHeaderRefresh()
                
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
                
                self.endFooterRefresh()
                self.endHeaderRefresh()
            }
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
        if selectedTabIndex == 1 {
            self.loadFavoritedList()
            
        } else if selectedTabIndex == 2 {
            self.loadFeaturedList(resetData: true, loadFirst: false)
            
        } else if selectedTabIndex == 3 {
            self.loadVideoList()
            
        } else if selectedTabIndex == 5 {
            self.loadPostsMine()
            
        } else {
            self.loadLiveVideoList(resetData: true, loadFirst: false)
        }
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        if selectedTabIndex == 1 {
            self.loadFavoritedList()
            
        } else if selectedTabIndex == 2 {
            self.loadFeaturedList(resetData: true, loadFirst: false)
        
        } else if selectedTabIndex == 3 {
            self.loadVideoList()

        } else {
            self.loadLiveVideoList(resetData: false, loadFirst: false)
        }
        
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    
    private func getPlayUrl(video: LiveVideoModel) {
        let parameters: [String: Any] = [
            "uuid" : UserInstance.userId!,
            "video" : video.id!
        ]
        SocialAPI.shared.playUrl(params: parameters) { (json, success) in
            if success {
                print("Play Url..........")
                print(json)
                let playUrl = json["play_url"].stringValue
                
                if (video.live!) {
                    let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: LiveVideoPlayerVC.nameOfClass) as! LiveVideoPlayerVC
                    vc.liveVideoUrl = playUrl
                    vc.videoModel = video
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: LiveVideoPlayBackVC.nameOfClass) as! LiveVideoPlayBackVC
                    vc.liveVideoUrl = playUrl
                    vc.videoModel = video
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                // try again...
                SocialAPI.shared.playUrl(params: parameters, completion: { (json1, success1) in
                    if success1 {
                        let playUrl = json1["play_url"].stringValue
                        if (video.live!) {
                            let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: LiveVideoPlayerVC.nameOfClass) as! LiveVideoPlayerVC
                            vc.liveVideoUrl = playUrl
                            vc.videoModel = video
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: LiveVideoPlayBackVC.nameOfClass) as! LiveVideoPlayBackVC
                            vc.liveVideoUrl = playUrl
                            vc.videoModel = video
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        ProgressHUD.showErrorWithStatus("出了些问题。 请稍后再试")
                    }
                })
            }
        }
    }
    
}

extension FindVC: UITableViewDataSource, UITableViewDelegate, FeaturedCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTabIndex == 1 {
            return arrayFeature.count
            
        } else if selectedTabIndex == 2 {
            return arrayFeature.count
            
        } else if selectedTabIndex == 3 {
            return arrayFeature.count
            
        } else if selectedTabIndex == 4 {
            return videoList.count
            
        } else if selectedTabIndex == 5 {
            return arrayFeature.count
            
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTabIndex == 1 || selectedTabIndex == 2 || selectedTabIndex == 3 || selectedTabIndex == 5 {
            let cell: FeaturedCell = tableView.ts_dequeueReusableCell(FeaturedCell.self)
            cell.delegate = self
            cell.setupUI(self)
            cell.setInfo(dic: arrayFeature[indexPath.row] as! NSDictionary)
            cell.collectionList.reloadData()
            cell.setNeedsDisplay()
            return cell
        }
        let cell: FindVideoCell = tableView.ts_dequeueReusableCell(FindVideoCell.self)
        cell.setCellContent(videoList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedTabIndex == 1 || selectedTabIndex == 2 || selectedTabIndex == 3 || selectedTabIndex == 5 {
            let vc = UIStoryboard(name: "Find", bundle: nil).instantiateViewController(withIdentifier: FindContentDetailVC.nameOfClass) as! FindContentDetailVC
            vc.dicFeature = arrayFeature[indexPath.row] as! NSDictionary
            self.navigationController?.pushViewController(vc, animated: true)
        } else if selectedTabIndex == 4 {
            self.getPlayUrl(video: self.videoList[indexPath.row])
        }
    }
    
    // MARK: - FeaturedCell delegate
    func didTapButtonFeaturedCellFavorite() {
        if selectedTabIndex == 1 {
            self.loadFavoritedList()
            
        } else if selectedTabIndex == 3 {
            self.loadVideoList()
        }
        
    }
    
    func didTapButtonFeaturedCellDelete() {
        if selectedTabIndex == 5 {
            self.loadPostsMine()
        }
        
    }
    
    func didTapButtonFeaturedCellLike() {
        if selectedTabIndex == 1 {
            self.loadFavoritedList()
            
        } else if selectedTabIndex == 2 {
            self.loadFeaturedList(resetData: true, loadFirst: false)
            
        } else if selectedTabIndex == 3 {
            self.loadVideoList()
            
        } else if selectedTabIndex == 5 {
            self.loadPostsMine()
        }
        
    }
    
    func didTapButtonFeaturedCellActive() {
        if selectedTabIndex == 5 {
            self.loadPostsMine()
        }
    }
    
}























