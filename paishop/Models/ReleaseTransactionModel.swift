
import UIKit
import SwiftyJSON

class ReleaseTransactionModel: NSObject {
    
    var id: Int?
    var createdAt: String?
    var updatedAt: String?
    var releaseId: Int?
    var amount: String?
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.releaseId = json["restitution_id"].intValue
        self.amount = json["amount"].stringValue
    }
    
    static func getReleaseTransactionListFromJson(_ jsons: JSON) -> [ReleaseTransactionModel] {
        var releaseTransactionList: [ReleaseTransactionModel] = []
        for json in jsons.arrayValue {
            let releaseTransaction = ReleaseTransactionModel(json)
            releaseTransactionList.append(releaseTransaction)
        }
        return releaseTransactionList
    }

}
