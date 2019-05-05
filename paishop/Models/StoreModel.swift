
import UIKit
import SwiftyJSON


public struct StoreModel {
    
    var storeId: Int64?
    var image: String?
    var address: String?
    var name: String?
    var createdAt: String?
    var opening: String?
    var userId: Int64?
    var cityId: Int64?
    var phoneNumber: String?
    var status: Int?
    var introduction: String?
    var favorites: Int?
    var lat: Double?
    var lng: Double?
    var offline: Bool?
    var business: Bool?
    
    
    var checked = false
    
    
    init(_ json: JSON) {
        self.storeId = json["id"].int64Value
        self.image = json["image"].stringValue
        self.address = json["address"].stringValue
        self.name = json["name"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.opening = json["opening"].stringValue
        self.userId = json["user_id"].int64Value
        self.cityId = json["city_id"].int64Value
        self.lat = json["lat"].doubleValue
        self.lng = json["lng"].doubleValue
        self.phoneNumber = json["phone_number"].stringValue
        self.status = json["status"].intValue
        self.introduction = json["introduction"].stringValue
        self.favorites = json["favorites"].arrayValue.count
        self.offline = json["offline"].boolValue
        self.business = json["business"].boolValue
    }
    
    static func getStoresFromJson(_ jsons: JSON) -> [StoreModel] {
        var stores: [StoreModel] = []
        for json in jsons.arrayValue {
            let store = StoreModel(json)
            stores.append(store)
        }
        return stores
    }
    
    
}











