
import Foundation
import SwiftyJSON


public struct TicketListModel {
    
    var  id: Int
    var content: String
    var userId: Int
    var status: Int // 0 - finished, 1 - answered, 2 - waiting answer...
    var createdAt: String
    var updatedAt: String
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        self.content = json["content"].stringValue
        self.userId = json["user_id"].intValue
        self.status = json["status"].intValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
    }
    
    
    static func getTicketListsFromJson(_ jsons: JSON) -> [TicketListModel] {
        var ticketLists: [TicketListModel] = []
        for json in jsons.arrayValue {
            let ticketList = TicketListModel(json)
            ticketLists.append(ticketList)
        }
        return ticketLists
    }
    
}






