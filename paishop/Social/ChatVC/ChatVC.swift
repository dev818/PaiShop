
import UIKit
import SnapKit
import RxSwift
import MJRefresh
import SKPhotoBrowser
import Starscream
import SwiftyJSON

class ChatVC: UIViewController {

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    var chatListModel: ChatListModel!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(colorWithHexValue: 0xf7f6f6)
        tableView.separatorStyle = .none
        //tableView.backgroundView = UIImageView(image: ImageAsset.Chat_background.image)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    var chatActionBarView: ChatActionBarView!
    var actionBarPaddingBottomConstraint: Constraint?
    var keyboardHeightConstraint: NSLayoutConstraint?
    let disposeBag = DisposeBag()
    var itemDataSource = [ChatMessageModel]()
    var page = 1
    var isEndData = false
    var loadSentMsg = false
    var getMessageTimer: Timer!
    
    var socket: WebSocket!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // NavBar Set up
        navBar.lblTitle.text = chatListModel.name
        if chatListModel.name.isEmpty {
            if chatListModel.users.count > 0 {
                self.navBar.lblTitle.text = chatListModel.users.first?.name
                if (chatListModel.users.first?.name?.isEmpty)! {
                    self.navBar.lblTitle.text = Utils.getNickNameFromPhoneNumber((chatListModel.users.first?.phoneNumber)!)
                }
            }            
        }
        
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.tableView.ts_registerCellNib(ChatTextCell.self)
        self.tableView.ts_registerCellNib(ChatTimeCell.self)
        self.tableView.ts_registerCellNib(ChatImageCell.self)
        self.tableView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        self.setupSubviews(self)
        self.keyboardControl()
        self.setupActionBarButtonInteraction()
        self.setupRefresh()
        
        self.loadChatMessages(loadFirst: true)
        
        SKPhotoBrowserOptions.displayAction = false
        
        //NotificationCenter.default.addObserver(self, selector: #selector(receivePushMessage(_:)), name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil)
        
        getMessageTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.LoadNewMsg), userInfo: nil, repeats: true)
    }
    
    @objc func LoadNewMsg() {
        self.loadSentMsg = true
        self.loadChatMessages(loadFirst: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDefaultsUtil.shared.setOpenChatMessageId(self.chatListModel.id)
        setupSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaultsUtil.shared.setOpenChatMessageId(-1)
        if self.socket != nil {
            socket.disconnect()
            socket.delegate = nil
        }
        
        getMessageTimer.invalidate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if self.socket != nil {
            socket.disconnect()
            socket.delegate = nil
        }
    }
    
    func loadChatMessages(loadFirst: Bool) {
        print("okay")
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if loadFirst {
            self.page = 1
            self.isEndData = false
            //self.tableView.isHidden = true
            if !loadSentMsg {
                ProgressHUD.showWithStatus()
                self.tableView.isHidden = true
            } else {
                self.tableView.isHidden = false
            }
        }
        if isEndData {
            self.endHeaderRefresh()
            return
        }
        let parameters: [String : Any] = [
            "id" : chatListModel.id
        ]
        SocialAPI.shared.chatMessageGet(page: self.page, params: parameters) { (json, success) in
            let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            backgroundQueue.async(execute: {
                self.endHeaderRefresh()
            })
            if loadFirst {
                self.tableView.isHidden = false
                ProgressHUD.dismiss()
            }
            if success {
                print("Chat Message Get........")
                print(json)
                if loadFirst {
                    self.itemDataSource = []
                }
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                let tempMessages = self.reverseMessages(ChatMessageModel.getChatMessagesFromJson(json["data"]))
                
                var list = [ChatMessageModel]()
                var temp: ChatMessageModel?   
                for  i in 0..<tempMessages.count {
                    if temp == nil || tempMessages[i].isLateForTwoMinutes(temp!) {
                        list.insert(ChatMessageModel.init(updatedAt: tempMessages[i].updatedAt!), at: list.count)
                    }
                    list.insert(tempMessages[i], at: list.count)
                    temp = tempMessages[i]
                }
                if loadFirst {
                    self.itemDataSource.insert(contentsOf: list, at: 0)
                    self.tableView.reloadData()
                    self.tableView.scrollBottomToLastRow()
                } else {
                    DispatchQueue.main.async(execute: {
                        self.itemDataSource.insert(contentsOf: list, at: 0)
                        self.updateTableWithNewRowCount(list.count)
                    })
                }
                
            }
        }
    }
    
    /*@objc func receivePushMessage(_ notification: NSNotification) {
        /*let info: [String: Any] = [
         "status": UserDefaultsUtil.shared.IS_OPEN_CHAT_LIST,
         "message": message
         ]*/
        guard let type = notification.userInfo?["type"] as? String else { return }
        if type != UserDefaultsUtil.shared.OPEN_CHAT_MESSAGE_ID {
            return
        }
        guard let message = notification.userInfo?["message"] as? ChatMessageModel else { return }
        
        guard let status = notification.userInfo?["status"] as? String else { return }
        if status == "receive" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if self.itemDataSource.isEmpty {
                let timeModel = ChatMessageModel.init(updatedAt: dateString)
                self.itemDataSource.append(timeModel)
                let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
                self.tableView.insertRowsAtBottom([insertIndexPath])
            } else {
                let lastMessage = self.itemDataSource.last!
                if message.isLateForTwoMinutes(lastMessage) {
                    let timeModel = ChatMessageModel.init(updatedAt: dateString)
                    self.itemDataSource.append(timeModel)
                    let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
                    self.tableView.insertRowsAtBottom([insertIndexPath])
                }
            }
            self.itemDataSource.append(message)
            let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
            self.tableView.insertRowsAtBottom([insertIndexPath])
        } else { // status == "response"
            
        }
    }*/

    
    
    private func setupRefresh() {
        let refreshHeader = MJRefreshNormalHeader {
            self.headerRefreshing()
        }
        refreshHeader?.lastUpdatedTimeLabel.isHidden = true
        refreshHeader?.setTitle("", for: MJRefreshState.idle)
        refreshHeader?.setTitle("", for: .pulling)
        refreshHeader?.setTitle("", for: .refreshing)
        self.tableView.mj_header = refreshHeader

    }
    
    private func headerRefreshing() {
        self.loadChatMessages(loadFirst: false)
    }
    
    private func endHeaderRefresh() {
        self.tableView.mj_header.endRefreshing()
    }
    
    func updateTableWithNewRowCount(_ count: Int) {
        var contentOffset = self.tableView.contentOffset
        
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        
        var heightForNewRows: CGFloat = 0
        var indexPaths = [IndexPath]()
        for i in 0 ..< count {
            let indexPath = IndexPath(row: i, section: 0)
            indexPaths.append(indexPath)
            
            heightForNewRows += self.tableView(self.tableView, heightForRowAt: indexPath)
        }
        
        contentOffset.y += heightForNewRows
        
        self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
        self.tableView.setContentOffset(contentOffset, animated: false)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath.init(row: count, section: 0), at: .top, animated: false)
        UIView.setAnimationsEnabled(true)
    }
    
    
    func reverseMessages(_ messages: [ChatMessageModel]) -> [ChatMessageModel] {
        var reversedMessages: [ChatMessageModel] = []
        for message in messages.reversed() {
            reversedMessages.append(message)
        }
        return reversedMessages
    }
    
    
    
    //socket chat implementation...
    private func setupSocket() {
        socket = WebSocket(url: URL.init(string: Constants.WEB_SOCKET_CHAT_URL)!)
        socket.delegate = self
        socket.connect()
    }
    
    private func handleSocketData(_ json: JSON) {
        let action = json["action"].stringValue
        let room = json["room"].int64Value
        
        if action == "chat" && room == chatListModel.id {
            let chatMessage = ChatMessageModel.init(json["message"])
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if self.itemDataSource.isEmpty {
                let timeModel = ChatMessageModel.init(updatedAt: dateString)
                self.itemDataSource.append(timeModel)
                let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
                self.tableView.insertRowsAtBottom([insertIndexPath])
            } else {
                let lastMessage = self.itemDataSource.last!
                if chatMessage.isLateForTwoMinutes(lastMessage) {
                    let timeModel = ChatMessageModel.init(updatedAt: dateString)
                    self.itemDataSource.append(timeModel)
                    let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
                    self.tableView.insertRowsAtBottom([insertIndexPath])
                }
            }
            self.itemDataSource.append(chatMessage)
            let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
            self.tableView.insertRowsAtBottom([insertIndexPath])
        }
    }

}


extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chatModel = self.itemDataSource[indexPath.row]
        let type: MessageContentType = chatModel.messageContentType
        return type.chatCellHeight(chatModel)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatModel = self.itemDataSource[indexPath.row]
        let type = chatModel.messageContentType
        return type.chatCell(tableView, index: indexPath, model: chatModel, vc: self)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*let chatModel = self.itemDataSource[indexPath.row]
        let type = chatModel.messageContentType
        if type == MessageContentType.Image {
            let cell = tableView.cellForRow(at: indexPath) as! ChatImageCell
            cell.chatImageView.kf.cancelDownloadTask()            
        }*/
    }
}


extension ChatVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hideAllKeyboard()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*if (scrollView.contentOffset.y < kChatLoadMoreOffset) {
            if self.isEndRefreshing {
                log.info("pull to refresh");
                self.pullToLoadMore()
            }
        }*/
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /*if (scrollView.contentOffset.y - scrollView.contentInset.top < kChatLoadMoreOffset) {
            if self.isEndRefreshing {
                log.info("pull to refresh");
                self.pullToLoadMore()
            }
        }*/
    }
}



extension ChatVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}



extension ChatVC: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect...............")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect...............")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage...............", text)
        let json = JSON.init(parseJSON: text)
        print(json)
        handleSocketData(json)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData...............")
    }
}


















