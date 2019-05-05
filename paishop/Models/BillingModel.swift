

import UIKit
import SwiftyJSON

class BillingModel: NSObject {
    
    var id: Int?
    var amount: String?
    var comment: String?
    var createdAt: String?
    var currency: Int?
    var fee: String?
    var orderId: Int?
    var status: Int?
    var type: Bool?
    var updatedAt: String?
    var userId: Int?
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["id"].intValue
        self.amount = json["amount"].stringValue
        self.comment = json["comment"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.currency = json["currency"].intValue
        self.fee = json["fee"].stringValue
        self.orderId = json["order_id"].intValue
        self.status = json["status"].intValue
        self.type = json["type"].boolValue
        self.updatedAt = json["updated_at"].stringValue
        self.userId = json["user_id"].intValue
    }
    
    static func getBillingsFromJson(_ jsons: JSON) -> [BillingModel] {
        var billings: [BillingModel] = []
        for json in jsons.arrayValue {
            let billing = BillingModel.init(json)
            billings.append(billing)
        }
        return billings
    }

}
