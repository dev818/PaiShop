
import Foundation

public var loadRecmFirst = true

public var TRADE_NO = ""
public var TRADE_NUMBER = ""
public var SELLER_ID = ""
public var OUT_TRADE_NO = ""
public var AlipayPaid = false
public var VCArray: NSArray!

public struct Constants {
    
    static var SCREEN_WIDTH = UIScreen.main.bounds.width
    
    static var SCREEN_HEIGHT = UIScreen.main.bounds.height
    
    static let ALIYUN_IMAGE_RESIZE_PRIFIX = "?x-oss-process=image/resize,"
    
    static let ACCESS_TOKEN = "access_token"
    
    static let GOODS_IMAGE = "goods"
    
    static let SHOP_IMAGE = "shop"
    
    static let PROFILE_IMAGE = "profile"
    
    static let CHAT_IMAGE = "chat"
    
    static let LIVE_VIDEO = "live"
    
    static let QR_PAYMENT = "qrpayment"
    
    static let ARTICLE = "article"
    
    /***************** sandbox ******************/
    /*static let ALIYUN_URL_PREFIX = "http://pisandbox.oss-cn-beijing.aliyuncs.com/"
    static let OSS_BUCKET_NAME = "pisandbox"*/
    
    /***************** server ******************/
    //static let ALIYUN_URL_PREFIX = "http://piworld.oss-cn-beijing.aliyuncs.com/"
    static let ALIYUN_URL_PREFIX = "http://oss.pi-world.net/"
    static let OSS_BUCKET_NAME = "piworld"
    
    
    
    /****************** local *******************/
    //static let WEB_SOCKET_LIVE_VIDEO_URL = "ws://192.168.0.106:6000/"
    
    /***************** server ******************/
    static let WEB_SOCKET_LIVE_VIDEO_URL = "ws://116.62.226.8:6000/"
    
    static let WEB_SOCKET_CHAT_URL = "ws://116.62.226.8:3000/"
}

public struct Notifications {
    
    static let MOVE_TAB_BAR = "move_tab_bar"
    
    static let HOME_CITY_SELECT = "home_city_select"
    
    static let HOME_WHOLE_SELECT = "home_whole_select"
    
    static let HOME_DID_LOAD = "home_did_load"
    
    static let PUSH_MESSAGE = "push_message"
    
    static let PUSH_TICKET = "push_ticket"
    
    static let PUSH_ORDER = "push_order"
    
    static let PUSH_NEW_ITEM = "push_new_item"
    
    static let PUSH_PAYMENT = "push_payment"
    
    static let PUSH_LOGOUT = "push_logout"
    
    static let CHAT_CREATE_ROOM = "chat_create_room"
    
    static let STORE_ITEM_EDIT = "store_item_edit"
    
    static let SELECT_ADDRESS = "select_address"
    
    static let PRODUCT_DETAIL_CHANGE = "product_detail_change"
    
    static let STORE_DETAIL_CHANGE = "store_detail_change"
    
    static let APPLICATION_WILL_ENTER_FOREGROUND = "application_will_enter_foreground"
    
    static let CART_ITEMS_REMOVE = "cart_items_remove"
    
    static let LOGOUT_APPLICATION = "logout_application"
    
    static let LOGIN_APPLICATION = "login_application"
    
    static let DEEP_LINK = "deep_link"
    
    static let STORE_ORDER_CHANGE = "store_order_change"
    
    static let MINE_ORDER_CHANGE = "mine_order_change"
    
    static let VERSION_UPDATE = "version_update"
    
    static let QR_PAY_SUCCESS = "qr_pay_success"
        
    static let CHANGE_THEME = "change_theme"
    
    
    
    static let CONTACT_ADD = "contact_add"
    
    static let CONTACT_SELECT = "contact_select"
    
    static let CONTACTS_BACK = "contacts_back"
    
    static let CONTACT_EDIT = "contact_edit"
    
    
    static let ALIPAY_SUCCESS = "Alipay_success"
    
    static let LEVEL_ALIPAY_SUCCESS = "Level_alipay_success"
    
}


public struct API {
    private init() {}
    static let shared = API()
    
    /****************** local *******************/
     /*public static let HOST = "http://192.168.0.100/paishop"
     public static let BASE_URL = HOST + "/public/api"
     public static let IMAGE_URL = HOST + "/storage/app/"
     public static let WEB_LINK = HOST + "/public"*/
    
    /*public static let HOST = "http://192.168.0.106"
    public static let BASE_URL = HOST + "/api"
    public static let IMAGE_URL = HOST + "/storage/app/"
    public static let WEB_LINK = HOST*/
    
    
    /****************** server *******************/
    //public static let HOST = "http://paikepaifu.cn" //"http://116.62.226.8"
    //public static let HOST = "http://dev.pi-world.net" //Test Server
    public static let HOST = "http://api.pi-world.net" //Real Server
    public static let BASE_URL = HOST + "/api"
    public static let IMAGE_URL = HOST + "/storage/app/"
    public static let WEB_LINK = HOST
    
    
    /**************************** Auth ***************************/
    
