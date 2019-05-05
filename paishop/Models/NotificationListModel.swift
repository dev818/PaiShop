
import UIKit
import SwiftyJSON

class NotificationListModel: NSObject {
    
    var id: Int?
    var link: String?
    var message: String?
    var imageUrl: String?
    var createdAt: String?
    var updatedAt: String?
    var type: Bool?
    
    var itemId: Int64?
    var storeId: Int64?
    var siteUrl: String?
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["id"].intValue
        self.link = json["link"].stringValue
        self.message = json["message"].stringValue
        self.imageUrl = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.type = json["type"].boolValue
        
        let str = self.link!
        if str == "" {
            return
        }
        if str.range(of: "item") != nil {
            let elements = str.split(separator: "/")
            itemId = Int64(elements.last!)
        } else if str.range(of: "store") != nil {
            let elements = str.split(separator: "/")
            storeId = Int64(elements.last!)
        } else if str.range(of: "http") != nil {
            siteUrl = str
        } else if str.range(of: "https") != nil {
            siteUrl = str
        }
        
    }
    
    static func getNotificationListsFromJson(_ jsons: JSON) -> [NotificationListModel] {
        var notificationLists: [NotificationListModel] = []
        for json in jsons.arrayValue {
            let notificationList = NotificationListModel.init(json)
            notificationLists.append(notificationList)
        }
        return notificationLists
    }
    
    
}
