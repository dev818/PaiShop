
import UIKit
import SwiftyJSON

class DeliveryModel: NSObject {
    
    var id: Int?
    var position: String?
    var fare: Int?
    var receipt: String?
    var company: String?
    var createdAt: String?
    var updatedAt: String?
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["id"].intValue
        self.position = json["position"].stringValue
        self.fare = json["fare"].intValue
        self.receipt = json["receipt"].stringValue
        self.company = json["company"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
    }

}
