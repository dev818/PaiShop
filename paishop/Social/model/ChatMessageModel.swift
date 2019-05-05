

import UIKit
import SwiftyJSON
import YYText

class ChatMessageModel: NSObject {
    var id: String?
    var roomId: Int64?
    var updatedAt: String?
    var createdAt: String?
    var message: String?
    var type: Int? = 1
    var user: UserModel?
    var fromMe: Bool = true //{ return self.user?.id ==  UserInstance.userId }
    var richTextLayout: YYTextLayout?
    var richTextLinePositionModifier: MyYYTextLinePositionModifier?
    var richTextAttributedString: NSMutableAttributedString?
    var messageSendSuccessType: MessageSendSuccessType = .failed // Message Sent Status
    var cellHeight: CGFloat = 0 // Calculated Cell Height
    var messageContentType: MessageContentType = .Text
    
    var imageModel: ChatImageModel?
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        self.id = json["id"].stringValue
        self.roomId = json["room_id"].int64Value
        self.updatedAt = json["updated_at"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.message = json["message"].stringValue
        self.type = json["type"].intValue
        self.user = UserModel(json["user"])
        self.fromMe = (self.user?.id ==  UserInstance.userId)
        if self.type! > 0 {
            self.messageContentType = MessageContentType(rawValue: self.type!)!
        }
        
        if self.messageContentType == .Image {
            let size = json["size"].stringValue
            self.imageModel = ChatImageModel.init(self.message!, size: size)//ChatImageModel.init(API.IMAGE_URL + self.message!, size: size)
        }
        
    }
    
    init(text: String) {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        self.createdAt = dateFormatter.string(from: Date())
        self.updatedAt = dateFormatter.string(from: Date())
        self.message = text
        self.type = 1
        self.fromMe = true
        self.messageContentType = .Text
    }
    
    init(imageModel: ChatImageModel) {
        super.init()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        self.createdAt = dateFormatter.string(from: Date())
        self.updatedAt = dateFormatter.string(from: Date())
        self.type = MessageContentType.Image.rawValue
        self.messageContentType = .Image
        self.fromMe = true
        self.imageModel = imageModel
    }
    
    init(updatedAt: String) {
        super.init()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: updatedAt)!
        self.message = date.chatTimeString
        self.messageContentType = .Time
    }
    
    static func getChatMessagesFromJson(_ jsons: JSON) -> [ChatMessageModel] {
        var chatMessages: [ChatMessageModel] = []
        for json in jsons.arrayValue {
            let chatMessage = ChatMessageModel(json)
            chatMessages.append(chatMessage)
        }
        
        return chatMessages
    }
    
    func isLateForTwoMinutes(_ targetModel: ChatMessageModel) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nextDate = dateFormatter.date(from: self.updatedAt!)!
        let nextSeconds = Int(nextDate.timeIntervalSince1970)
        let prevDate = dateFormatter.date(from: targetModel.updatedAt!)!
        let prevSeconds = Int(prevDate.timeIntervalSince1970)
        
        return (nextSeconds - prevSeconds) > 60 * 5 // 5 min
    }
    
    

}



enum MessageSendSuccessType: Int {
    case success = 0
    case failed
    case sending
}











