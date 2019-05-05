//
//  LiveVideoPushVC.swift
//  paishop
//
//  Created by SeniorCorder on 4/25/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import AlivcLivePusher
import Starscream
import SwiftyJSON

class LiveVideoPushVC: UIViewController {
    
    var pushUrl: String = ""
    var videoModel: LiveVideoModel!
    var videoImage: UIImage!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashButton: UIButton! {
        didSet {
            flashButton.isEnabled = false
        }
    }
    @IBOutlet weak var cameraButton: UIButton! {
        didSet {
            cameraButton.isEnabled = false
        }
    }
    @IBOutlet weak var pushButton: UIButton! {
        didSet {
            pushButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.isHidden = true
            statusLabel.clipsToBounds = true
            statusLabel.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.ts_registerCellNib(LiveVideoChatCell.self)
            chatTableView.rowHeight = UITableView.automaticDimension
            chatTableView.estimatedRowHeight = 40
            chatTableView.tableFooterView = UIView()
        }
    }
    
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
    
    
    
    var chatMessages: [LiveChatModel] = []
    
    var lastPinchDistance: CGFloat = 0
    var livePusher: AlivcLivePusher!
    var flashState = false
    var previewState = false // true: preview started, false: preview stoped
    var pushState = false // true: push started, false: push stoped
    var isPaused = false
    
    var statusTimer: Timer!
    var socket: WebSocket!
    var joinedCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startPreview()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        self.cameraView.addGestureRecognizer(pinchGesture)
        
