
import UIKit
import SwiftyJSON

class ReleaseModel: NSObject {
    
    var id: Int?
    var buyerRestitution: String?
    var sellerRestitution: String?
    var orderId: Int?
    var releaseCount: Int?
    var expectAt: String?
    var createdAt: String?
    var updatedAt: String?
    var releasePeriod: Int?
    var paiPrice: String?
    
    var images: [String]?
    var productId: Int?
    var productName: String?
    
    var treasureRatio: Int?
    var orderCreatedAt: String?
    var orderUpdatedAt: String?
    var price: String?
    var count: Int?
    var status: Int?
    var address: String?
    var userName: String?
    var currency: Int?
    var fare: Int?
    var phoneNumber: String?
    
    var activityId: Int?
    var activityContent: String?
    //var activityType: Int?
    var activityDegreeId: Int?
    var activityCreatedAt: String?
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["id"].intValue
        self.buyerRestitution = json["buyer_restitution"].stringValue
        self.sellerRestitution = json["seller_restitution"].stringValue
        self.orderId = json["order_id"].intValue
        self.releaseCount = json["count"].intValue
        self.expectAt = json["expect_at"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.releasePeriod = json["period"].intValue
        self.paiPrice = json["price"].stringValue
        
        self.activityId = json["activity_id"].intValue
        
        if activityId! > 0 {
            let activityJson = json["activity"]
            self.activityContent = activityJson["content"].stringValue
            self.activityDegreeId = activityJson["degree_id"].intValue
            self.activityCreatedAt = activityJson["created_at"].stringValue
        } else {
            let orderJson = json["order"]
            let itemJson = orderJson["item"]
            self.productId = itemJson["id"].intValue
            self.images = Utils.parseStringToArray(itemJson["images"].stringValue)
            self.productName = itemJson["name"].stringValue
            
            self.treasureRatio = orderJson["profit_ratio"].intValue
            self.orderCreatedAt = orderJson["created_at"].stringValue
            self.orderUpdatedAt = orderJson["updated_at"].stringValue
            self.price = orderJson["price"].stringValue
            self.count = orderJson["count"].intValue
            self.status = orderJson["status"].intValue
            self.address = orderJson["address"].stringValue
            self.userName = orderJson["user_name"].stringValue
            self.currency = orderJson["currency"].intValue
            self.fare = orderJson["fare"].intValue
            self.phoneNumber = orderJson["phone_number"].stringValue
        }
    }
    
    static func getReleaseListFromJson(_ jsons: JSON) -> [ReleaseModel] {
        var releaseList: [ReleaseModel] = []
        for json in jsons.arrayValue {
            let release = ReleaseModel(json)
            releaseList.append(release)
        }
        return releaseList
    }
    
    
}








