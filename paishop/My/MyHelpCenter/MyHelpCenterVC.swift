
import UIKit
import MJRefresh

class MyHelpCenterVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.ts_registerCellNib(MyHelpCenterListCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    
    @IBOutlet var postView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var postButtonBg: GradientView!
    
    
    var tickets: [TicketListModel] = []
    var page = 1
    var isEndData = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupPostView()
        self.setupRefresh()
        self.setupTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivePushTicket(_:)), name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil)
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        postButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        postButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTicketList(resetData: true, loadFirst: true)
        UserDefaultsUtil.shared.setIsOpenTicketList(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaultsUtil.shared.setIsOpenTicketList(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "客服中心"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        navBar.rightButton.isHidden = false
        navBar.rightButton.setTitle(nil, for: .normal)
        navBar.rightButtonImageView.isHidden = false
        navBar.rightButtonImageView.image = ImageAsset.my_shopping_calc_plus.image
        navBar.rightButtonImageView.setTintColor(UIColor.white)
        navBar.rightButton.addTarget(self, action: #selector(selectNavRight), for: .touchUpInside)
    }
    
    private func loadTicketList(resetData: Bool, loadFirst: Bool) {
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
        
        MyAPI.shared.ticketList(page: self.page) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            self.tableView.isUserInteractionEnabled = true
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Ticket List...")
                print(json)
                if resetData {
                    self.tickets = []
                }
                let tempItems = TicketListModel.getTicketListsFromJson(json["data"])
                self.tickets.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.ts_reloadData { }
                }
                if self.tickets.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
            } else {
                // try again...
                MyAPI.shared.ticketList(page: self.page, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.tickets = []
                        }
                        let tempItems = TicketListModel.getTicketListsFromJson(json["data"])
                        self.tickets.append(contentsOf: tempItems)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
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
                    
                    DispatchQueue.main.async {
                        self.tableView.ts_reloadData { }
                    }
                    if self.tickets.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = false
                    }
                })
                
            }
            
            
        }
    }
    
    private func setupPostView() {
        self.view.addSubview(postView)
        postView.translatesAutoresizingMaskIntoConstraints = false
        postView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(282)
            make.width.equalTo(300)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
            
        }
        postTextView.placeholder = "请在这里写下"
        
        let darkViewTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(darkViewTap)
    }
    

    @objc func selectNavRight() {
        self.postView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    @IBAction func closePostView(_ sender: UIButton) {
        self.hidePostView()
    }
    
    
    @IBAction func selectPost(_ sender: Any) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        let postText = postTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if postText.count < 2 {
            ProgressHUD.showErrorWithStatus("请输入有效的内容.")
            return
        }
        let parameters: [String : Any] = [
            "content" : postText
        ]
        ProgressHUD.showWithStatus()
        MyAPI.shared.ticketCreate(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            self.hidePostView()
            if success {
                print("Ticket Create...")
                print(json)
                DispatchQueue.main.async {
                    var ticketListModel = TicketListModel.init(json["ticket"])
                    ticketListModel.status = 2
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TicketMessageVC.nameOfClass) as! TicketMessageVC
                    vc.ticketListModel = ticketListModel
                    self.pushAndHideTabbar(vc)
                }
            } else {
                ProgressHUD.showErrorWithStatus("无法发布您的内容. 请稍后再试.")
            }
        }
        
        
    }
    
    @objc func selectDarkView() {
        //self.hidePostView()
    }
    
    @objc func receivePushTicket(_ notification: NSNotification) {
        guard let ticket = notification.userInfo?["ticket"] as? TicketListModel else { return }
        guard let status = notification.userInfo?["status"] as? String else { return }
        if status == "response" {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TicketMessageVC.nameOfClass) as! TicketMessageVC
            vc.ticketListModel = ticket
            self.pushAndHideTabbar(vc)
        }
    }
    
    
    
    
    private func hidePostView() {
        postTextView.text = ""
        postTextView.resignFirstResponder()
        postView.snp.updateConstraints { (make) in
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
    
    private func showDarkView(_ state: Bool) {
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
    
    private func deleteTicketRoom(_ id: Int, indexPath: IndexPath) {
        let parameters: [String : Any] = [
            "id" : id
        ]
        MyAPI.shared.ticketDelete(params: parameters) { (json, success) in
            if success {
                print("Ticket Delete...")
                print(json)
                self.tickets.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                // try again...
                MyAPI.shared.ticketDelete(params: parameters, completion: { (json, success1) in
                    if success1 {
                        self.tickets.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                })
            }
            
            if self.tickets.count > 0 {
                self.noDataView.isHidden = true
            } else {
                self.noDataView.isHidden = false
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
        self.loadTicketList(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        self.loadTicketList(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

}


extension MyHelpCenterVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyHelpCenterVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyHelpCenterListCell = tableView.ts_dequeueReusableCell(MyHelpCenterListCell.self)
        cell.setCellContent(tickets[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TicketMessageVC.nameOfClass) as! TicketMessageVC
        vc.ticketListModel = self.tickets[indexPath.row]
        self.pushAndHideTabbar(vc)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteTicketRoom(self.tickets[indexPath.row].id, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    
}