        if videoModel.forbidden! {
            self.presentOKAlert("您的直播已被管理员禁止!\n请联系管理员.") {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.destroyLivePusher()
        self.cancelTimer()
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    deinit {
        self.destroyLivePusher()
        self.cancelTimer()
        
        if self.socket != nil {
            socket.disconnect()
            socket.delegate = nil
        }
    }
    
    private func setupSocket() {
        socket = WebSocket(url: URL.init(string: Constants.WEB_SOCKET_LIVE_VIDEO_URL)!)
        socket.delegate = self
        socket.connect()
    }

    
    @IBAction func onBackClicked(_ sender: UIButton) {
        if self.pushState {
            self.stopPush()
        } else {
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onFlashClicked(_ sender: UIButton) {
        self.flashState = !self.flashState
        self.livePusher.setFlash(self.flashState)
    }
    
    @IBAction func onCameraClicked(_ sender: UIButton) {
        self.livePusher.switchCamera()
    }
    
    @IBAction func onPushClicked(_ sender: UIButton) {
        self.pushButton.isEnabled = false
        if !self.pushState {
            self.startPush()
        } else if self.isPaused { // paused
            self.livePusher.resume()
        } else {
            self.livePusher.pause()
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
    
    
    
    @objc func pinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.numberOfTouches != 2 {
            return
        }
        let p1 = gesture.location(ofTouch: 0, in: self.cameraView)
        let p2 = gesture.location(ofTouch: 1, in: self.cameraView)
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let dist = sqrt(dx*dx + dy*dy)
        if gesture.state == UIGestureRecognizer.State.began {
            lastPinchDistance = dist
        }
        
        let change = dist - lastPinchDistance
        print("zoom -------------- ", change)
        
        if self.previewState {
            let max = self.livePusher.getMaxZoom()
            self.livePusher.setZoom(Float(min(change/3000, CGFloat(max))))
        }
    }
    
    private func configLivePusher() -> AlivcLivePushConfig {
        // Basic configuration
        let config = AlivcLivePushConfig(resolution: AlivcLivePushResolution.resolution540P)! //初始化推流配置类，也可使用initWithResolution来初始化
        config.resolution = .resolution540P //默认为540P，最大支持720P
        config.fps = AlivcLivePushFPS.FPS20 //建议用户使用20fps
        config.videoEncodeGop = AlivcLivePushVideoEncodeGOP._2 //默认值为2，关键帧间隔越大，延时越高。建议设置为1-2
        config.connectRetryInterval = 2000 // 单位为毫秒，重连时长2s，重连间隔设置不小于1秒，建议使用默认值即可。
        config.previewMirror = false // 默认为false，正常情况下都选择false即可。
        config.orientation = AlivcLivePushOrientation.portrait // 默认为竖屏，可设置home键向左或向右横屏。
        
        // Code control configuration
        config.qualityMode = AlivcLivePushQualityMode.fluencyFirst // 默认为清晰度优先模式，可设置为流畅度优先模式和自定义模式。
        /*
         config.qualityMode = AlivcLivePushQualityMode.custom //设置为自定义模式
         config.targetVideoBitrate = 1200 //  目标码率1200Kbps
         config.minVideoBitrate = 400 //  最小码率400Kbps
         config.initialVideoBitrate = 900 //  初始码率900Kbps
         */
        
        // Resolution adaptive configuration
        
        // Beauty Configuration
        config.beautyOn = true
        config.beautyMode = AlivcLivePushBeautyMode.normal
        config.beautyWhite = 70
        config.beautyBuffing = 40
        config.beautyRuddy = 40
        /*
         config.beautyOn = true
         config.beautyMode = AlivcLivePushBeautyMode.professional
         config.beautyWhite = 70; // 美白范围0-100
         config.beautyBuffing = 40; // 磨皮范围0-100
         config.beautyRuddy = 40;// 红润设置范围0-100
         config.beautyBigEye = 30;// 大眼设置范围0-100
         config.beautyThinFace = 40;// 瘦脸设置范围0-100
         config.beautyShortenFace = 50;// 收下巴设置范围0-100
         config.beautyCheekPink = 15;// 腮红设置范围0-100
         */
        
        // Picture push configuration
//        config.networkPoorImg = UIImage(named: "icon_store")! //videoImage
//        config.pauseImg = UIImage(named: "icon_store")! // videoImage
        
        // Watermark configuration
        let watermarkBundlePath = Bundle.main.path(forResource: "watermark", ofType: "png")
        config.addWatermark(withPath: watermarkBundlePath, watermarkCoordX: 0.1, watermarkCoordY: 0.1, watermarkWidth: 0.3)
        
        return config
    }
    
    private func startPreview() {
        let config = self.configLivePusher()
        self.livePusher = AlivcLivePusher(config: config)
        self.livePusher.setInfoDelegate(self)
        self.livePusher.setErrorDelegate(self)
        self.livePusher.setNetworkDelegate(self)
        
        self.livePusher.startPreview(self.cameraView)
    }
    
    private func stopPreview() {
        self.livePusher.stopPreview()
    }
    
    private func destroyLivePusher() {
        if self.livePusher != nil {
            livePusher.destory()
            livePusher = nil
        }
    }
    
    
    
    private func startPush() {
        //self.livePusher.startPush(withURL: "rtmp://push-videocall.aliyuncs.com/test/stream41")
        self.livePusher.startPush(withURL: self.pushUrl)
    }
    
    private func stopPush() {
        // api call for stop
        self.livePusher.stopPush()
    }
    
    
    private func setupStatusTimer() {
        self.statusTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(statusTimerAction(_:)), userInfo: nil, repeats: true)
    }
    
    private func cancelTimer() {
        if self.statusTimer != nil {
            self.statusTimer.invalidate()
            self.statusTimer = nil
        }
    }
    
    @objc func statusTimerAction(_ timer: Timer) {
        let isPushing = self.livePusher.isPushing()
        if isPushing {
            if self.isPaused {
                self.statusLabel.text = "暂停"
            } else {
                self.statusLabel.text = "直播中"
            }
        } else {
            self.statusLabel.text = "没有直播"
        }
        self.statusLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.statusLabel.isHidden = true
        }
    }
    
        
    
    private func updateAuthURL() {
        let authPushURL = self.getAuthPushURL()
        self.pushUrl = authPushURL
    }
    
    func getAuthPushURL() -> String {
        var tempString = ""
        let authKey = "zsYTDmYHjE"
        let authDuration = 1800
        let basePushUrl = self.pushUrl.components(separatedBy: "&").first!
        tempString = self.pushUrl.components(separatedBy: "?").first!
        let uri = tempString.components(separatedBy: "video-center-bj.alivecdn.com").last!
        
        let currentTime = Int(Date().timeIntervalSince1970)
        let timestamp = currentTime + authDuration
        
        let hash = self.MD5ForLower32Bate(uri + "-\(timestamp)-\(UserInstance.userId!)-0-" + authKey)
        let newPushURL = basePushUrl + "&auth_key=\(timestamp)-\(UserInstance.userId!)-0-" + hash
        print("New Push Url..........", newPushURL)
        return newPushURL
    }
    
    func MD5ForLower32Bate(_ str: String) -> String {
        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(str.toPointer(), CC_LONG(str.count), uint8Pointer)
        let digest = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<CC_MD5_DIGEST_LENGTH {
            digest.appendFormat("%02x", uint8Pointer[Int(i)])
        }
        return digest as String
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
            case "forbid":
                self.presentOKAlert("您的直播已被管理员禁止!\n请联系管理员.") {
                    self.dismiss(animated: true, completion: nil)
                }
                break
            default:
                break
            }
        }
        
    }
    
}


extension LiveVideoPushVC: AlivcLivePusherInfoDelegate {
    func onPreviewStarted(_ pusher: AlivcLivePusher!) {
        print("onPreviewStarted...........")
        DispatchQueue.main.async {
            self.previewState = true
            self.pushState = false
            self.pushButton.setTitle("开始", for: .normal)
            
            self.pushButton.isEnabled = true
            self.cameraButton.isEnabled = true
            self.flashButton.isEnabled = true
            
        }
        
        self.livePusher.setCaptureVolume(100)
    }
    
