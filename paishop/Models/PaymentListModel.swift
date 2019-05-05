
import UIKit
import SwiftyJSON

class PaymentListModel: NSObject {
    var id: Int?
    var status: Int?
    var amount: String?
    var currency: Int? // 1- pai, 2 - CNY
    var type: Bool? // true - recharge, false - withdraw
    var createdAt: String?
    var updatedAt: String?
    var paymentPhone: String?
    var fee: String?
    var userId: Int?
    var contactPhone: String?
    var paymentAddress: String?
    
    var paymentDate: String?
    var paymentAmount: String?
    var paymentImage: String?
    
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["id"].intValue
        self.status = json["status"].intValue
        self.amount = json["amount"].stringValue
        self.currency = json["currency"].intValue
        self.type = json["type"].boolValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.paymentPhone = json["payment_phone"].stringValue
        self.fee = json["fee"].stringValue
        self.userId = json["user_id"].intValue
        self.contactPhone = json["contact_phone"].stringValue
        self.paymentAddress = json["payment_address"].stringValue
        
        //self.paymentDate = self.getRechargeDateString(self.updatedAt!)
        self.paymentDate = self.updatedAt!
        if currency == 1 {
            self.paymentAmount = amount! + "π"
        } else {
            self.paymentAmount = "¥" + amount!
        }
        self.paymentImage = json["image"].stringValue
        
    }
    
    func getRechargeDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: dateString)!
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: date)
    }
    
    static func getPaymentListsFromJson(_ jsons: JSON) -> [PaymentListModel] {
        var paymentLists: [PaymentListModel] = []
        for json in jsons.arrayValue {
            let paymentList = PaymentListModel(json)
            paymentLists.append(paymentList)
        }
        return paymentLists
    }

}
