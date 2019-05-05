

import UIKit
import SwiftyJSON


public struct ProductDetailModel {
    
    var id: Int64?
    var description: String?
    var sales: Int?
    var createdAt: String?
    var updatedAt: String?
    var images: [String]?
    var price: String?
    var favoritesCount: Int?
    var category: CategoryModel?
    var user: UserModel?
    var name: String?
    var amount: Int?
    var views: Int?
    var city: CityModel?
    var commentsCount: Int?
    var store: StoreModel?
    var expiresAt: String?
    var treasureRatio: Int?
    var favorites: Int? // 0 -no like from me, 1~ - like from me
    var paymentType: Int? //1: pi, 2: yen, 3: pi + yen
    var status: Int? //0 - rejected, 1 - active, 2 - pending
    var active: Bool? // true - active, false - inactive
    var qrimage: String?    
    var deliveryOnOff: Bool?
    var refundOnOff: Bool?
    var refundInWeek: Bool?
    var propertyAll: Bool?
    var propertyRecent: Bool?
    var propertyActive: Bool?
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.description = json["description"].stringValue
        self.sales = json["sales"].intValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.images = Utils.parseStringToArray(json["images"].stringValue)
        self.price = json["price"].stringValue
        self.favoritesCount = json["favorites_count"].intValue
        self.category = CategoryModel.init(json["category"])
        self.user = UserModel.init(json["user"])
        self.name = json["name"].stringValue
        self.amount = json["amount"].intValue
        self.views = json["views"].intValue
        self.city = CityModel.init(json["city"])
        self.commentsCount = json["comments_count"].intValue
        self.store = StoreModel.init(json["store"])
        self.expiresAt = json["expires_at"].stringValue
        self.treasureRatio = json["profit_ratio"].intValue
        self.favorites = json["favorites"].arrayValue.count
        self.paymentType = json["currency"].intValue
        self.status = json["status"].intValue
        self.active = json["active"].boolValue
        self.qrimage = json["qrimage"].stringValue
        self.deliveryOnOff = json["delivery_on_off"].boolValue
        self.refundOnOff = json["refund_on_off"].boolValue
        self.refundInWeek = json["refund_in_week"].boolValue
        self.propertyAll = json["property_all"].boolValue
        self.propertyRecent = json["property_recent"].boolValue
        self.propertyActive = json["property_active"].boolValue

    }
    
    
    
}