    public static let SEND_VERIFY_CODE = BASE_URL + "/verifycode/send"
    
    public static let REGISTER = BASE_URL + "/register"
    
    public static let LOGIN = BASE_URL + "/login"
    
    public static let LOGOUT = BASE_URL + "/logout"
    
    public static let FORGOT_PASSWORD = BASE_URL + "/password/forgot"
    
    public static let RESET_PASSWORD = BASE_URL + "/password/reset"
    
    public static let PROFILE_GET = BASE_URL + "/profile/get"
    
    public static let PROFILE_SET = BASE_URL + "/profile/set"
    
    public static let PROFILE_IMAGE_UPDATE = BASE_URL + "/profile/image/update"
    
    public static let DEVICE_TOKEN = BASE_URL + "/device/token"
    
    public static let DEVICE_REFRESH = BASE_URL + "/device/refresh"
    
    
    
    
    /**************************** Home ***************************/
    
    public static let ITEM_PROMOTIONS = BASE_URL + "/promotions"
    
    public static let CATEGORY_ROOT = BASE_URL + "/category/root"
    
    public static let HOME_ITEMS = BASE_URL + "/item/home?page=%@"
    
    public static let ITEM_CATEGORY = BASE_URL + "/item/category?page=%@"
    
    public static let ITEM_CITY = BASE_URL + "/item/city?page=%@"
    
    public static let ITEM_DETAIL = BASE_URL + "/item/detail"
    
    public static let STORE_DETAIL = BASE_URL + "/store/detail"
    
    public static let ITEM_STORE = BASE_URL + "/item/store?page=%@"
    
    public static let CITY_ROOT = BASE_URL + "/city/root"
    
    public static let CITY_CHILDREN = BASE_URL + "/city/children"
    
    public static let COMMENT_DETAIL = BASE_URL + "/comment/detail"
    
    public static let COMMENT_ADD = BASE_URL + "/comment/create"
    
    public static let COMMENT_CHANGE = BASE_URL + "/comment/change"
    
    public static let COMMENT_DELETE = BASE_URL + "/comment/delete"
    
    public static let COMMENT_ITEM = BASE_URL + "/comment/item?page=%@"
    
    public static let STORE_REGISTER = BASE_URL + "/store/register"
    
    public static let ITEM_SEARCH = BASE_URL + "/item/search?page=%@"
    
    public static let ITEM_LIKE = BASE_URL + "/item/like"
    
    public static let TOKEN_CHECK = BASE_URL + "/token/check"
    
    public static let STORE_FAVORITE_ADD = BASE_URL + "/store/favorite/add"
    
    public static let STORE_FAVORITE_DELETE = BASE_URL + "/store/favorite/delete"
    
    public static let STORE_FAVORITE_LIST = BASE_URL + "/store/favorite/list?page=%@"
    
    public static let NOTIFICATION_LIST = BASE_URL + "/notification/list"
    
    public static let DEGREES = BASE_URL + "/degrees"
    
    public static let STORE_RECOMMEND = BASE_URL + "/store/recommend"
    
    public static let ITEM_RECOMMEND = BASE_URL + "/item/recommend"
    
    public static let RECOMMENDS = BASE_URL + "/recommends"
    
    public static let ITEM_FAVORITE_ADD = BASE_URL + "/item/favorite/add"
    
    public static let ITEM_FAVORITE_DELETE = BASE_URL + "/item/favorite/delete"
    
    public static let ITEM_FAVORITE_LIST = BASE_URL + "/item/favorite/list?page=%@"
    
    public static let ITEM_STORE_BEST = BASE_URL + "/item/store/best"
    
    
    
    /**************************** Guide ***************************/
    
    public static let STORE_LOCATION = BASE_URL + "/store/location"
    
    public static let STORE_CITY = BASE_URL + "/store/city"
    
    public static let STORE_CATEGORY = BASE_URL + "/store/category?page=%@"
    
    public static let STORE_SEARCH = BASE_URL + "/store/search"
    
    
    /**************************** My ***************************/
    
    public static let PROFILE_DEGREE_UPDATE = BASE_URL + "/profile/degree/update"
    
    public static let PROFILE_DEGREE = BASE_URL + "/profile/degree"
    
    
    public static let CART_LIST = BASE_URL + "/cart/list"
    
    public static let CART_DETAIL = BASE_URL + "/cart/detail"
    
    public static let CART_ADD = BASE_URL + "/cart/create"
    
    public static let CART_DELETE = BASE_URL + "/cart/delete"
    
