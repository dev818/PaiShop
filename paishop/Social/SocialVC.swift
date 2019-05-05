

import UIKit
import SwiftyJSON
import ObjectMapper
import MJRefresh


class SocialVC: UIViewController {
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            // Table View Setup
            tableView.ts_registerCellNib(ChatListCell.self)
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 65
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var noDataImageView: UIImageView! {
        didSet {
            noDataImageView.isHidden = true
        }
    }
    
    
    var chatList: [ChatListModel] = []
    var page = 1
    var isEndData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.setupRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(openChatMessage(_:)), name: NSNotification.Name(Notifications.CHAT_CREATE_ROOM), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivePushMessage(_:)), name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserInstance.isLogin {
            self.showUI(true)
            self.loadChatList(resetData: true, loadFirst: true)
            SocialAPI.shared.chatBadge(completion: { (json, success) in
                if success {
                    print("Chat Badge...")
                    print(json)
                } else {
                    SocialAPI.shared.chatBadge(completion: { (json, success1) in
                        if success1 {
                            
                        }
                    })
                }
            })
            UserDefaultsUtil.shared.setIsOpenChatList(true)
        } else {
            self.showUI(false)
            self.goToLoginVC()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaultsUtil.shared.setIsOpenChatList(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func setupNavBar() {
        navBar.lblTitle.text = "消息"
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
    
    
    
    
    @objc func selectNavRight() {
        Utils.applyTouchEffect(navBar.rightButtonImageView)
        let chatUserListVC = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: ChatUserListVC.nameOfClass)
        self.present(chatUserListVC, animated: true, completion: nil)
    }
    
    @objc func openChatMessage(_ notification: NSNotification) {
        if let chatListItem = notification.userInfo?["chatListItem"] as? ChatListModel {
            self.openChatMessageVC(chatListItem)
        }
    }
    
    @objc func receivePushMessage(_ notification: NSNotification) {
        guard let type = notification.userInfo?["type"] as? String else { return }
        if type != UserDefaultsUtil.shared.IS_OPEN_CHAT_LIST {
            return
        }
        guard let message = notification.userInfo?["message"] as? ChatMessageModel else { return }
        
        guard let status = notification.userInfo?["status"] as? String else { return }
        if status == "receive" {
            self.tableView.isScrollEnabled = false
            self.reloadChatListWithMessage(message)
            self.tableView.isScrollEnabled = true
        } else { // status == "response"
            var isRoomExist = false
            for chatListItem in self.chatList {
                if chatListItem.id == message.roomId! {
                    self.openChatMessageVC(chatListItem)
                    isRoomExist = true
                    continue
                }
            }
            if !isRoomExist {
                let parameters: [String : Any] = [
                    "id" : message.roomId!
                ]
                SocialAPI.shared.chatDetail(params: parameters, completion: { (json, success) in
                    if success {
                        DispatchQueue.main.async {
                            let room = ChatListModel(json["room"])
                            self.openChatMessageVC(room)
                        }
                    } else {
                        // try again...
                        SocialAPI.shared.chatDetail(params: parameters, completion: { (json, success1) in
                            if success1 {
                                DispatchQueue.main.async {
                                    let room = ChatListModel(json["room"])
                                    self.openChatMessageVC(room)
                                }
                            }
                        })
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
        self.loadChatList(resetData: true, loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        self.loadChatList(resetData: false, loadFirst: false)
    }
    
    private func endFooterRefresh() {
        self.tableView.mj_footer.endRefreshing()
    }
    
    private func loadChatList(resetData: Bool, loadFirst: Bool) {
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
        SocialAPI.shared.chatList(page: self.page) { (json, success) in
            if success {
                self.endFooterRefresh()
                self.endHeaderRefresh()
                ProgressHUD.dismiss()
                self.tableView.isUserInteractionEnabled = true
                
                print("Chat List.....")
                print(json)
                if resetData {
                    self.chatList = []
                }
                let tempList = ChatListModel.getChatListsFromJson(json["data"])
                self.chatList.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if self.chatList.count > 0 {
                    self.noDataImageView.isHidden = true
                    self.tableView.backgroundColor = MainColors.defaultBackground
                } else {
                    self.noDataImageView.isHidden = false
                    self.tableView.backgroundColor = UIColor.white
                }
            } else {
                // try again...
                SocialAPI.shared.chatList(page: self.page, completion: { (json1, success1) in
                    self.endFooterRefresh()
                    self.endHeaderRefresh()
                    ProgressHUD.dismiss()
                    self.tableView.isUserInteractionEnabled = true
                    
                    if success1 {
                        if resetData {
                            self.chatList = []
                        }
                        let tempList = ChatListModel.getChatListsFromJson(json1["data"])
                        self.chatList.append(contentsOf: tempList)
                        let lastPage = json1["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    if self.chatList.count > 0 {
                        self.noDataImageView.isHidden = true
                        self.tableView.backgroundColor = MainColors.defaultBackground
                    } else {
                        self.noDataImageView.isHidden = false
                        self.tableView.backgroundColor = UIColor.white
                    }
                })
            }
        }
    }
    
    private func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
    private func showUI(_ show: Bool) {
        tableView.isHidden = !show
        noDataImageView.isHidden = true
    }
    
    
    func openChatMessageVC(_ chatListItem: ChatListModel) {
        let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: ChatVC.nameOfClass) as! ChatVC
        vc.chatListModel = chatListItem
        self.pushAndHideTabbar(vc)
    }
    
    private func reloadChatListWithMessage(_ message: ChatMessageModel) {
        if self.chatList.count == 0 {
            self.addNewChatRoom(message.roomId!)
            return
        }
        var isRoomExist = false
        for i in 0..<self.chatList.count {
            let chatListItem = self.chatList[i]
            if chatListItem.id == message.roomId! {
                isRoomExist = true
                self.chatList.remove(at: i)
                chatListItem.lastMessage = message
                chatListItem.updatedAt = message.updatedAt
                chatListItem.dateString = chatListItem.getFormattedDateString(message.updatedAt!)
                self.chatList.insert(chatListItem, at: 0)
                self.tableView.ts_reloadData {}
                continue
            }
        }
        if !isRoomExist {
            self.addNewChatRoom(message.roomId!)
        }
    }
    
    
    private func addNewChatRoom(_ id: Int64) {
        let parameters: [String : Any] = [
            "id" : id
        ]
        SocialAPI.shared.chatDetail(params: parameters) { (json, success) in
            if success {
                //print("Chat Detail...........")
                //print(json)
                let room = ChatListModel(json["room"])
                self.chatList.insert(room, at: 0)
                self.tableView.ts_reloadData {   }
            } else {
                // try again...
                SocialAPI.shared.chatDetail(params: parameters, completion: { (json, success1) in
                    if success1 {
                        let room = ChatListModel(json["room"])
                        self.chatList.insert(room, at: 0)
                        self.tableView.ts_reloadData {   }
                    }
                })
            }
            
            if self.chatList.count > 0 {
                self.noDataImageView.isHidden = true
                self.tableView.backgroundColor = MainColors.defaultBackground
            } else {
                self.noDataImageView.isHidden = false
                self.tableView.backgroundColor = UIColor.white
            }
        }
    }
    
    private func leaveRoom(_ id: Int64, indexPath: IndexPath) {
        let parameters: [String : Any] = [ "id" : id]
        SocialAPI.shared.chatLeave(params: parameters) { (json, success) in
            if success {
                print("Chat Leave...")
                print(json)
                self.chatList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                // try again...
                SocialAPI.shared.chatLeave(params: parameters, completion: { (json, success1) in
                    if success1 {
                        self.chatList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                })
            }
            
            if self.chatList.count > 0 {
                self.noDataImageView.isHidden = true
                self.tableView.backgroundColor = MainColors.defaultBackground
            } else {
                self.noDataImageView.isHidden = false
                self.tableView.backgroundColor = UIColor.white
            }
        }
    }
    
    
}


extension SocialVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatListCell = tableView.ts_dequeueReusableCell(ChatListCell.self)
        cell.setCellContent(self.chatList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.openChatMessageVC(self.chatList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.leaveRoom(self.chatList[indexPath.row].id, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
}

extension SocialVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}



/*
class SocialVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navFrame: UIView!
    @IBOutlet weak var navChatImageView: UIImageView!
    @IBOutlet weak var navVideoImageView: UIImageView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            // Table View Setup
            chatTableView.ts_registerCellNib(ChatListCell.self)
            chatTableView.rowHeight = UITableViewAutomaticDimension
            chatTableView.estimatedRowHeight = 65
            chatTableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var liveVideoTableView: UITableView! {
        didSet {
            liveVideoTableView.ts_registerCellNib(LiveVideoListCell.self)
            liveVideoTableView.rowHeight = UITableViewAutomaticDimension
            liveVideoTableView.estimatedRowHeight = 300
            liveVideoTableView.tableFooterView = UIView()
            liveVideoTableView.isHidden = true
        }
    }
    
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }    
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    
    var chatList: [ChatListModel] = []
    var chatPage = 1
    var isChatEndData = false
    
    var liveVideoList: [LiveVideoModel] = []
    var liveVideoPage = 1
    var isLiveVideoEndData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupRefresh()
        self.setupTheme()
        self.setupNavBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(openChatMessage(_:)), name: NSNotification.Name(Notifications.CHAT_CREATE_ROOM), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivePushMessage(_:)), name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSegmentChange(_:)), name: NSNotification.Name(Notifications.CHANGE_CHAT_SEGMENT), object: nil)
        
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = ""
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        segment.tintColor = MainColors.themeEndColors[selectedTheme]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserInstance.isLogin {
            self.showUI(true)
            
            if self.segment.selectedSegmentIndex == 0 {
                self.loadChatList(resetData: true, loadFirst: true)
            } else {
                self.loadLiveVideoList(resetData: true, loadFirst: true)
            }
            
            SocialAPI.shared.chatBadge(completion: { (json, success) in
                if success {
                    print("Chat Badge...")
                    print(json)
                } else {
                    SocialAPI.shared.chatBadge(completion: { (json, success1) in
                        if success1 {
                            
                        }
                    })
                }
            })
        } else {
            self.showUI(false)
            self.goToLoginVC()
        }
        UserDefaultsUtil.shared.setIsOpenChatList(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaultsUtil.shared.setIsOpenChatList(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }    
    
    @IBAction func selectChat(_ sender: UIButton) {
        Utils.applyTouchEffect(navChatImageView)
        let chatUserListVC = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: ChatUserListVC.nameOfClass)
        self.present(chatUserListVC, animated: true, completion: nil)
    }
    
    @IBAction func selectVideo(_ sender: UIButton) {
        Utils.applyTouchEffect(navVideoImageView)
        
        if Utils.isIpad() {
            ProgressHUD.showWarningWithStatus("视频直播推流不支持ipad!")
            return
        }
        
        if UserInstance.degreeId! < 1 {
            ProgressHUD.showWarningWithStatus("请升级您的帐户!")
        } else if !UserInstance.hasVerifiedStore() {
            ProgressHUD.showWarningWithStatus("你没有你的商店或你的商店仍在审查中!")
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPostVC.nameOfClass) as! LiveVideoPostVC
            let navVC = UINavigationController(rootViewController: vc)
            navVC.isNavigationBarHidden = true
            self.present(navVC, animated: true, completion: nil)
        }
        
    }
    
    
    
    
    private func loadChatList(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.chatPage = 1
            self.isChatEndData = false
            self.chatTableView.isUserInteractionEnabled = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isChatEndData {
            self.endFooterRefresh()
            self.endHeaderRefresh()
            return
        }
        SocialAPI.shared.chatList(page: self.chatPage) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if resetData {
                self.chatTableView.isUserInteractionEnabled = true
            }
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Chat List.....")
                print(json)
                if resetData {
                    self.chatList = []
                }
                let tempList = ChatListModel.getChatListsFromJson(json["data"])
                self.chatList.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.chatPage == lastPage {
                    self.isChatEndData = true
                } else {
                    self.chatPage += 1
                }
                
                DispatchQueue.main.async {
                    self.chatTableView.ts_reloadData {
                    }
                }
                if self.chatList.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = true
                    self.noDataLabel.text = "您没有任何聊天记录"
                }
            } else {
                // try again...
                SocialAPI.shared.chatList(page: self.chatPage, completion: { (json1, success1) in
                    if success1 {
                        if resetData {
                            self.chatList = []
                        }
                        let tempList = ChatListModel.getChatListsFromJson(json1["data"])
                        self.chatList.append(contentsOf: tempList)
                        let lastPage = json1["last_page"].intValue
                        if self.chatPage == lastPage {
                            self.isChatEndData = true
                        } else {
                            self.chatPage += 1
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.chatTableView.ts_reloadData {
                        }
                    }
                    if self.chatList.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = true
                        self.noDataLabel.text = "您没有任何聊天记录"
                    }
                })
            }
        }        
    }
    
    private func loadLiveVideoList(resetData: Bool, loadFirst: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.liveVideoPage = 1
            self.isLiveVideoEndData = false
            self.liveVideoTableView.isUserInteractionEnabled = false
        }
        if loadFirst {
            ProgressHUD.showWithStatus()
        }
        if isLiveVideoEndData {
            self.endFooterRefresh()
            self.endHeaderRefresh()
            return
        }
        SocialAPI.shared.liveList(page: self.liveVideoPage) { (json, success) in
            self.endFooterRefresh()
            self.endHeaderRefresh()
            if resetData {
                self.liveVideoTableView.isUserInteractionEnabled = true
            }
            if loadFirst {
                ProgressHUD.dismiss()
            }
            if success {
                print("Live Video List............")
                print(json)
                if resetData {
                    self.liveVideoList = []
                }
                let tempList = LiveVideoModel.getLiveVideosFromJson(json["data"])
                self.liveVideoList.append(contentsOf: tempList)
                let lastPage = json["last_page"].intValue
                if self.liveVideoPage == lastPage {
                    self.isLiveVideoEndData = true
                } else {
                    self.liveVideoPage += 1
                }
                
                DispatchQueue.main.async {
                    self.liveVideoTableView.ts_reloadData { }
                }
                if self.liveVideoList.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = true
                    self.noDataLabel.text = "没有实时视频"
                }
            } else {
                // try again...
                SocialAPI.shared.liveList(page: self.liveVideoPage, completion: { (json1, success1) in
                    if success1 {
                        if resetData {
                            self.liveVideoList = []
                        }
                        let tempList = LiveVideoModel.getLiveVideosFromJson(json1["data"])
                        self.liveVideoList.append(contentsOf: tempList)
                        let lastPage = json1["last_page"].intValue
                        if self.liveVideoPage == lastPage {
                            self.isLiveVideoEndData = true
                        } else {
                            self.liveVideoPage += 1
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.liveVideoTableView.ts_reloadData { }
                    }
                    if self.liveVideoList.count > 0 {
                        self.noDataView.isHidden = true
                    } else {
                        self.noDataView.isHidden = true
                        self.noDataLabel.text = "没有实时视频"
                    }
                })
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            chatTableView.isHidden = false
            liveVideoTableView.isHidden = true
            self.loadChatList(resetData: true, loadFirst: true)
        } else if sender.selectedSegmentIndex == 1 {
            chatTableView.isHidden = true
            liveVideoTableView.isHidden = false
            self.loadLiveVideoList(resetData: true, loadFirst: true)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == ChatVC.nameOfClass {
            let vc = segue.destination as! ChatVC
            let index = sender as! Int
            vc.chatListModel = self.chatList[index]
        }
    }
    
    private func goToLoginVC() {
        let loginVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: LoginVC.nameOfClass) as! LoginVC
        let loginNav = UINavigationController(rootViewController: loginVC)
        self.present(loginNav, animated: true, completion: nil)
    }
    
    private func showUI(_ show: Bool) {
        self.navFrame.isHidden = !show
        if self.segment.selectedSegmentIndex == 0 {
            self.chatTableView.isHidden = !show
        } else {
            self.liveVideoTableView.isHidden = !show
        }
    }
    
    
    private func setupRefresh() {
        let refreshHeader1 = MJRefreshNormalHeader {
            self.headerRefreshing()
        }
        refreshHeader1?.lastUpdatedTimeLabel.isHidden = true
        refreshHeader1?.setTitle("拉下来刷新", for: MJRefreshState.idle)
        refreshHeader1?.setTitle("释放以刷新", for: .pulling)
        refreshHeader1?.setTitle("装载...", for: .refreshing)
        self.chatTableView.mj_header = refreshHeader1
        
        let refreshHeader2 = MJRefreshNormalHeader {
            self.headerRefreshing()
        }
        refreshHeader2?.lastUpdatedTimeLabel.isHidden = true
        refreshHeader2?.setTitle("拉下来刷新", for: MJRefreshState.idle)
        refreshHeader2?.setTitle("释放以刷新", for: .pulling)
        refreshHeader2?.setTitle("装载...", for: .refreshing)
        self.liveVideoTableView.mj_header = refreshHeader2
        
        let refreshFooter1 = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter1?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter1?.setTitle("装载...", for: .refreshing)
        self.chatTableView.mj_footer = refreshFooter1
        
        let refreshFooter2 = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter2?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter2?.setTitle("装载...", for: .refreshing)
        self.liveVideoTableView.mj_footer = refreshFooter2
    }
    
    private func headerRefreshing() {
        if self.segment.selectedSegmentIndex == 0 {
            self.loadChatList(resetData: true, loadFirst: false)
        } else {
            self.loadLiveVideoList(resetData: true, loadFirst: false)
        }
    }
    
    private func endHeaderRefresh() {
        self.chatTableView.mj_header.endRefreshing()
        self.liveVideoTableView.mj_header.endRefreshing()
    }
    
    private func footerRefreshing() {
        if self.segment.selectedSegmentIndex == 0 {
           self.loadChatList(resetData: false, loadFirst: false)
        } else {
            self.loadLiveVideoList(resetData: false, loadFirst: false)
        }
    }
    
    private func endFooterRefresh() {
        self.chatTableView.mj_footer.endRefreshing()
        self.liveVideoTableView.mj_footer.endRefreshing()
    }
    
    
    @objc func openChatMessage(_ notification: NSNotification) {
        if let chatListItem = notification.userInfo?["chatListItem"] as? ChatListModel {
            self.openChatMessageVC(chatListItem)
        }
    }
    
    @objc func receivePushMessage(_ notification: NSNotification) {
        guard let type = notification.userInfo?["type"] as? String else { return }
        if type != UserDefaultsUtil.shared.IS_OPEN_CHAT_LIST {
            return
        }
        guard let message = notification.userInfo?["message"] as? ChatMessageModel else { return }
        
        guard let status = notification.userInfo?["status"] as? String else { return }
        if status == "receive" {
            self.chatTableView.isScrollEnabled = false
            self.reloadChatListWithMessage(message)
            self.chatTableView.isScrollEnabled = true
        } else { // status == "response"
            var isRoomExist = false
            for chatListItem in self.chatList {
                if chatListItem.id == message.roomId! {
                    self.openChatMessageVC(chatListItem)
                    isRoomExist = true
                    continue
                }
            }
            if !isRoomExist {
                let parameters: [String : Any] = [
                    "id" : message.roomId!
                ]
                SocialAPI.shared.chatDetail(params: parameters, completion: { (json, success) in
                    if success {
                        DispatchQueue.main.async {
                            let room = ChatListModel(json["room"])
                            self.openChatMessageVC(room)
                        }                        
                    } else {
                        // try again...
                        SocialAPI.shared.chatDetail(params: parameters, completion: { (json, success1) in
                            if success1 {
                                DispatchQueue.main.async {
                                    let room = ChatListModel(json["room"])
                                    self.openChatMessageVC(room)
                                }
                            }
                        })
                    }
                })
            }
        }
        
    }
    
    @objc func receiveSegmentChange(_ notification: NSNotification) {
        segment.selectedSegmentIndex = 1
        segment.sendActions(for: .valueChanged)
    }
    
    
    func openChatMessageVC(_ chatListItem: ChatListModel) {
        let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: ChatVC.nameOfClass) as! ChatVC
        vc.chatListModel = chatListItem
        self.pushAndHideTabbar(vc)
    }
    
    private func reloadChatListWithMessage(_ message: ChatMessageModel) {
        if self.chatList.count == 0 {
            self.addNewChatRoom(message.roomId!)
            return
        }
        var isRoomExist = false
        for i in 0..<self.chatList.count {
            let chatListItem = self.chatList[i]
            if chatListItem.id == message.roomId! {
                isRoomExist = true
                self.chatList.remove(at: i)
                chatListItem.lastMessage = message
                chatListItem.updatedAt = message.updatedAt
                chatListItem.dateString = chatListItem.getFormattedDateString(message.updatedAt!)
                self.chatList.insert(chatListItem, at: 0)
                self.chatTableView.ts_reloadData {        }
                continue
            }
        }
        if !isRoomExist {
            self.addNewChatRoom(message.roomId!)
        }
        
    }
    
    private func addNewChatRoom(_ id: Int64) {
        let parameters: [String : Any] = [
            "id" : id
        ]
        SocialAPI.shared.chatDetail(params: parameters) { (json, success) in
            if success {
                //print("Chat Detail...........")
                //print(json)
                let room = ChatListModel(json["room"])
                self.chatList.insert(room, at: 0)
                self.chatTableView.ts_reloadData {   }
            } else {
                // try again...
                SocialAPI.shared.chatDetail(params: parameters, completion: { (json, success1) in
                    if success1 {
                        let room = ChatListModel(json["room"])
                        self.chatList.insert(room, at: 0)
                        self.chatTableView.ts_reloadData {   }
                    }
                })
            }
            
            if self.chatList.count > 0 {
                self.noDataView.isHidden = true
            } else {
                self.noDataView.isHidden = true
                self.noDataLabel.text = "您没有任何聊天记录"
            }
        }
    }
    
    private func leaveRoom(_ id: Int64, indexPath: IndexPath) {
        let parameters: [String : Any] = [ "id" : id]
        SocialAPI.shared.chatLeave(params: parameters) { (json, success) in
            if success {
                print("Chat Leave...")
                print(json)
                self.chatList.remove(at: indexPath.row)
                self.chatTableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                // try again...
                SocialAPI.shared.chatLeave(params: parameters, completion: { (json, success1) in
                    if success1 {
                        self.chatList.remove(at: indexPath.row)
                        self.chatTableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                })
            }
            
            if self.chatList.count > 0 {
                self.noDataView.isHidden = true
            } else {
                self.noDataView.isHidden = true
                self.noDataLabel.text = "您没有任何聊天记录"
            }
        }
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
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPlayerVC.nameOfClass) as! LiveVideoPlayerVC
                    vc.liveVideoUrl = playUrl
                    vc.videoModel = video
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPlayBackVC.nameOfClass) as! LiveVideoPlayBackVC
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
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPlayerVC.nameOfClass) as! LiveVideoPlayerVC
                            vc.liveVideoUrl = playUrl
                            vc.videoModel = video
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPlayBackVC.nameOfClass) as! LiveVideoPlayBackVC
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


extension SocialVC: UITableViewDataSource, UITableViewDelegate {    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == chatTableView {
            return  chatList.count
        }
        return liveVideoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == chatTableView {
            let cell: ChatListCell = tableView.ts_dequeueReusableCell(ChatListCell.self)
            cell.setCellContent(self.chatList[indexPath.row])
            return cell
        }
        let cell: LiveVideoListCell = tableView.ts_dequeueReusableCell(LiveVideoListCell.self)
        cell.setCellContent(self.liveVideoList[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == chatTableView {
            self.openChatMessageVC(self.chatList[indexPath.row])
        } else {
            self.getPlayUrl(video: self.liveVideoList[indexPath.row])
            /*let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPlayerVC.nameOfClass) as! LiveVideoPlayerVC
            self.navigationController?.pushViewController(vc, animated: true)*/
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == chatTableView {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.leaveRoom(self.chatList[indexPath.row].id, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
}



extension SocialVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

*/










