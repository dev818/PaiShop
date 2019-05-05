
import Foundation

class UserDefaultsUtil {
    
    static let shared = UserDefaultsUtil()
    
    let USER_LOGGED_IN = "user_logged_in"
    
    let IS_OPEN_CHAT_LIST = "is_open_chat_list"
    
    let OPEN_CHAT_MESSAGE_ID = "open_chat_message_id"
    
    let IS_OPEN_TICKET_LIST = "is_open_ticket_list"
    
    let OPEN_TICKET_MESSAGE_ID = "open_ticket_message_id"
    
    let IS_CHECK_PAYMENT_PASSWORD = "is_check_payment_password"
    
    let DEVICE_SOUND = "device_sound"
    
    let DEGREE_ARRAY = "degree_array"
    
    let DEGREE_IMAGE_ARRAY = "degree_image_array"
    
    let DEGREE_PROFIT_RATIO_ARRAY = "degree_profit_ration_arry"
    
    let DEGREE_NAME_ARRAY = "degree_name_array"
    
    let PERIOD_RATIO = "period_ratio"
    
    let SERVER_PAI_ADDRESS = "server_pai_address"
    
    let CURRENCY_RATE = "currency_rate"
    
    let POINT_EXCHANGE = "point_exchange"
    
    let IOS_URL = "ios_url"
    
    let RESTITUTION_RATE = "restitution_rate"
    
    let SERVER_PAI_PHONE = "server_pai_phone"
    
    let IOS_VERSION = "ios_version"
    
    let SELECTED_THEME  = "selected_theme"
    
    func setAccessToken(_ token: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(token, forKey: Constants.ACCESS_TOKEN)
    }
    
    func getAccessToken() -> String {
        let userDefaults = UserDefaults.standard
        if let token = userDefaults.value(forKey: Constants.ACCESS_TOKEN) {
            return token as! String
        } else {
            return ""
        }
    }
    
    
    func setUserLoggedIn(_ loggedIn: Bool) {
        let userdefaults = UserDefaults.standard
        userdefaults.set(loggedIn, forKey: USER_LOGGED_IN)
    }
    
