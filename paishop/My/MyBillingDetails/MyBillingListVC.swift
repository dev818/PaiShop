
import UIKit
import MJRefresh

class MyBillingListVC: UIViewController {
    
    var currency: Int = 1
    var type = false
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
            tableView.ts_registerCellNib(MyBillingHeaderCell.self)
            tableView.ts_registerCellNib(MyBillingCell.self)
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    var billings: [BillingModel] = []
    var page = 1
    var isEndData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        self.setupRefresh()
        self.loadBillings(resetData: true, loadFirst: true)
    }
    
    private func setupNavBar() {
        if currency == 1 {
            navBar.lblTitle.text = "π 明细"
        }
        
        if currency == 2 {
            navBar.lblTitle.text = "¥ 明细"
        }
        
        if currency == 3 {
            navBar.lblTitle.text = "π 积分明细"
        }
        
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        segmentedControl.tintColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func loadBillings(resetData: Bool, loadFirst: Bool) {
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
            return
        }
        
        let parameters: [String : Any] = [
            "currency" : currency,
            "type" : type
        ]
        print("Parameters...", parameters)
        MyAPI.shared.transactionList(page: self.page, params: parameters) { (json, success) in
            if success {
                self.tableView.isUserInteractionEnabled = true
                self.endFooterRefresh()
                if loadFirst {
                    ProgressHUD.dismiss()
                }
                print("Billings...")
                print(json)
                if resetData {
                    self.billings = []
                }
                let tempItems = BillingModel.getBillingsFromJson(json["data"])
                self.billings.append(contentsOf: tempItems)
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
                MyAPI.shared.transactionList(page: self.page, params: parameters, completion: { (json, success1) in
                    self.tableView.isUserInteractionEnabled = true
                    self.endFooterRefresh()
                    if loadFirst {
                        ProgressHUD.dismiss()
                    }
                    if success1 {
                        if resetData {
                            self.billings = []
                        }
                        let tempItems = BillingModel.getBillingsFromJson(json["data"])
                        self.billings.append(contentsOf: tempItems)
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
        self.loadBillings(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.type = false
            self.loadBillings(resetData: true, loadFirst: true)
        } else if sender.selectedSegmentIndex == 1 {
            self.type = true
            self.loadBillings(resetData: true, loadFirst: true)
        }
    }
    
    
}

extension MyBillingListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return billings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: MyBillingHeaderCell = tableView.ts_dequeueReusableCell(MyBillingHeaderCell.self)
            return cell
        }
        let cell: MyBillingCell = tableView.ts_dequeueReusableCell(MyBillingCell.self)
        cell.setCellContent(billings[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension MyBillingListVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}























