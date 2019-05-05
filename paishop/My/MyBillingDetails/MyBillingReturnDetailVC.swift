
import UIKit
import MJRefresh

class MyBillingReturnDetailVC: UIViewController {
    
    var release: ReleaseModel!
    var releaseType: Bool!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.ts_registerCellNib(MyBillingReturnCell.self)
            tableView.ts_registerCellNib(MyBillingReturnDetailCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    
    @IBOutlet weak var remainTableView: UITableView! {
        didSet {
            remainTableView.dataSource = self
            remainTableView.delegate = self
            remainTableView.tableFooterView = UIView()
            remainTableView.ts_registerCellNib(MyBillingReturnCell.self)
            remainTableView.ts_registerCellNib(MyBillingReturnDetailRemainCell.self)
            remainTableView.rowHeight = UITableView.automaticDimension
            remainTableView.estimatedRowHeight = 300
            remainTableView.isHidden = true
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    var releaseTransactionList: [ReleaseTransactionModel] = []
    var page = 1
    var isEndData = false
    var totalReturnedCount = 0
    
    var remainingTransactionCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupRefresh()
        self.loadReleaseTransactionList(resetData: true, loadFirst: true)
        
        self.remainingTransactionCount = release.releasePeriod! - release.releaseCount!
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            remainTableView.isHidden = true
            ProgressHUD.showWithStatus()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                ProgressHUD.dismiss()
                self.tableView.isHidden = false
            })
        } else {
            tableView.isHidden = true
            ProgressHUD.showWithStatus()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                ProgressHUD.dismiss()
                self.remainTableView.isHidden = false
            })
        }
    }
    
    
    private func setupNavBar() {
        navBar.lblTitle.text = "返还详情"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        segmentedControl.tintColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func loadReleaseTransactionList(resetData: Bool, loadFirst: Bool) {
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
            self.tableView.isHidden = true
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        
        let parameters: [String : Any] = [
            "restitution_id" : release.id!
        ]
        MyAPI.shared.restitutionTransactionList(page: self.page, params: parameters) { (json, success) in
            if success {
                self.tableView.isUserInteractionEnabled = true
                self.endFooterRefresh()
                if loadFirst {
                    ProgressHUD.dismiss()
                    self.tableView.isHidden = false
                }
                print("Release Transaction List...")
                print(json)
                if resetData {
                    self.releaseTransactionList = []
                }
                let tempItems = ReleaseTransactionModel.getReleaseTransactionListFromJson(json["data"])
                self.releaseTransactionList.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                self.totalReturnedCount = json["total"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData {  }
                })
            } else {
                // try again...
                MyAPI.shared.restitutionTransactionList(page: self.page, params: parameters, completion: { (json, success1) in
                    self.tableView.isUserInteractionEnabled = true
                    self.endFooterRefresh()
                    if loadFirst {
                        ProgressHUD.dismiss()
                        self.tableView.isHidden = false
                    }
                    if success1 {
                        if resetData {
                            self.releaseTransactionList = []
                        }
                        let tempItems = ReleaseTransactionModel.getReleaseTransactionListFromJson(json["data"])
                        self.releaseTransactionList.append(contentsOf: tempItems)
                        let lastPage = json["last_page"].intValue
                        self.totalReturnedCount = json["total"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData {  }
                        })
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
    
    private func setupRefresh() {
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.tableView.mj_footer = refreshFooter
    }
    
    private func footerRefreshing() {
        self.loadReleaseTransactionList(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

}


extension MyBillingReturnDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyBillingReturnDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if tableView == remainTableView {
            return remainingTransactionCount
        }
        return releaseTransactionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: MyBillingReturnCell = tableView.ts_dequeueReusableCell(MyBillingReturnCell.self)
            cell.setCellContent(release, type: releaseType)
            return cell
        }
        
        if tableView == remainTableView {
            let cell: MyBillingReturnDetailRemainCell = tableView.ts_dequeueReusableCell(MyBillingReturnDetailRemainCell.self)
            cell.setCellContent(release, releaseType: releaseType, row: indexPath.row)
            return cell
        }
        
        let cell: MyBillingReturnDetailCell = tableView.ts_dequeueReusableCell(MyBillingReturnDetailCell.self)
        cell.setCellContent(releaseTransactionList[indexPath.row], releasePeriod: release.releasePeriod!, index: indexPath.row)
        return cell
    }
    
}
















