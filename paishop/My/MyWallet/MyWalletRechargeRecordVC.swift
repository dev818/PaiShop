
import UIKit
import MJRefresh

class MyWalletRechargeRecordVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.ts_registerCellNib(MyWalletRechargeRecordCell.self)
            tableView.ts_registerCellNib(MyWalletRecordHeaderCell.self)
        }
    }
    
    var paymentLists: [PaymentListModel] = []
    var page = 1
    var isEndData = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupRefresh()
        self.loadPaymentList(resetData: true, loadFirst: true)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "充值记录"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }

    private func loadPaymentList(resetData: Bool, loadFirst: Bool) {
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
            "type" : true
        ]
        MyAPI.shared.paymentList(page: self.page, params: parameters) { (json, success) in            
            if success {
                self.tableView.isUserInteractionEnabled = true
                self.endFooterRefresh()
                if loadFirst {
                    ProgressHUD.dismiss()
                }
                print("Payment List...")
                print(json)
                if resetData {
                    self.paymentLists = []
                }
                let tempItems = PaymentListModel.getPaymentListsFromJson(json["data"])
                self.paymentLists.append(contentsOf: tempItems)
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
                MyAPI.shared.paymentList(page: self.page, params: parameters, completion: { (json, success1) in
                    self.tableView.isUserInteractionEnabled = true
                    self.endFooterRefresh()
                    if loadFirst {
                        ProgressHUD.dismiss()
                    }
                    if success1 {
                        if resetData {
                            self.paymentLists = []
                        }
                        let tempItems = PaymentListModel.getPaymentListsFromJson(json["data"])
                        self.paymentLists.append(contentsOf: tempItems)
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
        self.loadPaymentList(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    

}


extension MyWalletRechargeRecordVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return paymentLists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: MyWalletRecordHeaderCell = tableView.ts_dequeueReusableCell(MyWalletRecordHeaderCell.self)
            cell.paymentTypeLabel.text = "充值金额"
            return cell
        }
        let cell: MyWalletRechargeRecordCell = tableView.ts_dequeueReusableCell(MyWalletRechargeRecordCell.self)
        cell.setCellContent(paymentLists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletRechargeDetailVC.nameOfClass) as! MyWalletRechargeDetailVC
        vc.paymentDetail = self.paymentLists[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension MyWalletRechargeRecordVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}













