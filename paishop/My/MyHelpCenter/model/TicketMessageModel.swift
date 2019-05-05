
import UIKit
import SwiftyJSON
import YYText

class TicketMessageModel: NSObject {
    var id: String?
    var ticketId: Int?
    var createdAt: String?
    var updatedAt: String?
    var ticketClass: Int?
    var message: String?
    var type: Int?
    
    var messageContentType: TicketMessageContentType = .Text
    var fromMe: Bool = true
    var cellHeight: CGFloat = 0 // Calculated Cell Height
    var richTextLayout: YYTextLayout?
    var richTextLinePositionModifier: MyYYTextLinePositionModifier?
    var richTextAttributedString: NSMutableAttributedString?
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["_id"].stringValue
        self.ticketId = json["ticket_id"].intValue
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.ticketClass = json["class"].intValue
        self.message = json["message"].stringValue
        self.type = json["type"].intValue
        
        if self.ticketClass == 1 {
            self.fromMe = true
        } else {
            self.fromMe = false
        }
    }
    
    init(text: String) {
        super.init()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        self.createdAt = dateFormatter.string(from: Date())
        self.updatedAt = dateFormatter.string(from: Date())
        self.message = text
        self.fromMe = true
        self.messageContentType = .Text
    }
    
    init(updatedAt: String) {
        super.init()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: updatedAt)!
        self.message = date.chatTimeString
        self.messageContentType = .Time
    }
    
    static func getTicketMessagesFromJson(_ jsons: JSON) -> [TicketMessageModel] {
        var ticketMessages: [TicketMessageModel] = []
        for json in jsons.arrayValue {
            let ticketMessage = TicketMessageModel(json)
            ticketMessages.append(ticketMessage)
        }
        return ticketMessages
    }
    
    func isLateForFiveMinutes(_ targetModel: TicketMessageModel) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let nextDate = dateFormatter.date(from: self.updatedAt!)!
        let nextSeconds = Int(nextDate.timeIntervalSince1970)
        let prevDate = dateFormatter.date(from: targetModel.updatedAt!)!
        let prevSeconds = Int(prevDate.timeIntervalSince1970)
        
        return (nextSeconds - prevSeconds) > 60 * 2 // 2 min
    }

}




enum TicketMessageContentType: Int {
    case Text = 1
    
    case Time = 100
}
