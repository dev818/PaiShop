
import UIKit
import MJRefresh

class HomeCommentVC: UIViewController {
    
    var productId: Int64!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(HomeCommentCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }    
    @IBOutlet weak var countLabel: UILabel!
    
    var comments: [CommentModel] = []
    var page = 1
    var isEndData = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        self.loadComments(resetData: true, loadFirst: true)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "评价"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func loadComments(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
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
            self.endHeaderRefresh()
            return
        }
        
        
        let parameters: [String : Any] = [
            "id" : self.productId
        ]
        HomeAPI.shared.commentItem(page: self.page, params: parameters) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if resetData {
                self.tableView.isHidden = false
                self.comments = []
            }
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                //print("Comment Item...")
                //print(json)
                let tempList = CommentModel.getCommentsFromJson(json["data"])
                self.comments.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                let total = json["total"].intValue
                self.countLabel.text = "宝贝评价(\(total))"
            }
            DispatchQueue.main.async {
                self.tableView.ts_reloadData { }
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
        self.loadComments(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        self.loadComments(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension HomeCommentVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension HomeCommentVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeCommentCell = tableView.ts_dequeueReusableCell(HomeCommentCell.self)
        cell.setCellContent(comments[indexPath.row])
        return cell
    }
    
}



















