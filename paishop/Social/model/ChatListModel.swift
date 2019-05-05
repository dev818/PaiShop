

import UIKit
import ObjectMapper
import SwiftyJSON

class ChatListModel: NSObject {
    var name: String!
    var id: Int64!
    var updatedAt: String!
    var createdAt: String!
    var type: Int!
    var users: [UserModel]!
    var lastMessage: ChatMessageModel? //var messages: [ChatMessageModel]!
    var dateString: String!
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        self.name = json["name"].stringValue
        self.id = json["id"].int64Value
        self.updatedAt = json["updated_at"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.type = json["type"].intValue
        self.users = UserModel.getUsersFromJson(json["users"])        
        self.lastMessage = ChatMessageModel.init(json["last_message"])
        if (self.lastMessage?.id?.isEmpty)! {
            self.dateString = self.getFormattedDateString(self.updatedAt)
        } else {
            self.dateString = self.getFormattedDateString((self.lastMessage?.updatedAt)!)
        }
    }
    
    static func getChatListsFromJson(_ jsons: JSON) -> [ChatListModel] {
        var chatLists: [ChatListModel] = []
        for json in jsons.arrayValue {
            let chatList = ChatListModel(json)
            chatLists.append(chatList)
        }
        return chatLists
    }
    
    func getFormattedDateString(_ string: String) -> String {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dataFormatter.date(from: string)
        
        return Date.messageAgoSinceDate(date!)
    }
    
}






enum MessageContentType: Int {
    case Text = 1
    case Image = 2
    //case Voice = "2"
    //case System = "3"
    case Time =  110
}












