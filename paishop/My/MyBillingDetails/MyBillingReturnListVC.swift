

import UIKit
import MJRefresh

class MyBillingReturnListVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.ts_registerCellNib(MyBillingReturnCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    var releaseList: [ReleaseModel] = []
    var type = false
    var page = 1
    var isEndData = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupRefresh()
        self.loadReleaseList(resetData: true, loadFirst: true)
        
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "返还明细"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        segmentedControl.tintColor = MainColors.themeEndColors[selectedTheme]
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            type = false
        } else {
            type = true
        }
        self.loadReleaseList(resetData: true, loadFirst: true)
    }
    
    private func loadReleaseList(resetData: Bool, loadFirst: Bool) {
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
            "type" : type
        ]
        MyAPI.shared.restitutionList(page: self.page, params: parameters) { (json, success) in
            if success {
                self.tableView.isUserInteractionEnabled = true
                self.endFooterRefresh()
                if loadFirst {
                    ProgressHUD.dismiss()
                    self.tableView.isHidden = false
                }
                print("Release List...")
                print(json)
                if resetData {
                    self.releaseList = []
                }
                let tempItems = ReleaseModel.getReleaseListFromJson(json["data"])
                self.releaseList.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
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
                MyAPI.shared.restitutionList(page: self.page, params: parameters, completion: { (json, success1) in
                    self.tableView.isUserInteractionEnabled = true
                    self.endFooterRefresh()
                    if loadFirst {
                        ProgressHUD.dismiss()
                        self.tableView.isHidden = false
                    }
                    if success1 {
                        if resetData {
                            self.releaseList = []
                        }
                        let tempItems = ReleaseModel.getReleaseListFromJson(json["data"])
                        self.releaseList.append(contentsOf: tempItems)
                        let lastPage = json["last_page"].intValue
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
        self.loadReleaseList(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    
}


extension MyBillingReturnListVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyBillingReturnListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.releaseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyBillingReturnCell = tableView.ts_dequeueReusableCell(MyBillingReturnCell.self)
        cell.setCellContent(releaseList[indexPath.row], type: self.type)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingReturnDetailVC.nameOfClass) as! MyBillingReturnDetailVC
        vc.release = self.releaseList[indexPath.row]
        vc.releaseType = self.type
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
