    public static let CART_DELETE_ALL = BASE_URL + "/cart/delete/all"
    
    public static let CART_CHANGE = BASE_URL + "/cart/change"
    
    public static let CART_DELETES = BASE_URL + "/cart/deletes"
    
    
    public static let ITEM_MINE = BASE_URL + "/item/mine?page=%@"
    
    public static let ITEM_REGISTER = BASE_URL + "/item/register"
    
    public static let ITEM_DELETE = BASE_URL + "/item/delete"
    
    public static let ITEM_ACTIVE = BASE_URL + "/item/active"
    
    public static let ITEM_INACTIVE = BASE_URL + "/item/inactive"
    
    public static let ITEM_CHANGE = BASE_URL + "/item/change"
    
    
    public static let STORE_MINE = BASE_URL + "/store/mine"
    
    public static let STORE_CHANGE = BASE_URL + "/store/change"
    
    
    public static let TICKET_LIST = BASE_URL + "/ticket/list?page=%@"
    
    public static let TICKET_CREATE = BASE_URL + "/ticket/create"
    
    public static let TICKET_DELETE = BASE_URL + "/ticket/delete"
    
    public static let TICKET_MESSAGE_GET = BASE_URL + "/ticket/message/get"
    
    public static let TICKET_MESSAGE_SEND = BASE_URL + "/ticket/message/send"
    
    
    public static let PAYMENT_ADDRESS = BASE_URL + "/payment/address"
    
    public static let PAYMENT_PASSWORD_CHANGE = BASE_URL + "/payment/password/change"
    
    public static let PAYMENT_PASSWORD_VERIFY = BASE_URL + "/payment/password/verify"
    
    public static let PAYMENT_CREATE = BASE_URL + "/payment/create"
    
    public static let PAYMENT_LIST = BASE_URL + "/payment/list?page=%@"
    
    public static let PAYMENT_DETAIL = BASE_URL + "/payment/detail"
    
    public static let PAYMENT_EXCHANGE = BASE_URL + "/payment/exchange"
    
    
    public static let ORDER_LIST = BASE_URL + "/order/list?page=%@"
        
    public static let ORDER_CREATE = BASE_URL + "/order/create"
    
    public static let ORDER_DETAIL = BASE_URL + "/order/detail"
    
    public static let ORDER_STATUS_CHANGE = BASE_URL + "/order/status/change"
    
    public static let ORDER_DELETE = BASE_URL + "/order/delete"
    
    
    public static let CONFIG_RATES = BASE_URL + "/config/rates"
    
    public static let TRANSACTION_LIST = BASE_URL + "/transaction/list?page=%@"
    
    public static let RESTITUTION_LIST = BASE_URL + "/restitution/list?page=%@"
    
    public static let RESTITUTION_TRANSACTION_LIST = BASE_URL + "/restitution/transaction/list?page=%@"
    
    public static let DEVICE_SOUND = BASE_URL + "/device/sound"
    
    public static let SYSTEM_INFO = BASE_URL + "/system/info"
    
    public static let PHONENUMBER_UPDATE = BASE_URL + "/phonenumber/update"    
    
    public static let LIVE_MINE = BASE_URL + "/live/mine"
    
    public static let LIVE_ACTIVE = BASE_URL + "/live/active"
    
    public static let LIVE_INACTIVE = BASE_URL + "/live/inactive"
    
    public static let LIVE_DELETE = BASE_URL + "/live/delete"
    
    
    public static let CONTACT_LIST = BASE_URL + "/contact/list"
    
    public static let CONTACT_UPDATE = BASE_URL + "/contact/update"
    
    public static let CONTACT_ADD = BASE_URL + "/contact/add"
    
    public static let CONTACT_DELETE = BASE_URL + "/contact/delete"
    
    public static let CONTACT_DEFAULT = BASE_URL + "/contact/default"
    
    
    public static let PURCHASE_LEVEL = BASE_URL + "/setting/set"
    
    public static let GET_INVITES = BASE_URL + "/invite/getinvites"
    
    public static let GET_SECOND = BASE_URL + "/invite/getSecond"
    
    public static let GET_DETAILALL = BASE_URL + "/invite/getdetailall"
    
    public static let GET_DETAIL = BASE_URL + "/invite/getdetail"
    
    public static let GET_SETTING = BASE_URL + "/setting"
    

    /**************************** Social ***************************/
    
    public static let CHAT_ALL = BASE_URL + "/chat/all?page=%@"
    
    public static let CHAT_LIST = BASE_URL + "/chat/list?page=%@"
    
    public static let CHAT_MESSAGE_GET = BASE_URL + "/chat/message/get?page=%@"
    
    public static let CHAT_MESSAGE_SEND = BASE_URL + "/chat/message/send"
    
