
import UIKit
import KeychainAccess
import SwiftyJSON

private let kId             = "kPaishop_userid"
private let kNickname       = "kPaishop_username"
private let kGender         = "kPaishop_gender"
private let kAddress        = "kPaishop_address"
private let kAvatar         = "kPaishop_avatar"
private let kIntroduction   = "kPaishop_introduction"
private let kPaiBalance     = "kPaishop_pai_balance"
private let kRmbBalance     = "kPaishop_rmb_balance"
private let kUserId         = "kPaishop_userId"
private let kPaiAddress     = "kPaishop_pai_address"
private let kStoreId        = "kPaishop_storeId"
private let kStoreStatus    = "kPaishop_store_status"
private let kPoint          = "kPaishop_point"
private let kDegreeId       = "kPaishop_degreeId"
private let kMobileKey      = "kPaishop_mobile_key"
private let kGuardPayment   = "kPaishop_guard_payment"
private let kDegreePeriod   = "kPaishop_degree_period"
private let kRefereeId      = "kPaishop_referee_id"
private let kLevelId        = "kPaishop_level_id"
private let kDiscovery      = "kPaishop_discovery"         //new => h.g.n
private let kDisAddress     = "kPaishop_dis_addr"          //new => h.g.n
private let kPointExchange  = "kPaishop_point_exchange30"  //new => h.g.n

private let kAccessToken    = "kPaishop_accessToken"
private let kIsLogin        = "kPaishop_isLogin"
private let kLoginName      = "kPaishop_loginName"   // <- Phone number
private let kPassword       = "kPaishop_password"
private let kDeviceToken    = "kPaishop_deviceToken" // apple push token
private let kAlipayAddress  = "kPaishop_ali_address"

let UserInstance = UserManager.sharedInstance

class UserManager: NSObject {
    let testUserID = "wx1234skjksmsjdfwe234"
    
    class var sharedInstance: UserManager {
        struct Static {
            static let instance: UserManager = UserManager()
        }
        return Static.instance
    }
    
    let keyChain = Keychain(service: "com.paishop")
    
    var accessToken: String? {
        get {
            return UserDefaults.ts_stringForKey(kAccessToken, defaultValue: "这是我的 AccessToken")            
        }
        set (newValue) {
            UserDefaults.ts_setString(kAccessToken, value: newValue)
        }
    }
    
    var deviceToken: String? {
        get {
            return UserDefaults.ts_stringForKey(kDeviceToken, defaultValue: "")
        }
        set (newValue) {
            UserDefaults.ts_setString(kDeviceToken, value: newValue)
        }
    }
    
    var isLogin: Bool {
        get {
            return UserDefaults.ts_boolForKey(kIsLogin, defaultValue: false)
        }
        set (newValue) {
            UserDefaults.ts_setBool(kIsLogin, value: newValue)
        }
    }
    
    /// User Phone Number in keychain
    var loginName: String? {
        get {
            return  keyChain[kLoginName] ?? ""
        }
        set (newValue) {
            keyChain[kLoginName] = newValue
        }
    }
    
    /// Password in keychain
    var password: String?  {
        get {
            return  keyChain[kPassword] ?? ""
        }
        set (newValue) {
            keyChain[kPassword] = newValue
        }
    }
    
    var id: Int? {
        get {
            return UserDefaults.ts_integerForKey(kId, defaultValue: 0)
        }
        set (newValue) {
            UserDefaults.ts_setInteger(kId, value: newValue!)
        }
    }
    
    var nickname: String? {
        get {
            return UserDefaults.ts_stringForKey(kNickname, defaultValue: "") 
        }
        set (newValue) {
            UserDefaults.ts_setString(kNickname, value: newValue)
        }
    }
    
    var gender: Bool {
        get {
            return UserDefaults.ts_boolForKey(kGender, defaultValue: true)
        }
        set (newValue) {
            UserDefaults.ts_setBool(kGender, value: newValue)
        }
    }
    
    var address: String? {
        get {
            return UserDefaults.ts_stringForKey(kAddress, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kAddress, value: newValue)
        }
    }
    
    var avatar: String? {
        get {
            return UserDefaults.ts_stringForKey(kAvatar, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kAvatar, value: newValue)
        }
    }
    
    var introduction: String? {
        get {
            return UserDefaults.ts_stringForKey(kIntroduction, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kIntroduction, value: newValue)
        }
    }
    
    var paiBalance: String? {
        get {
            return UserDefaults.ts_stringForKey(kPaiBalance, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kPaiBalance, value: newValue)
        }
    }
    
    var rmbBalance: String? {
        get {
            return UserDefaults.ts_stringForKey(kRmbBalance, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kRmbBalance, value: newValue)
        }
    }
    
    var paiAddress: String? {
        get {
            return UserDefaults.ts_stringForKey(kPaiAddress, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kPaiAddress, value: newValue)
        }
    }
    
    var alipayAddress: String? {
        get {
            return UserDefaults.ts_stringForKey(kAlipayAddress, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kAlipayAddress, value: newValue)
        }
    }
    
    var storeId: Int? {
        get {
            return UserDefaults.ts_integerForKey(kStoreId, defaultValue: -1)
        }
        set(newValue) {
            UserDefaults.ts_setInteger(kStoreId, value: newValue!)
        }
    }
    
    var storeStatus: Int? {
        get {
            return UserDefaults.ts_integerForKey(kStoreStatus, defaultValue: -1)
        }
        set(newValue) {
            UserDefaults.ts_setInteger(kStoreStatus, value: newValue!)
        }
    }
    
