

import UIKit
import SwiftyJSON



public struct StoreDetailModel {
    
    var storeId: Int64?
    var image: String?
    var address: String?
    var alipayAddress: String?
    var name: String?
    var createdAt: String?
    var opening: String?
    var user: UserModel?
    var city: CityModel?
    var updatedAt: String?
    var category: CategoryModel?
    var introduction: String?
    var phoneNumber: String?
    
    var status: Int?
    var license: String?
    var images: [String]?
    var views: Int?
    var favorites: Int?
    var lat: Double?
    var lng: Double?
    var offline: Bool?
    var business: Bool?
    
    init(_ json: JSON) {
        self.storeId = json["id"].int64
        self.image = json["image"].stringValue
        self.address = json["address"].stringValue
        self.name = json["name"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.opening = json["opening"].stringValue
        self.user = UserModel.init(json["user"])
        self.city = CityModel.init(json["city"])
        self.updatedAt = json["updated_at"].stringValue
        self.lat = json["lat"].doubleValue
        self.lng = json["lng"].doubleValue
        self.category = CategoryModel.init(json["category"])
        self.introduction = json["introduction"].stringValue
        self.phoneNumber = json["phone_number"].stringValue
        self.status = json["status"].intValue
        self.license = json["license"].stringValue
        self.views = json["views"].intValue
        self.favorites = json["favorites"].arrayValue.count
        self.offline = json["offline"].boolValue
        self.business = json["business"].boolValue
        self.alipayAddress = json["alipay_address"].stringValue
        
        if let imagesString = json["images"].string, !imagesString.isEmpty {
            if imagesString != "null" {
                self.images = Utils.parseStringToArray(imagesString)
            }            
        }        
        
        // For Store Location API
        if (self.name?.isEmpty)! {
            let storeJson = json["store"]
            self.storeId = storeJson["id"].int64
            self.image = storeJson["image"].stringValue
            self.address = storeJson["address"].stringValue
            self.name = storeJson["name"].stringValue
            self.city = CityModel.init(storeJson["city"])
            self.status = storeJson["status"].intValue
            self.views = storeJson["views"].intValue
            self.opening = storeJson["opening"].stringValue
            self.user = UserModel.init(storeJson["user"])
            self.category = CategoryModel.init(storeJson["category"])
            self.introduction = storeJson["introduction"].stringValue
        }
    }
    
    static func getStoreDetailsFromJson(_ jsons: JSON) -> [StoreDetailModel] {
        var storeDetails: [StoreDetailModel] = []
        for json in jsons.arrayValue {
            let storeDetail = StoreDetailModel(json)
            storeDetails.append(storeDetail)
        }
        return storeDetails
    }
    
    
}