    func isUserLoggedIn() -> Bool {
        let userDefaults = UserDefaults.standard
        if let loggedIn = userDefaults.value(forKey: USER_LOGGED_IN) as? Bool {
            return loggedIn
        }
        return false
    }
    
    
    func setIsOpenChatList(_ opened: Bool) {
        UserDefaults.ts_setBool(IS_OPEN_CHAT_LIST, value: opened)
    }
    func getIsOpenChatList() -> Bool {
        return UserDefaults.ts_boolForKey(IS_OPEN_CHAT_LIST, defaultValue: false)
    }
    
    
    func setOpenChatMessageId(_ id: Int64) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(id, forKey: OPEN_CHAT_MESSAGE_ID)
        userDefaults.synchronize()
    }    
    func getOpenChatMessageId() -> Int64 {
        let userDefaults = UserDefaults.standard
        if let id = userDefaults.value(forKey: OPEN_CHAT_MESSAGE_ID) as? Int64 {
            return id
        }
        return -1
    }
    
    
    func setIsOpenTicketList(_ opened: Bool) {
        UserDefaults.ts_setBool(IS_OPEN_TICKET_LIST, value: opened)
    }
    func getIsOpenTicketList() -> Bool {
        return UserDefaults.ts_boolForKey(IS_OPEN_TICKET_LIST, defaultValue: false)
    }
    
    
    func setOpenTicketMessageId(_ id: Int) {
        UserDefaults.ts_setInteger(OPEN_TICKET_MESSAGE_ID, value: id)
    }
    func getOpenTicketMessageId() -> Int {
        return UserDefaults.ts_integerForKey(OPEN_TICKET_MESSAGE_ID, defaultValue: -1)
    }
    
    
    func setIsCheckPaymentPassword(_ checked: Bool) {
        UserDefaults.ts_setBool(IS_CHECK_PAYMENT_PASSWORD, value: checked)
    }
    func getIsCheckPaymentPassword() -> Bool {
        return UserDefaults.ts_boolForKey(IS_CHECK_PAYMENT_PASSWORD, defaultValue: false)
    }
    
    
    func setDegreeArray(_ degreeArray: [[String: Any]]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(degreeArray, forKey: DEGREE_ARRAY)
        userDefaults.synchronize()
    }
    func getDegreeArray() -> [[String: Any]] {
        let userDefaults = UserDefaults.standard
        if let degreeArray = userDefaults.array(forKey: DEGREE_ARRAY) as? [[String: Any]] {
            return degreeArray
        }
        return []
    }
    
    
    func setDegreeImageArray(_ degreeImageArray: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(degreeImageArray, forKey: DEGREE_IMAGE_ARRAY)
        userDefaults.synchronize()
    }
    func getDegreeImageArray() -> [String] {
        let userDefaults = UserDefaults.standard
        if let degreeImageArray = userDefaults.array(forKey: DEGREE_IMAGE_ARRAY) as? [String] {
            return degreeImageArray
        }
        return []
    }
    
    
    func setDegreeProfitRatioArray(_ degreeProfitRatioArray: [Int]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(degreeProfitRatioArray, forKey: DEGREE_PROFIT_RATIO_ARRAY)
        userDefaults.synchronize()
    }
    func getDegreeProfitRatioArray() -> [Int] {
        let userDefaults = UserDefaults.standard
        if let degreeProfitArray = userDefaults.array(forKey: DEGREE_PROFIT_RATIO_ARRAY) as? [Int] {
            return degreeProfitArray
        }
        return []
    }
    
    
    func setDegreeNameArray(_ degreeNameArray: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(degreeNameArray, forKey: DEGREE_NAME_ARRAY)
        userDefaults.synchronize()
    }
    func getDegreeNameArray() -> [String] {
        let userDefaults = UserDefaults.standard
        if let degreeNameArray = userDefaults.array(forKey: DEGREE_NAME_ARRAY) as? [String] {
            return degreeNameArray
        }
        return []
    }
    
    
    func setDeviceSound(_ status: Bool) {
        UserDefaults.ts_setBool(DEVICE_SOUND, value: status)
    }
    func getDeviceSound() -> Bool {
        return UserDefaults.ts_boolForKey(DEVICE_SOUND, defaultValue: true)
    }
   
    
    func setPeriodRatio(_ ratio: Double) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(ratio, forKey: PERIOD_RATIO)
        userDefaults.synchronize()
    }
    func getPeriodRatio() -> Double {
        let userDefaults = UserDefaults.standard
        if let ratio = userDefaults.value(forKey: PERIOD_RATIO) as? Double {
            return ratio
        }
        return 1.00
    }
    
    
    func setServerPaiAddress(_ paiAddress: String) {
        UserDefaults.ts_setString(SERVER_PAI_ADDRESS, value: paiAddress)
    }
    func getServerPaiAddress() -> String {
        let userDefaults = UserDefaults.standard
        if let paiAddress = userDefaults.value(forKey: SERVER_PAI_ADDRESS) as? String {
            return paiAddress
        }
        return ""
    }
    
    
    func setCurrencyRate(_ currencyRate: Double) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(currencyRate, forKey: CURRENCY_RATE)
        userDefaults.synchronize()
    }
    func getCurrencyRate() -> Double {
        let userDefaults = UserDefaults.standard
        if let currencyRate = userDefaults.value(forKey: CURRENCY_RATE) as? Double {
            return currencyRate
        }
        return 6.58
    }
    
    
    func setPointExchange(_ pointExchange: [String]) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(pointExchange, forKey: POINT_EXCHANGE)
        userDefaults.synchronize()
    }
    func getPointExchange() -> [String] {
        let userDefaults = UserDefaults.standard
        if let pointExchange = userDefaults.array(forKey: POINT_EXCHANGE) as? [String] {
            return pointExchange
        }
        return []
    }
    
    
    func setIosUrl(_ iosUrl: String) {
        UserDefaults.ts_setString(IOS_URL, value: iosUrl)
    }
    func getIosUrl() -> String {
        let userDefaults = UserDefaults.standard
        if let iosUrl = userDefaults.value(forKey: IOS_URL) as? String {
            return iosUrl
        }
        return ""
    }
    
    
    func setRestitutionRate(_ rate: Double) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(rate, forKey: RESTITUTION_RATE)
        userDefaults.synchronize()
    }
    func getRestitutionRate() -> Double {
        let userDefaults = UserDefaults.standard
        if let rate = userDefaults.value(forKey: RESTITUTION_RATE) as? Double {
            return rate
        }
        return 200.00
    }
    
    
    func setServerPaiPhone(_ paiPhone: String) {
        UserDefaults.ts_setString(SERVER_PAI_PHONE, value: paiPhone)
    }
    func getServerPaiPhone() -> String {
        let userDefaults = UserDefaults.standard
        if let paiPhone = userDefaults.value(forKey: SERVER_PAI_PHONE) as? String {
            return paiPhone
        }
        return ""
    }
    
    
    func setIosVersion(_ version: String) {
        UserDefaults.ts_setString(IOS_VERSION, value: version)
    }
    func getIosVersion() -> String {
        let userDefaults = UserDefaults.standard
        if let version = userDefaults.value(forKey: IOS_VERSION) as? String {
            return version
        }
        return "1.0"
    }
    
    
    func setSelectedTheme(_ theme: Int) {
        UserDefaults.ts_setInteger(SELECTED_THEME, value: theme)
    }
    func getSelectedTheme() -> Int {
        let userDefaults = UserDefaults.standard
        if let selectedTheme = userDefaults.value(forKey: SELECTED_THEME) as? Int {
            return selectedTheme
        }
        return 0
    }
    
    
}






