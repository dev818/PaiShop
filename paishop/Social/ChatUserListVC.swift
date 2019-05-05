

import UIKit
import MJRefresh

class ChatUserListVC: UIViewController {
    
    @IBOutlet weak var searchBar: LRSearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    

    @IBOutlet weak var confirmButton: UIButton! {
        didSet {
            confirmButton.setTitleColor(UIColor.lightGray, for: .normal)
            confirmButton.isEnabled = false
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.ts_registerCellNib(ChatUserListCell.self)
            tableView.estimatedRowHeight = 65
            tableView.tableFooterView = UIView()
        }
    }
    
    var users: [UserModel] = []
    var page = 1
    var isEndData = false
    var selectedCellIndex = -1
    var keyword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupRefresh()
        //self.loadUserList(resetData: true, loadFirst: true)
    }

    
    @IBAction func selectCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectConfirm(_ sender: Any) {
        let ids = [self.users[selectedCellIndex].id!]
        let parameters: [String : Any] = [
            "ids" : ids
        ]
        SocialAPI.shared.chatCreate(params: parameters) { (json, success) in
            if success {
                print("Chat Create...")
                print(json)
                let chatListItem = ChatListModel.init(json["room"])
                chatListItem.name = self.users[self.selectedCellIndex].name!
                let info: [String : Any] = [
                    "chatListItem" : chatListItem
                ]
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.CHAT_CREATE_ROOM), object: nil, userInfo: info)
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
        }
        
    }
    
    func loadUserList(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1            
            self.isEndData = false
            self.tableView.isUserInteractionEnabled = false
            self.selectedCellIndex = -1
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isEndData {
            self.endFooterRefresh()
            self.endHeaderRefresh()
            return
        }
        let parameters: [String: Any] = [
            "keyword" : keyword
        ]
        SocialAPI.shared.userList(page: self.page, params: parameters) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if resetData {
                self.tableView.isUserInteractionEnabled = true
            }
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("User List..........")
                print(json)
                if resetData {
                    self.users = []
                }
                let tempList = UserModel.getUsersFromJson(json["data"])
                self.users.append(contentsOf: tempList)
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
                SocialAPI.shared.userList(page: self.page, params: parameters, completion: { (json1, success1) in
                    if success1 {
                        if resetData {
                            self.users = []
                        }
                        let tempList = UserModel.getUsersFromJson(json1["data"])
                        self.users.append(contentsOf: tempList)
                        let lastPage = json1["last_page"].intValue
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        self.loadUserList(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        self.loadUserList(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }

}


extension ChatUserListVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatUserListCell = tableView.ts_dequeueReusableCell(ChatUserListCell.self)
        cell.setCellContent(self.users[indexPath.row])
        if self.selectedCellIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedCellIndex = indexPath.row
        tableView.ts_reloadData {
            self.confirmButton.setTitleColor(UIColor.black, for: .normal)
            self.confirmButton.isEnabled = true
        }
    }
    
}


extension ChatUserListVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            self.keyword = searchText
            self.loadUserList(resetData: true, loadFirst: false)
        }
    }
}



