    public static let USER_LIST = BASE_URL + "/user/list?page=%@"
    
    public static let CHAT_CREATE = BASE_URL + "/chat/create"
    
    public static let CHAT_DETAIL = BASE_URL + "/chat/detail"
    
    public static let CHAT_LEAVE = BASE_URL + "/chat/leave"
    
    public static let CHAT_BADGE = BASE_URL + "/badge/update"
    
    public static let USER_INFO = BASE_URL + "/user/info"
    
    
    public static let LIVE_PLAY_URL = BASE_URL + "/aliyun/live/play/url"
    
    public static let LIVE_PUSH_URL = BASE_URL + "/aliyun/live/push/url"
    
    public static let LIVE_PUSH_START = BASE_URL + "/aliyun/live/push/start"
    
    public static let LIVE_PUSH_STOP = BASE_URL + "/aliyun/live/push/stop"
    
    public static let LIVE_LIST = BASE_URL + "/live/list"
    
    public static let LIVE_PUSH_EXTEND = BASE_URL + "/aliyun/live/push/extend"
    
    public static let LIVE_PLAY_EXTEND = BASE_URL + "/aliyun/live/play/extend"
    
    public static let LIVE_LIKE = BASE_URL + "/live/like"
    
    public static let LIVE_CHAT_GET = BASE_URL + "/live/chat/get"
    
    public static let LIVE_CHAT_SEND = BASE_URL + "/live/chat/send"
    
    public static let LIVE_FAVORITE_ADD = BASE_URL + "/live/favorite/add"
    
    public static let LIVE_FAVORITE_DELETE = BASE_URL + "/live/favorite/delete"
    
    public static let LIVE_FAVORITE_LIST = BASE_URL + "/live/favorite/list?page=%@"
    
    
    /**************************** Category ***************************/
    
    public static let ITEM_FIND = BASE_URL + "/item/find_sub?page=%@"
    
    public static let CATEGORY_FIRST = BASE_URL + "/category/root"
    
    public static let CATEGORY_SUB = BASE_URL + "/category/sub"
    
    public static let NOTIFICATION_BANNERS = BASE_URL + "/notification/banners"
    
    public static let ITEM_GOOD = BASE_URL + "/item/good"
    

    /**************************** Nearby ***************************/
    
    public static let STORE_AROUND = BASE_URL + "/store/around"
    
    
    /**************************** Find ***************************/
    public static let POST_CREATE = BASE_URL + "/post/create"
    
    public static let POSTS = BASE_URL + "/post/all?page=%@"
    
    public static let POSTSALL = BASE_URL + "/post/all"
    
    public static let GET_FAVORITES = BASE_URL + "/post/getFavorites"
    
    public static let GET_COMMENTS = BASE_URL + "/post/getComments"
    
    public static let CREATE_COMMENT = BASE_URL + "/post/createComment"
    
    public static let ADD_VIEW = BASE_URL + "/post/addView"
    
    public static let ADD_FAVORITE = BASE_URL + "/post/addFavorite"
    
    public static let ADD_REPORT = BASE_URL + "/post/addReport"
    
    public static let ADD_LIKE = BASE_URL + "/post/addLike"
    
    public static let SHOW_AUTHOR = BASE_URL + "/post/showAuthor"
    
    public static let REMOVE_FAVORITE = BASE_URL + "/post/removeFavorite"
    
    public static let REMOVE_REPORT = BASE_URL + "/post/removeReport"
    
    public static let REMOVE_LIKE = BASE_URL + "/post/removeLike"
    
    public static let HIDE_AUTHOR = BASE_URL + "/post/hideAuthor"
    
    public static let POSTS_MINE = BASE_URL + "/post/mine"
    
    public static let POST_ACTIVE = BASE_URL + "/post/active"
    
    public static let POST_INACTIVE = BASE_URL + "/post/inActive"
    
    public static let POST_DELETE = BASE_URL + "/post/delete"
    

    /**************************** Payment ***************************/
    
    public static let ALIPAY_ORDER = BASE_URL + "/alipay/getOrder"   
    
    public static let WECHAT_ORDER = BASE_URL + "/wechat/createOrder"
    
    public static let SET_BY_CURRENCY = BASE_URL + "/setting/setbycurrency"
    
    // added 2018-12-06
    public static let CREATE_QRCODE_PAYMENT = BASE_URL + "/qrcode/payment"
    public static let QRCODE_PAYMENT_SUCCESS = BASE_URL + "/qrcode/payment/ok"
    
    
    
    public static let OLD_BASE_URL = "http://116.62.226.8/index.php/interfaces"
    
    public static let OLD_IMAGE_URL = "http://paikepaifu.cn/public/"
    /**************************** Old Apis ***************************/
    
    public static let OLD_INDEX_INDEX = OLD_BASE_URL + "/index/index"
    
    
}







