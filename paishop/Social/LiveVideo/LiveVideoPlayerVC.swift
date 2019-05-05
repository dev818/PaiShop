
import UIKit
import AliyunVodPlayerSDK
import MJRefresh
import Starscream
import SwiftyJSON

class LiveVideoPlayerVC: UIViewController {
    
    var liveVideoUrl: String = ""
    var videoModel: LiveVideoModel!
    
    @IBOutlet weak var videoViewFrame: UIView!
    @IBOutlet weak var playerContentView: UIView!
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.ts_registerCellNib(LiveVideoChatCell.self)
            chatTableView.rowHeight = UITableView.automaticDimension
            chatTableView.estimatedRowHeight = 40
            chatTableView.tableFooterView = UIView()
        }
    }
    @IBOutlet var productTableView: UITableView! {
        didSet {
            productTableView.ts_registerCellNib(LiveVideoProductHeaderCell.self)
            productTableView.ts_registerCellNib(LiveVideoProductCell.self)
            productTableView.rowHeight = UITableView.automaticDimension
            productTableView.estimatedRowHeight = 300
            productTableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var businessImageView: RoundImageView!
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessLocationLabel: UILabel!
    
    
    @IBOutlet weak var favorView: RoundRectView!
    @IBOutlet weak var favorFrame: UIStackView!
    @IBOutlet weak var favorButton: UIButton!
        
    @IBOutlet weak var placeholderImageView: UIImageView!
    
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var likeButton: JQEmitterButton!
    
    @IBOutlet weak var viewsLabel: UILabel! {
        didSet {
            viewsLabel.isHidden = true
        }
    }
    @IBOutlet weak var userImageView1: UIImageView! {
        didSet {
            userImageView1.isHidden = true
        }
    }
    @IBOutlet weak var userImageView2: UIImageView! {
        didSet {
            userImageView2.isHidden = true
        }
    }
    @IBOutlet weak var userImageView3: UIImageView! {
        didSet {
            userImageView3.isHidden = true
        }
    }
    
    
    lazy private var aliyunVodPlayer: AliyunVodPlayer = {
        let tempPlayer = AliyunVodPlayer()
        tempPlayer.delegate = self
        tempPlayer.isAutoPlay = true
        tempPlayer.displayMode = AliyunVodPlayerDisplayMode.fit
        return tempPlayer
    }()
    var aliyunPlayerView: UIView!
    var isCustomViewAppear = false
    
    var storeItems: [ProductListModel] = []
    var page = 1
    var isEndData = false
    
    var chatMessages: [LiveChatModel] = []
    var joinedCount = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var socket: WebSocket!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardWillShowNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardWillHideNotification.rawValue), object: nil)
        
        setupRefresh()
        self.loadStoreItems(resetData: true)
        self.updateFavor()
        self.showBusinessFields()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupCustomView()
        
        self.setPlayerContentView()
        self.setCacheForPlaying()
        
        self.aliyunVodPlayer.prepare(with: URL.init(string: self.liveVideoUrl) )
        //self.aliyunVodPlayer.prepare(with: URL.init(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks") )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.placeholderImageView.isHidden = true
        }
        
        chatTableView.scrollBottomToLastRow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
        let parameters: [String: Any] = ["video" : videoModel.id!]
        SocialAPI.shared.liveChatGet(params: parameters) { (json, success) in
            if success {
                self.chatMessages = LiveChatModel.getLiveChatsFromJson(json["chats"])
                DispatchQueue.main.async {
                    self.chatTableView.reloadData {
                        self.chatTableView.scrollBottomToLastRow()
                        self.setupSocket()
                    }
                }
            } else {
                self.setupSocket()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.aliyunVodPlayer.stop()
        UIApplication.shared.isIdleTimerDisabled = false
        
        if self.socket != nil {
            socket.disconnect()
            socket.delegate = nil
        }
    }
    
    deinit {
        self.aliyunVodPlayer.stop()
        self.aliyunVodPlayer.release()
        NotificationCenter.default.removeObserver(self)
        
        if self.socket != nil {
            socket.disconnect()
            socket.delegate = nil
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //self.aliyunVodPlayer.playerView.frame  = self.playerContentView.frame
        //self.aliyunVodPlayer.prepare(with: URL.init(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks") )
        //self.aliyunVodPlayer.prepare(with: URL.init(string: self.liveVideoUrl) )
        
    }
    
    private func setupSocket() {
        socket = WebSocket(url: URL.init(string: Constants.WEB_SOCKET_LIVE_VIDEO_URL)!)
        socket.delegate = self
        socket.connect()
    }
    
    private func setupUI() {
        placeholderImageView.setImageWithURLString(videoModel.image, placeholderImage: ImageAsset.social_blur.image)
        videoTitleLabel.text = videoModel.title
        let resizedUrl = Utils.getResizedImageUrlString((videoModel.store?.image)!, width: "200")
        businessImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        businessNameLabel.text = videoModel.store?.name
        businessLocationLabel.text = videoModel.store?.city?.name
        if videoModel.views! < 1 {
            viewsLabel.isHidden = true
        } else {
            viewsLabel.isHidden = false
            viewsLabel.text = "\(videoModel.views!)人"
        }
        
        let playerContentTap = UITapGestureRecognizer(target: self, action: #selector(tapPlayerContentView))
        playerContentView.isUserInteractionEnabled = true
        playerContentView.addGestureRecognizer(playerContentTap)
    }

    @IBAction func onBackClicked(_ sender: UIButton) {
        if self.isCustomViewAppear {
            self.hideCustomView()
            isCustomViewAppear = false
        } else {
            inputTextField.resignFirstResponder()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onGiftClicked(_ sender: UIButton) {
    }
    
    @IBAction func onChatClicked(_ sender: UIButton) {
        inputTextField.becomeFirstResponder()
    }
    
    
    
    @IBAction func onBagClicked(_ sender: UIButton) {
        self.isCustomViewAppear = true
        self.showCustomView()
    }
    
    @IBAction func onLikeClicked(_ sender: UIButton) {
        let parameters: [String: Any] = [
            "video" : videoModel.id!
        ]
        SocialAPI.shared.liveLike(params: parameters) { (json, success) in
            if success {
                print("Live Video Like...................")
                print(json)
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        if let chatText = inputTextField.text, chatText.count > 0 {
            //send chat text...
            //self.chatMessages.append(chatText)
            /*self.chatTableView.reloadData {
                self.chatTableView.scrollBottomToLastRow()
            }*/
            
            let parameters: [String : Any] = [
                "video" : videoModel.id!,
                "message" : chatText
            ]
            SocialAPI.shared.liveChatSend(params: parameters) { (json, success) in
                if success {
                    print(json)
                }
            }
        }
        inputTextField.resignFirstResponder()
    }
    
    @IBAction func onFavorClicked(_ sender: UIButton) {
        Utils.applyTouchEffect(favorFrame)
        Utils.applyTouchEffect(favorView)
        
        if Int64(UserInstance.storeId!) == self.videoModel.storeId! {
            ProgressHUD.showSuccessWithStatus("这是你的商店!")
            return
        }
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : self.videoModel.storeId!
        ]
        
        sender.isEnabled = false
        ProgressHUD.showWithStatus()
        HomeAPI.shared.storeFavoriteAdd(params: parameters) { (json, success) in
            sender.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                print("Store Favorite Add...")
                print(json)
                self.videoModel.store?.favorites = 1
                self.updateFavor()
                self.productTableView.reloadData()
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
    
    
    @objc func tapPlayerContentView() {
        isCustomViewAppear = false
        self.hideCustomView()
        
        inputTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardControl(notification, isShowing: true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardControl(notification, isShowing: false)
    }
    
    func keyboardControl(_ notification: Notification, isShowing: Bool) {
        var userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
        
        //let convertedFrame = self.view.convert(keyboardRect!, from: nil)
        let options = UIView.AnimationOptions(rawValue: UInt(curve!) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        inputBar.snp.updateConstraints { (make) in
            if isShowing {
                print("KeyboardRect....", keyboardRect!.size.height)
                make.bottom.equalTo(self.view.bottom).offset(-(keyboardRect?.size.height)!)
            } else {
                make.bottom.equalTo(self.view.bottom).offset(40)
            }
        }
        UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
            self.view.layoutSubviews()
        }) { (success) in
            
        }
        
    }
    
    
    private func setPlayerContentView() {
        aliyunPlayerView = aliyunVodPlayer.playerView
        playerContentView.addSubview(aliyunPlayerView)
        aliyunPlayerView?.translatesAutoresizingMaskIntoConstraints = false
        aliyunPlayerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(playerContentView.top)
            make.centerX.equalTo(playerContentView.centerX)
            make.width.equalTo(Constants.SCREEN_WIDTH)
            make.height.equalTo(Constants.SCREEN_HEIGHT)
        })
        self.view.layoutSubviews()
    }
    
    private func setCacheForPlaying(){
        //缓存设置
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        aliyunVodPlayer.setPlayingCache(false, saveDir: path, maxSize: 30, maxDuration: 10000)
    }
    
    private func setupCustomView() {
        self.view.addSubview(productTableView)
        productTableView.translatesAutoresizingMaskIntoConstraints = false
        productTableView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.height.equalTo(Constants.SCREEN_HEIGHT*2/3)
            make.bottom.equalTo(self.view).offset(Constants.SCREEN_HEIGHT*2/3)
        }
        
        self.view.addSubview(inputBar)
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(40)
            make.bottom.equalTo(self.view).offset(40)
        }
        inputTextField.delegate = self
    }
    
    private func showCustomView() {
        self.hideFavor()
        self.hideBusinessFields()
        self.aliyunPlayerView.snp.updateConstraints { (make) in
            make.height.equalTo(Constants.SCREEN_HEIGHT/3)
            make.centerX.equalTo(playerContentView.centerX)
        }
        
        productTableView.scrollToTopAnimated(false)
        self.productTableView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutSubviews()
        }
    }
    
    private func hideCustomView() {
        self.updateFavor()
        self.showBusinessFields()
        self.aliyunPlayerView.snp.updateConstraints { (make) in
            make.height.equalTo(Constants.SCREEN_HEIGHT)
            make.width.equalTo(Constants.SCREEN_WIDTH)
            make.centerX.equalTo(playerContentView.centerX)
        }
        self.productTableView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(Constants.SCREEN_HEIGHT*2/3)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutSubviews()
        }
    }
    
    
    private func setupRefresh() {
        let refreshFooter = MJRefreshAutoNormalFooter {
            self.footerRefreshing()
        }
        refreshFooter?.setTitle("点击或拉起来加载更多", for: .idle)
        refreshFooter?.setTitle("装载...", for: .refreshing)
        self.productTableView.mj_footer = refreshFooter
    }
    
    private func footerRefreshing() {
        self.loadStoreItems(resetData: false)
    }
    
    private func endFooterRefresh() {
        self.productTableView.mj_footer.endRefreshing()
    }
    
    private func loadStoreItems(resetData: Bool) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        if resetData {
            self.page = 1
            self.isEndData = false
        }
        if isEndData {
            self.endFooterRefresh()
            return
        }
        HomeAPI.shared.itemStore(page: self.page, storeId: (videoModel.store?.storeId)!) { (json, success) in
            self.endFooterRefresh()
            if success {
                //print("Item Store......")
                //print(json)
                if resetData {
                    self.storeItems = []
                }
                let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                self.storeItems.append(contentsOf: tempItems)
                let lastPage = json["last_page"].intValue
                if self.page == lastPage {
                    self.isEndData = true
                } else {
                    self.page += 1
                }
                if resetData {
                    ProgressHUD.dismiss()
                } else {
                    self.productTableView.ts_reloadData {  }
                }
            } else {
                // try again...
                HomeAPI.shared.itemStore(page: self.page, storeId: (self.videoModel.store?.storeId)!, completion: { (json, success1) in
                    if success1 {
                        if resetData {
                            self.storeItems = []
                        }
                        let tempItems = ProductListModel.getProductListsFromJson(json["data"])
                        self.storeItems.append(contentsOf: tempItems)
                        let lastPage = json["last_page"].intValue
                        if self.page == lastPage {
                            self.isEndData = true
                        } else {
                            self.page += 1
                        }
                        if resetData {
                            ProgressHUD.dismiss()
                        } else {
                            self.productTableView.ts_reloadData {  }
                        }
                    } else {
                        if resetData {
                            ProgressHUD.dismiss()
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
                })
            }
        }
    }
    
    
    private func showFavor() {
        favorView.isHidden = false
        favorFrame.isHidden = false
        favorButton.isHidden = false
    }
    
    private func hideFavor() {
        favorView.isHidden = true
        favorFrame.isHidden = true
        favorButton.isHidden = true
    }
    
    private func showBusinessFields() {
        videoTitleLabel.isHidden = false
        businessImageView.isHidden = false
        businessNameLabel.isHidden = false
        businessLocationLabel.isHidden = false
    }
    
    private func hideBusinessFields() {
        videoTitleLabel.isHidden = true
        businessImageView.isHidden = true
        businessNameLabel.isHidden = true
        businessLocationLabel.isHidden = true
    }
    
    private func updateFavor() {
        if (videoModel.store?.favorites)! > 0 {
            self.hideFavor()
        } else {
            self.showFavor()
        }
    }
    
    private func handleSocketData(_ json: JSON) {
        let videoId = json["video"].stringValue//int64Value
        let action = json["action"].stringValue
        
        if videoId == videoModel.id! {
            switch action {
            case "message":
                let chatJson = json["chat"]
                let chatMessage = LiveChatModel.init(chatJson)
                self.chatMessages.append(chatMessage)
                DispatchQueue.main.async {
                    self.chatTableView.reloadData {
                        self.chatTableView.scrollBottomToLastRow()
                    }
                }
            case "like":
                likeButton.emit(count: 1)
            case "join":
                //process join...
                joinedCount += 1
                userImageView1.isHidden = false
                if joinedCount == 2 {
                    userImageView2.isHidden = false
                } else if joinedCount > 2 {
                    userImageView3.isHidden = false
                }
                
                let chatMessage = LiveChatModel.init(json)
                self.chatMessages.append(chatMessage)
                let views = json["views"].intValue
                DispatchQueue.main.async {
                    self.chatTableView.reloadData {
                        self.chatTableView.scrollBottomToLastRow()
                    }
                    if views > 0 {
                        self.viewsLabel.isHidden = false
                        self.viewsLabel.text = "\(views)人"
                    }
                    
                    self.userImageView3.image = self.userImageView2.image
                    self.userImageView2.image = self.userImageView1.image
                    let resizedUrl = Utils.getResizedImageUrlString((chatMessage.user?.image)!, width: "200")
                    self.userImageView1.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
                }
                break
            default:
                break
            }
        }
        
    }

}


extension LiveVideoPlayerVC: AliyunVodPlayerDelegate {
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, onEventCallback event: AliyunVodPlayerEvent) {
        switch event {
        case AliyunVodPlayerEvent.prepareDone:
            self.aliyunVodPlayer.start()
        case AliyunVodPlayerEvent.play:
            //暂停后恢复播放时触发
            print("AliyunVodPlayerEvent.play")
            break;
        case AliyunVodPlayerEvent.firstFrame:
            //播放视频首帧显示出来时触发
            print("AliyunVodPlayerEvent.firstFrame")
            break;
        case AliyunVodPlayerEvent.pause:
            print("AliyunVodPlayerEvent.pause")
            //视频暂停时触发
            break;
        case AliyunVodPlayerEvent.stop:
            print("AliyunVodPlayerEvent.stop")
            //主动使用stop接口时触发
            break;
        case AliyunVodPlayerEvent.finish:
            //视频正常播放完成时触发
            print("AliyunVodPlayerEvent.finish")
            self.presentOKAlert("直播结束") {
                self.navigationController?.popViewController(animated: true)
            }
            break;
        case AliyunVodPlayerEvent.beginLoading:
            print("AliyunVodPlayerEvent.beginLoading")
            //视频开始载入时触发
            break;
        case AliyunVodPlayerEvent.endLoading:
            print("AliyunVodPlayerEvent.endLoading")
            //视频加载完成时触发
            break;
        case AliyunVodPlayerEvent.seekDone:
            print("AliyunVodPlayerEvent.seekDone")
            //视频Seek完成时触发
            break;
        }
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, playBack errorModel: ALPlayerVideoErrorModel!) {
        print(errorModel.errorMsg)
        self.presentOKAlert(errorModel.errorMsg) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, willSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, didSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    
    func vodPlayer(_ vodPlayer: AliyunVodPlayer!, failSwitchTo quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    
    func onTimeExpiredError(with vodPlayer: AliyunVodPlayer!) {
        
    }
    
    func vodPlayerPlaybackAddressExpired(withVideoId videoId: String!, quality: AliyunVodPlayerVideoQuality, videoDefinition: String!) {
        
    }
    
}


extension LiveVideoPlayerVC: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == productTableView {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productTableView {
            if section == 0 {
                return 1
            }
            return self.storeItems.count
        }
        
        return chatMessages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == productTableView {
            if indexPath.section == 0 {
                let cell: LiveVideoProductHeaderCell = tableView.ts_dequeueReusableCell(LiveVideoProductHeaderCell.self)
                cell.setPlayerCellContent(videoModel.store!, playerVC: self)
                return cell
            }
            let cell: LiveVideoProductCell = tableView.ts_dequeueReusableCell(LiveVideoProductCell.self)
            cell.setContent(storeItems[indexPath.row])
            return cell
        }
        
        let cell: LiveVideoChatCell = tableView.ts_dequeueReusableCell(LiveVideoChatCell.self)
        cell.setCellContent(chatMessages[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == productTableView {
            if indexPath.section == 0 {
                return
            }
            
            isCustomViewAppear = false
            self.hideCustomView()
            
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = self.storeItems[indexPath.row].id!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}


extension LiveVideoPlayerVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
}



extension LiveVideoPlayerVC: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect..............")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect..............")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage..............", text)
        let json = JSON.init(parseJSON: text)
        print(json)
        self.handleSocketData(json)
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData..............")
    }
    
}
















