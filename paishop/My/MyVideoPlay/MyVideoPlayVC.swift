
import UIKit
import MJRefresh

class MyVideoPlayVC: UIViewController {
    
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(MyVideoPlayCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 65
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    
    var videos: [LiveVideoModel] = []
    var page = 1
    var isEndData = true
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        
        self.loadVideos(resetData: true, loadFirst: true)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "视频回放"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func loadVideos(resetData: Bool, loadFirst: Bool) {
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
        MyAPI.shared.liveMine(page: self.page) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if resetData {
                self.tableView.isUserInteractionEnabled = true
            }
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Item Mine...")
                print(json)
                if resetData {
                    self.videos = []
                }
                let tempList = LiveVideoModel.getLiveVideosFromJson(json["data"])
                self.videos.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if self.videos.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
            } else {
                // try again...
                MyAPI.shared.itemMine(page: self.page, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.videos = []
                        }
                        let tempList = LiveVideoModel.getLiveVideosFromJson(json["data"])
                        self.videos.append(contentsOf: tempList)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    if self.videos.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
                    }
                })
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
        self.loadVideos(resetData: true, loadFirst: false)
    }
    
    private func footerRefreshing() {
        self.loadVideos(resetData: false, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }


}


extension MyVideoPlayVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyVideoPlayVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyVideoPlayCell = tableView.ts_dequeueReusableCell(MyVideoPlayCell.self)
        cell.setCellContent(self.videos[indexPath.row], index: indexPath.row, vc: self)        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}