    var point: String? {
        get {
            return UserDefaults.ts_stringForKey(kPoint, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kPoint, value: newValue)
        }
    }
    
    var poinr_exchange30: String? {
        get {
            return UserDefaults.ts_stringForKey(kPointExchange, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kPointExchange, value: newValue)
        }
    }
    
    var degreeId: Int? {
        get {
            return UserDefaults.ts_integerForKey(kDegreeId, defaultValue: 0)
        }
        set(newValue) {
            UserDefaults.ts_setInteger(kDegreeId, value: newValue!)
        }
    }
    
    var degreePeriod: String? {
        get {
            return UserDefaults.ts_stringForKey(kDegreePeriod, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kDegreePeriod, value: newValue)
        }
    }
    
    var referee_id: Int? {
        get {
            return UserDefaults.ts_integerForKey(kRefereeId, defaultValue: 0)
        }
        set(newValue) {
            UserDefaults.ts_setInteger(kRefereeId, value: newValue!)
        }
    }
    
    var level_id: Int? {
        get {
            return UserDefaults.ts_integerForKey(kLevelId, defaultValue: 0)
        }
        set(newValue) {
            UserDefaults.ts_setInteger(kLevelId, value: newValue!)
        }
    }
    
    var discovery: String? {
        get {
            return UserDefaults.ts_stringForKey(kDiscovery, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kDiscovery, value: newValue!)
        }
    }
    
    var dis_addr: String? {
        get {
            return UserDefaults.ts_stringForKey(kDisAddress, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kDisAddress, value: newValue!)
        }
    }
    
    var mobileKey: String? {
        get {
            return UserDefaults.ts_stringForKey(kMobileKey, defaultValue: "")
        }
        set(newValue) {
            UserDefaults.ts_setString(kMobileKey, value: newValue!)
        }
    }
    
    var guardPayment: Bool {
        get {
            return UserDefaults.ts_boolForKey(kGuardPayment, defaultValue: false)
        }
        set(newValue) {
            UserDefaults.ts_setBool(kGuardPayment, value: newValue)
        }
    }
    
    var userId: Int? {
        get {
            return UserDefaults.ts_integerForKey(kUserId, defaultValue: -1)
        }
        set (newValue) {
            UserDefaults.ts_setInteger(kUserId, value: newValue!)
        }
    }
    
    fileprivate override init() {
        super.init()
    }
    
    func readAllData() {
        self.nickname = UserDefaults.ts_stringForKey(kNickname, defaultValue: "")
        self.avatar = UserDefaults.ts_stringForKey(kAvatar, defaultValue: "")
        //self.userId = UserDefaults.ts_stringForKey(kUserId, defaultValue: "")
        self.isLogin = UserDefaults.ts_boolForKey(kIsLogin, defaultValue: false)
        self.loginName = keyChain[kLoginName] ?? ""
        self.password = keyChain[kPassword] ?? ""
    }
    
    /**
     登录成功
     - parameter result: 登录成功后传进来的字典
     */
    func userLoginSuccess(_ result: JSON) {
        //print(result)
        self.isLogin = true
        self.nickname = result["name"].stringValue
        self.id = result["id"].intValue
        self.loginName = result["phone_number"].stringValue
        self.gender = result["gender"].boolValue
        self.address = result["address"].stringValue
        self.avatar = result["image"].stringValue//API.IMAGE_URL + result["image"].stringValue
        self.introduction = result["introduction"].stringValue
        self.paiBalance = result["pai_balance"].stringValue
        self.rmbBalance = result["yen_balance"].stringValue
        self.paiAddress = result["pai_address"].stringValue
        self.alipayAddress = result["alipay_address"].stringValue
        if result["stores"].arrayValue.count > 0 {
            let store = result["stores"].arrayValue.first!
            self.storeId = store["id"].intValue
            self.storeStatus = store["status"].intValue
        }
        self.point = result["point"].stringValue
        self.poinr_exchange30 = result["poinr_exchange30"].stringValue
        self.degreeId = result["degree_id"].intValue
        self.mobileKey = result["pai_phone"].stringValue
        self.userId = result["id"].intValue
        self.guardPayment = result["guard_payment"].boolValue
        self.degreePeriod = result["period"].stringValue
        self.referee_id = result["referee_id"].intValue
        self.level_id = result["level_id"].intValue
        self.discovery = result["discover_blance"].stringValue
        self.dis_addr = result["discover_addr"].stringValue
        
    }
    
    /**
     退出登录
     */
    func userLogout() {
        self.isLogin = false
        self.accessToken = ""
        self.loginName = ""
        self.password = ""
        self.id = 0
        self.nickname = ""
        self.address = ""
        self.avatar = ""
        self.introduction = ""
        self.paiBalance = ""
        self.rmbBalance = ""
        self.paiAddress = ""
        self.storeId = -1
        self.point = ""
        self.poinr_exchange30 = ""
        self.degreeId = 1
        self.mobileKey = ""
        self.userId = -1
        self.guardPayment = false
        self.degreePeriod = ""
        self.referee_id = 0
        self.level_id = 0
        self.discovery = ""
        self.dis_addr = ""
        self.alipayAddress = ""
    }
    
    func hasStore() -> Bool {
        if storeId! < 1 {
            return false
        }
        return true
    }
    
    func hasVerifiedStore() -> Bool {
        if storeId! < 0 {
            return false
        }
        if storeStatus! != 1 {
            return false
        }
        return true
    }
    
    func resetAccessToken(_ token: String) {
        UserDefaults.ts_setString(kAccessToken, value: token)
        if token.count > 0 {
            print("token success")
        } else {
            self.userLogout()
        }
    }

}
