
import Foundation
import SwiftyJSON

public struct LiveChatModel {
    var id: String?
    var message: String?
    var createdAt: String?
    var videoId: String?//Int64?
    var user: UserModel?
    
    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.message = json["message"].stringValue
        self.createdAt = json["createdAt"].stringValue
        self.videoId = json["video_id"].stringValue//int64Value
        self.user = UserModel.init(json["user"])
    }
    
    static func getLiveChatsFromJson(_ jsons: JSON) -> [LiveChatModel] {
        var liveChats: [LiveChatModel] = []
        for json in jsons.arrayValue {
            let liveChat = LiveChatModel(json)
            liveChats.append(liveChat)
        }
        return liveChats
    }
    
}
