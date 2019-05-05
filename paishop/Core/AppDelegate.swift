

import UIKit
import CoreData
import SwiftyJSON
import SDWebImage
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate {

    var window: UIWindow?
    
    let uMessageAppKey = "5a461ca28f4a9d10180001a6"
    let baiduMapApiKey = "2RGqoPjEG4wchlkS2rXu5UEMmtkU9zSA"
    var _mapManager: BMKMapManager?
    
    var degreeNameArray: [String] = []
    var degreeImageArray: [String] = []
    var degreeProfitRatioArray: [Int] = []
    var periodRatio: Double!
    var serverPaiAddress: String!
    var currencyRate: Double!
    var pointExchange: [String] = []
    var iosUrl: String!
    var restitutionRate: Double!
    var serverPaiPhone: String!
    var iosVersion: String!
    
    var categories: [CategoryModel] = []


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ApplicationManager.appConfigInit(self)
        
        _mapManager = BMKMapManager()
        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORDTYPE_BD09LL) {
            NSLog("经纬度类型设置成功");
        } else {
            NSLog("经纬度类型设置失败");
        }
        // 如果要关注网络及授权验证事件，请设定generalDelegate参数
        let ret = _mapManager?.start("Please enter your key", generalDelegate: self)
        if ret == false {
            NSLog("manager start failed!")
        }
        
        //self.setupXGPush()        
        self.setupUMessage(launchOptions)
        
        if UserInstance.isLogin {
            HomeAPI.shared.tokenCheck { (json, success) in
                if success {
                    print("Token Check...")
                    print(json)
                } else {
                    // try again...
                    HomeAPI.shared.tokenCheck(completion: { (json, success1) in
                        if success1 {
                            print("Token Check...")
                            print(json)
                        } else {
                            UserInstance.userLogout()
                        }
                    })
                }
            }
        } else {
            UserInstance.userLogout()
        }
        
        
        MyAPI.shared.systemInfo { (json, success) in
            if success {
                print("System Info...")
                print(json)
                self.getSystemInfoFromJson(json)
                self.checkAppVersion()
            } else {
                //try again...
                MyAPI.shared.systemInfo(completion: { (json, success1) in
                    if success1 {
                        self.getSystemInfoFromJson(json)
                        self.checkAppVersion()
                    } else {
                        
                    }
                })
            }
        }
        
        // Handle the situation where the app is launched in response to a deep link.
        /*if let url = launchOptions?[.url] as? URL {
            return executeDeepLink(url)
        } else {
            return true
        }*/
        
        // SDWebImage
        SDImageCache.shared().config.maxCacheAge = 3600 * 24 * 7 //1 Week
        SDImageCache.shared().maxMemoryCost = 1024 * 1024 * 20 //Aprox 20 images
        //SDImageCache.shared().config.shouldCacheImagesInMemory = false //Default True => Store images in RAM cache for Fast performance
        SDImageCache.shared().config.shouldDecompressImages = false
        SDWebImageDownloader.shared().shouldDecompressImages = false        
        SDImageCache.shared().config.diskCacheReadingOptions = NSData.ReadingOptions.mappedIfSafe
        
        return true
        
    }
    
    func getSystemInfoFromJson(_ json: JSON) {
        let degrees = DegreeModel.getDegreesFromJson(json["degrees"])
        
        for i in 0..<degrees.count {
            self.degreeNameArray.append(degrees[i].name!)
            self.degreeImageArray.append(degrees[i].image!)
            self.degreeProfitRatioArray.append(degrees[i].profitRatio!)
        }
        UserDefaultsUtil.shared.setDegreeNameArray(self.degreeNameArray)
        UserDefaultsUtil.shared.setDegreeImageArray(self.degreeImageArray)
        UserDefaultsUtil.shared.setDegreeProfitRatioArray(self.degreeProfitRatioArray)
        
        let infoJson = json["info"]
        
        self.periodRatio = infoJson["period_ratio"].doubleValue
        UserDefaultsUtil.shared.setPeriodRatio(self.periodRatio)
        
        self.serverPaiAddress = infoJson["pai_address"].stringValue
        UserDefaultsUtil.shared.setServerPaiAddress(self.serverPaiAddress)
        
        self.currencyRate = infoJson["currency_rate"].doubleValue
        UserDefaultsUtil.shared.setCurrencyRate(self.currencyRate)
        
        let pointStrings = infoJson["point_exchange"].stringValue
        let pointStringArray = pointStrings.split(separator: ",")
        for pointString in pointStringArray {
            self.pointExchange.append(pointString.trimmingCharacters(in: .whitespaces))
        }
        UserDefaultsUtil.shared.setPointExchange(self.pointExchange)
        
        self.iosUrl = infoJson["ios_url"].stringValue
        UserDefaultsUtil.shared.setIosUrl(self.iosUrl)
        
        self.restitutionRate = infoJson["restitution_rate"].doubleValue
        UserDefaultsUtil.shared.setRestitutionRate(self.restitutionRate)
        
        self.serverPaiPhone = infoJson["pai_phone"].stringValue
        UserDefaultsUtil.shared.setServerPaiPhone(self.serverPaiPhone)
        
        self.iosVersion = infoJson["ios_version"].stringValue
        UserDefaultsUtil.shared.setIosVersion(self.iosVersion)
    }
    
    func checkAppVersion() {
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        if Double(self.iosVersion)! > Double(currentVersion)! {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                let info : [String : Any] = [
                    "versionUrl" : self.iosUrl
                ]
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.VERSION_UPDATE), object: nil, userInfo: info)
            })
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.host == "safepay") {
            
            // 支付跳转支付宝钱包进行支付，处理支付结果
            
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic:[AnyHashable : Any]?) in
            
                if let Alipayjson = resultDic as NSDictionary?{
                    
                    let resultStatus = Alipayjson.value(forKey: "resultStatus") as! String
                    if resultStatus == "9000"{
                        
                        print("OK")
                        let jsonString = Alipayjson.value(forKey: "result") as! String
                        let json = JSON(jsonString.data(using: .utf8) as Any)
                        print(json)
                        let alipay_trade_app_pay_response = json["alipay_trade_app_pay_response"]                       
                        TRADE_NO = alipay_trade_app_pay_response["trade_no"].stringValue
                        OUT_TRADE_NO = alipay_trade_app_pay_response["out_trade_no"].stringValue
                        
                        // not sure it's correct
                        TRADE_NUMBER = alipay_trade_app_pay_response["tradeNumber_id"].stringValue
                        SELLER_ID = alipay_trade_app_pay_response["seller_id"].stringValue
                        
                        print(TRADE_NO)
                        print(OUT_TRADE_NO)
                        
                        //ProgressHUD.showSuccessWithStatus("支付成功")
                        if levelPayment {
                            NotificationCenter.default.post(name: NSNotification.Name(Notifications.LEVEL_ALIPAY_SUCCESS), object: nil)
                        } else {
                            AlipayPaid = true
                            NotificationCenter.default.post(name: NSNotification.Name(Notifications.ALIPAY_SUCCESS), object: nil)
                        }
                        
                    } else if resultStatus == "8000" {
                        print("正在处理中")
                        ProgressHUD.showErrorWithStatus("正在处理中...")
                        
                    } else if resultStatus == "4000" {
                        //                        NotificationCenter.default.post(name:  NSNotification.Name.init("payFeild"), object: nil, userInfo: ["warning":"订单支付失败"])
                        print("订单支付失败")
                        ProgressHUD.showErrorWithStatus("订单支付失败")
                        
                    } else if resultStatus == "6001" {
                        //                        NotificationCenter.default.post(name:  NSNotification.Name.init("payFeild"), object: nil, userInfo: ["warning":"已取消支付"])
                        print("用户中途取消")
                        ProgressHUD.showErrorWithStatus("用户中途取消")
                        
                    } else if resultStatus == "6002" {
                        //                        NotificationCenter.default.post(name:  NSNotification.Name.init("payFeild"), object: nil, userInfo: ["warning":"网络连接出错"])
                        print("网络连接出错")
                        ProgressHUD.showErrorWithStatus("网络连接出错")
                    }
                }
            })
            
            return true
            
        } else {
            return url.scheme == "paishop" && executeDeepLink(url)
        }
    }
    
    private func executeDeepLink(_ url: URL) -> Bool {
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [
            SelectStoreDeepLink.self,
            SelectProductDeepLink.self
            ])
        print("DeepLink....", url)
        guard let deepLink = recognizer.deepLink(matching: url) else {
            return false
        }
        switch deepLink {
        case let link as SelectStoreDeepLink:
            return selectStore(link)
        case let link as SelectProductDeepLink:
            return selectProduct(link)
        default:
            return false
        }
    }
    
    private func selectStore(_ deepLink: SelectStoreDeepLink) -> Bool {
        print("Select Store...", deepLink.storeIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ProgressHUD.showSuccessWithStatus("Store-\(deepLink.storeIndex)")
            let info: [String : Any] = [
                "type" : "store",
                "index" : deepLink.storeIndex
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.DEEP_LINK), object: nil, userInfo: info)
        }
        return true
    }
    
    private func selectProduct(_ deepLink: SelectProductDeepLink) -> Bool {
        print("Select Product....", deepLink.productIndex)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ProgressHUD.showSuccessWithStatus("Product-\(deepLink.productIndex)")
            let info: [String : Any] = [
                "type" : "product",
                "index" : deepLink.productIndex
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.DEEP_LINK), object: nil, userInfo: info)
        }
        return true
    }
    
    private func setupUMessage(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        UMConfigure.initWithAppkey(uMessageAppKey, channel: "App Store")
        //UMConfigure.setLogEnabled(true)
        let entry = UMessageRegisterEntity()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entry) { (granted, error) in
            if granted {
                print("Notification Authorization Granted!")
            } else {
                print("Notification Authorization Error!")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("Application Did Enter Background........................")
        UserDefaultsUtil.shared.setIsOpenChatList(false)
        UserDefaultsUtil.shared.setOpenChatMessageId(-1)
        UserDefaultsUtil.shared.setIsOpenTicketList(false)
        UserDefaultsUtil.shared.setOpenTicketMessageId(-1)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Application Will Enter Forground.......................")
        if UserInstance.isLogin {
            HomeAPI.shared.tokenCheck { (json, success) in
                if success {
                    print("Token Check...")
                    print(json)
                } else {
                    // try again...
                    HomeAPI.shared.tokenCheck(completion: { (json, success1) in
                        if success1 {
                            print("Token Check...")
                            print(json)
                        } else {
                            UserInstance.userLogout()
                        }
                    })                    
                }
            }
        } else {
            UserInstance.userLogout()
        }
        
        if NetworkUtil.isReachable() {
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.APPLICATION_WILL_ENTER_FOREGROUND), object: nil)
        }
        
        MyAPI.shared.systemInfo { (json, success) in
            if success {
                print("System Info...")
                print(json)
                self.getSystemInfoFromJson(json)
                self.checkAppVersion()
            } else {
                //try again...
                MyAPI.shared.systemInfo(completion: { (json, success1) in
                    if success1 {
                        self.getSystemInfoFromJson(json)
                        self.checkAppVersion()
                    } else {
                        
                    }
                })
            }
        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Application Did Become Active...........")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        UserInstance.deviceToken = token
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        if UserInstance.isLogin {
            let parameters: [String: Any] = [
                "token" : token,
                "system" : true,
                "version" : currentVersion,
            ]
            AuthAPI.shared.deviceToken(params: parameters) { (json, success) in
                if success {
                    print("Register Device Token Success...")
                } else {
                    // try again...
                    AuthAPI.shared.deviceToken(params: parameters, completion: { (json, success1) in
                        if success1 {
                            
                        }
                    })
                }
            }
        }
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Register APNS fail.", error)
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"registerDeviceFailed" object:nil];
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "paishop")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - BMKGeneralDelegate
    func onGetNetworkState(_ iError: Int32) {
        if (0 == iError) {
            NSLog("联网成功");
        }
        else{
            NSLog("联网失败，错误代码：Error\(iError)");
        }
    }
    
    func onGetPermissionState(_ iError: Int32) {
        if (0 == iError) {
            NSLog("授权成功");
        }
        else{
            NSLog("授权失败，错误代码：Error\(iError)");
        }
    }

}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Handle notifications received at the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //print("UNUserNotification willPresent ", notification)
        
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger  {
            // Remote push acceptance when the app is in the foreground
            /*// Close the pop-up box of U-Push
            UMessage.setAutoAlert(true)
            UMessage.didReceiveRemoteNotification(userInfo)*/
            print("Receive Notification....willPresent")
            print(userInfo)
            UMessage.setAutoAlert(false)
            UMessage.didReceiveRemoteNotification(userInfo)
            
            //Process User Info
            guard let pushType = userInfo[AnyHashable("type")] as? String else { return }
            switch pushType {
            case "chat" :
                print("Receive Chat Notification...")
                guard let messageDictionary = userInfo[AnyHashable("message")] as? [String: Any] else {
                    return
                }
                let messageJson = JSON(messageDictionary)
                let message = ChatMessageModel(messageJson)
                
                if UserDefaultsUtil.shared.getOpenChatMessageId() > 0 {
                    // ChatVC opened...
                    if UserDefaultsUtil.shared.getOpenChatMessageId() == message.roomId! {
                        let info: [String: Any] = [
                            "type": UserDefaultsUtil.shared.OPEN_CHAT_MESSAGE_ID,
                            "status" : "receive",
                            "message": message
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil, userInfo: info)
                    } else {
                        // opened other room...
                        completionHandler([.alert, .sound])
                    }
                } else if UserDefaultsUtil.shared.getIsOpenChatList() {
                    // SocialVC Opened...
                    let info: [String: Any] = [
                        "type": UserDefaultsUtil.shared.IS_OPEN_CHAT_LIST,
                        "status" : "receive",
                        "message": message
                    ]
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil, userInfo: info)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        completionHandler([.alert, .sound])
                    })
                } else {
                    // Other VC Opened...
                    completionHandler([.alert, .sound])
                }
            case "order":
                print("Receive Order Notification...")
                completionHandler([.alert, .sound])
            case "support":
                print("Receive Support Notification...")
                guard let suppportDictionary = userInfo[AnyHashable("conversation")] as? [String : Any] else { return }
                let supportJson = JSON(suppportDictionary)
                let ticketMessage = TicketMessageModel.init(supportJson)
                let ticket = TicketListModel.init(supportJson["ticket"])
                
                let openTicketMessageId = UserDefaultsUtil.shared.getOpenTicketMessageId()
                if openTicketMessageId > 0 {
                    if openTicketMessageId == ticket.id {
                        let info: [String : Any] = [
                            "status" : "receive",
                            "ticketMessage" : ticketMessage
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil, userInfo: info)
                    } else {
                        completionHandler([.alert, .sound])
                    }
                } else {
                    completionHandler([.alert, .sound])
                }
            case "new_item":
                print("Receive New Item Notification...")
                completionHandler([.alert, .sound])
            case "payment":
                completionHandler([.alert, .sound])
            case "logout":
                completionHandler([.alert, .sound])
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_LOGOUT), object: nil, userInfo: nil)
                })
            default:
                break
            }
            
        } else {
            // Local push acceptance when the application is in the foreground
        }
        //completionHandler([.sound, .badge, .alert])
    }
    
    // Handle click notifications in the background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("UNUserNotification didReceive response ", response)
        
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            // Remote push acceptance when the application is in the background
            /*UMessage.didReceiveRemoteNotification(userInfo)*/
            print("Response Notification....")
            print(userInfo)
            UMessage.didReceiveRemoteNotification(userInfo)
            
            //Process User Info
            guard let pushType = userInfo[AnyHashable("type")] as? String else { return }
            switch pushType {
            case "chat":
                print("Response Chat Notification...")
                guard let messageDictionary = userInfo[AnyHashable("message")] as? [String: Any] else {
                    return
                }
                let messageJson = JSON(messageDictionary)
                let message = ChatMessageModel(messageJson)
                if UserDefaultsUtil.shared.getIsOpenChatList() {
                    let info: [String : Any] = [
                        "type": UserDefaultsUtil.shared.IS_OPEN_CHAT_LIST,
                        "status" : "response",
                        "message": message
                    ]
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil, userInfo: info)
                } else if UserDefaultsUtil.shared.getOpenChatMessageId() > 0 {
                    // close current ChatVC and open other ChatVC
                    
                } else {
                    if UserInstance.isLogin {                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            let info: [String : Any] = [
                                "type" : "openChat"
                            ]
                            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil, userInfo: info)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            let info: [String : Any] = [
                                "type": UserDefaultsUtil.shared.IS_OPEN_CHAT_LIST,
                                "status" : "response",
                                "message": message
                            ]
                            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_MESSAGE), object: nil, userInfo: info)
                        })
                    } else {
                        ProgressHUD.showWarningWithStatus("请登录后打开.")
                    }                    
                }
            case "support":
                print("Response Support Notification...")
                guard let suppportDictionary = userInfo[AnyHashable("conversation")] as? [String : Any] else { return }
                let supportJson = JSON(suppportDictionary)
                //let ticketMessage = TicketMessageModel.init(supportJson)
                let ticket = TicketListModel.init(supportJson["ticket"])
                if UserDefaultsUtil.shared.getIsOpenTicketList() {
                    let info: [String : Any] = [
                        "status" : "response",
                        "ticket" : ticket
                    ]
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil, userInfo: info)
                } else {
                    if UserInstance.isLogin {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            let info: [String : Any] = [
                                "type" : "openTicket"
                            ]
                            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil, userInfo: info)
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            let info: [String : Any] = [
                                "status" : "response",
                                "ticket" : ticket
                            ]
                            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_TICKET), object: nil, userInfo: info)
                        })
                    } else {
                        ProgressHUD.showWarningWithStatus("请登录后打开.")
                    }
                }
            case "order":
                print("Response Order Notification...")
                
                guard let orderId = userInfo[AnyHashable("order")] as? Int64 else { return }
                //Go to Order Detail...
                if UserInstance.isLogin {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        let info: [String : Any] = [
                            "orderId" : orderId
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_ORDER), object: nil, userInfo: info)
                    })
                } else {
                    ProgressHUD.showWarningWithStatus("请登录后打开.")
                }
            case "new_item":
                print("Response New Item Notification...")
                
                guard let productId = userInfo[AnyHashable("item")] as? Int64 else { return }
                //Go to Product Detail...
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    let info: [String : Any] = [
                        "type" : "openProductDetail",
                        "productId" : productId
                    ]
                    NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_NEW_ITEM), object: nil, userInfo: info)
                })
            case "payment":
                guard let paymentId = userInfo[AnyHashable("payment")] as? Int else { return }
                if UserInstance.isLogin {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        let info: [String : Any] = [
                            "type" : "openPayment",
                            "paymentId" : paymentId
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.PUSH_PAYMENT), object: nil, userInfo: info)
                    })
                }
                
            default:
                break
            }
            
        } else {
            // Local push acceptance when the application is in the background
        }
    }
    
}











