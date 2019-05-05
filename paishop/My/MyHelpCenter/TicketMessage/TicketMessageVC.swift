

import UIKit
import SnapKit
import RxSwift

class TicketMessageVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    var ticketListModel: TicketListModel!
    
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
    
    var ticketActionBarView: TicketActionBarView!
    var actionBarPaddingBottomConstraint: Constraint?
    var keyboardHeightConstraint: NSLayoutConstraint?
    let disposeBag = DisposeBag()
    
    var itemDataSource: [TicketMessageModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        self.tableView.ts_registerCellNib(TicketTextCell.self)
        self.tableView.ts_registerCellNib(TicketTimeCell.self)
        
        self.setupSubviews(self)
        self.keyboardControl()
        self.setupActionBarButtonInteraction()
        
        self.loadTicketMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivePushTicket(_:)), name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDefaultsUtil.shared.setOpenTicketMessageId(self.ticketListModel.id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaultsUtil.shared.setOpenTicketMessageId(-1)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = ticketListModel.content
        navBar.lblTitle.font = UIFont.boldSystemFont(ofSize: 15)
        
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    func loadTicketMessages() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        let parameters: [String : Any] = [
            "id" : ticketListModel.id
        ]
        MyAPI.shared.ticketMessageGet(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                print("Ticket Message Get...")
                print(json)
                
                let tempMessages = TicketMessageModel.getTicketMessagesFromJson(json["conversations"])
                
                var list = [TicketMessageModel]()
                var temp: TicketMessageModel?
                for i in 0..<tempMessages.count {
                    if temp == nil || tempMessages[i].isLateForFiveMinutes(temp!) {
                        list.insert(TicketMessageModel.init(updatedAt: tempMessages[i].updatedAt!), at: list.count)
                    }
                    list.insert(tempMessages[i], at: list.count)
                    temp = tempMessages[i]
                }
                
                DispatchQueue.main.async {
                    if list.count > 0 {
                        self.itemDataSource.insert(contentsOf: list, at: 0)
                        self.updateTableWithNewRowCount(list.count)
                        self.tableView.scrollBottomToLastRow()
                    }                    
                }
            } else {
                // load again...
                MyAPI.shared.ticketMessageGet(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        let tempMessages = TicketMessageModel.getTicketMessagesFromJson(json["conversations"])
                        var list = [TicketMessageModel]()
                        var temp: TicketMessageModel?
                        for i in 0..<tempMessages.count {
                            if temp == nil || tempMessages[i].isLateForFiveMinutes(temp!) {
                                list.insert(TicketMessageModel.init(updatedAt: tempMessages[i].updatedAt!), at: list.count)
                            }
                            list.insert(tempMessages[i], at: list.count)
                            temp = tempMessages[i]
                        }
                        DispatchQueue.main.async {
                            if list.count > 0 {
                                self.itemDataSource.insert(contentsOf: list, at: 0)
                                self.updateTableWithNewRowCount(list.count)
                                self.tableView.scrollBottomToLastRow()
                            }
                        }
                    } else {
                        ProgressHUD.showErrorWithStatus("无法加载您的消息.")
                    }
                })
            }
        }
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
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.self.tableView.setContentOffset(contentOffset, animated: false)
    }
    
    @objc func receivePushTicket(_ notification: NSNotification) {
        guard let status = notification.userInfo?["status"] as? String else { return }
        guard let ticketMessage = notification.userInfo?["ticketMessage"] as? TicketMessageModel else { return }
        if status == "receive" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if (self.itemDataSource.isEmpty) {
                let timeModel = TicketMessageModel.init(updatedAt: dateString)
                self.itemDataSource.append(timeModel)
                let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
                self.tableView.insertRowsAtBottom([insertIndexPath])
            } else {
                let lastMessage = self.itemDataSource.last!
                if ticketMessage.isLateForFiveMinutes(lastMessage) {
                    let timeModel = TicketMessageModel.init(updatedAt: dateString)
                    self.itemDataSource.append(timeModel)
                    let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
                    self.tableView.insertRowsAtBottom([insertIndexPath])
                }
            }
            self.itemDataSource.append(ticketMessage)
            let insertIndexPath = IndexPath(row: self.itemDataSource.count - 1, section: 0)
            self.tableView.insertRowsAtBottom([insertIndexPath])
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

}


extension TicketMessageVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ticketMessage = itemDataSource[indexPath.row]
        let type: TicketMessageContentType = ticketMessage.messageContentType
        return type.ticketCellHeight(ticketMessage)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ticketMessage = itemDataSource[indexPath.row]
        let type: TicketMessageContentType = ticketMessage.messageContentType
        return type.ticketCell(tableView, index: indexPath, model: ticketMessage, vc: self)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



extension TicketMessageVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TicketMessageVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hideAllKeyboard()
    }
}






