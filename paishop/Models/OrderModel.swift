
import Foundation
import SwiftyJSON

public struct OrderModel {
    var id: Int64?
    var phoneNumber: String?
    var status: Int? // 0: rejected, 1: completed, 2: pending, 3: delivering
    var address: String?
    var createdAt: String?
    var updatedAt: String?
    var userName: String?
    var count: Int?
    var fare: Int?
    var delivery: DeliveryModel?
    var image: String? // transaction Image
    var price: String?
    var salePrice: String?
    var profitRatio: Int?
    var currency: Int?
    var restitution: RestitutionModel?
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.phoneNumber = json["phone_number"].stringValue
        self.status = json["status"].intValue
        self.address = json["address"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.userName = json["user_name"].stringValue
        self.count = json["count"].intValue
        self.fare = json["fare"].intValue
        self.delivery = DeliveryModel.init(json["delivery"])
        self.image = json["image"].stringValue
        self.price = json["price"].stringValue
        self.salePrice = json["sale_price"].stringValue
        self.profitRatio = json["profit_ratio"].intValue
        self.currency = json["currency"].intValue
        
        self.restitution = RestitutionModel.init(json["restitution"])
        
    }
    
    static func getOrdersFromJson(_ jsons: JSON) -> [OrderModel] {
        var orders: [OrderModel] = []
        for json in jsons.arrayValue {
            let order = OrderModel(json)
            orders.append(order)
        }
        return orders
    }
    
}