    func onPreviewStoped(_ pusher: AlivcLivePusher!) {
        print("onPreviewStoped............")
    }
    
    func onPushStarted(_ pusher: AlivcLivePusher!) {
        print("onPushStarted.............")
        let parameters: [String: Any] = [
            "video" : self.videoModel.id!
        ]
        SocialAPI.shared.pushStart(params: parameters) { (json, success) in
            if success {
                
            } else {
                // try again...
                SocialAPI.shared.pushStart(params: parameters, completion: { (json1, success1) in
                    if success1 {
                        
                    } else {
                        
                    }
                })
            }
        }
        
        DispatchQueue.main.async {
            self.pushButton.isEnabled = true
            self.previewState = true
            self.pushState = true
            self.pushButton.setTitle("暂停", for: .normal)
            self.isPaused = false
            
            self.statusLabel.isHidden = false
            self.statusLabel.text = "直播中"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.statusLabel.isHidden = true
            })
            self.setupStatusTimer()
        }
        
        self.setupSocket()
    }
    
    func onPushStoped(_ pusher: AlivcLivePusher!) {
        print("onPushStoped...............")
        
        DispatchQueue.main.async {
            self.pushButton.isEnabled = true
            self.previewState = true
            self.pushState = false
            self.pushButton.setTitle("开始", for: .normal)
            
            //self.navigationController?.popViewController(animated: true)
        }
        
        let parameters: [String: Any] = [
            "video" : self.videoModel.id!
        ]
        SocialAPI.shared.pushStop(params: parameters) { (json, success) in
            if success {
                //self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            } else {
                //try again..
                SocialAPI.shared.pushStop(params: parameters, completion: { (json1, success1) in
                    //self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        
    }
    
    func onPushPauesed(_ pusher: AlivcLivePusher!) {
        DispatchQueue.main.async {
            self.pushButton.isEnabled = true
            self.previewState = true
            self.pushState = true
            self.pushButton.setTitle("恢复", for: .normal)
            self.isPaused = true
            
            self.statusLabel.isHidden = false
            self.statusLabel.text = "暂停"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.statusLabel.isHidden = true
            })
        }
    }
    
    func onPushResumed(_ pusher: AlivcLivePusher!) {
        DispatchQueue.main.async {
            self.pushButton.isEnabled = true
            self.previewState = true
            self.pushState = true
            self.pushButton.setTitle("暂停", for: .normal)
            self.isPaused = false
            
            self.statusLabel.isHidden = false
            self.statusLabel.text = "直播中"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.statusLabel.isHidden = true
            })
        }
    }
    
    func onPushRestart(_ pusher: AlivcLivePusher!) {
        
    }
    
}

extension LiveVideoPushVC: AlivcLivePusherErrorDelegate {
    func onSystemError(_ pusher: AlivcLivePusher!, error: AlivcLivePushError!) {
        self.presentOKAlert("系统错误") {
            self.destroyLivePusher()
            self.cancelTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                //self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func onSDKError(_ pusher: AlivcLivePusher!, error: AlivcLivePushError!) {
        self.presentOKAlert("SDK错误") {
            self.destroyLivePusher()
            self.cancelTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                //self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
}


extension LiveVideoPushVC: AlivcLivePusherNetworkDelegate {
    func onPushURLAuthenticationOverdue(_ pusher: AlivcLivePusher!) -> String! {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "更新url"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
        
        print("onPushURLAuthenticationOverdue..............")
        self.updateAuthURL()
        return self.pushUrl
        
    }
    
    func onSendSeiMessage(_ pusher: AlivcLivePusher!) {
        
    }
    
    func onNetworkPoor(_ pusher: AlivcLivePusher!) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "onNetworkPoor"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
    }
    
    func onConnectFail(_ pusher: AlivcLivePusher!, error: AlivcLivePushError!) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "onConnectFail"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
    }
    
    func onConnectRecovery(_ pusher: AlivcLivePusher!) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "onConnectRecovery"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
    }
    
    func onReconnectStart(_ pusher: AlivcLivePusher!) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "onConnectRecovery"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
    }
    
    func onReconnectSuccess(_ pusher: AlivcLivePusher!) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "onConnectRecovery"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
    }
    
    func onReconnectError(_ pusher: AlivcLivePusher!, error: AlivcLivePushError!) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = "onConnectRecovery"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.statusLabel.isHidden = true
        })
    }
    
    func onSendDataTimeout(_ pusher: AlivcLivePusher!) {
        
    }
    
}


extension LiveVideoPushVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LiveVideoChatCell = tableView.ts_dequeueReusableCell(LiveVideoChatCell.self)
        cell.setCellContent(chatMessages[indexPath.row])
        return cell
    }
    
}


extension LiveVideoPushVC: WebSocketDelegate {
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














