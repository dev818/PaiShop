
import Foundation
import SwiftyJSON

public struct RestitutionModel {
    
    var id: Int64?
    var period: String?
    var sellderRestitution: String?
    var buyerRestitution: String?
    var orderId: Int64?
    var expectedAt: String?
    var price: String?
    var count: Int?
    
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.period = json["period"].stringValue
        self.sellderRestitution = json["seller_restitution"].stringValue
        self.buyerRestitution = json["buyer_restitution"].stringValue
        self.orderId = json["orderId"].int64Value
        self.expectedAt = json["expect_at"].stringValue
        self.price = json["price"].stringValue
        self.count = json["count"].intValue
    }    
    
}
