
import Foundation
import SwiftyJSON


public struct CommentModel {
    var id: String?
    var text: String?
    var userId: Int64?
    var rate: Int?
    var createdAt: String?
    var user: UserModel?
    
    init(_ json: JSON) {
        self.id = json["_id"].stringValue
        self.text = json["text"].stringValue
        self.userId = json["user_id"].int64Value
        self.rate = json["rate"].intValue
        self.createdAt = json["created_at"].stringValue
        self.user = UserModel.init(json["user"])
    }
    
    static func getCommentsFromJson(_ jsons: JSON) -> [CommentModel] {
        var comments: [CommentModel] = []
        for json in jsons.arrayValue {
            let comment = CommentModel(json)
            comments.append(comment)
        }
        return comments
    }
    
    
}





