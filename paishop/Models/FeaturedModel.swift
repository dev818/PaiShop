

import Foundation
import SwiftyJSON

public struct FeaturedModel {
    var reportCount: Int64?
    var favoriteCount: Int64?
    var likeCount: Int64?
    var commentCount: Int64?
    var viewCount: Int64?
    
    var id: Int64?
    var userId: Int64?

    var text: String?

    var like: [JSON]?
    var report: [JSON]?
    var comment: [JSON]?
    var images: NSArray?

    var user: UserModel?
    
    var updatedAt: String?
    var createdAt: String?
    var deletedAt: String?
    
    init(_ json: JSON) {
        self.reportCount = json["report_count"].int64Value
        self.favoriteCount = json["favorite_count"].int64Value
        self.likeCount = json["like_count"].int64Value
        self.commentCount = json["comment_count"].int64Value
        self.viewCount = json["views"].int64Value
        self.id = json["id"].int64Value
        self.userId = json["user_id"].int64Value
        self.text = json["text"].stringValue
        self.like = json["like"].arrayValue
        self.report = json["report"].arrayValue
        self.comment = json["comment"].arrayValue
        self.images = json["images"].arrayValue as NSArray
        
        self.user = UserModel.init(json["user"])
        self.createdAt = json["created_at"].stringValue
        self.updatedAt = json["updated_at"].stringValue
        self.deletedAt = json["updated_at"].stringValue
    }
    
    static func getFeaturedsFromJson(_ jsons: JSON) -> [FeaturedModel] {
        var featureds: [FeaturedModel] = []
        for json in jsons.arrayValue {
            let featured = FeaturedModel.init(json)
            featureds.append(featured)
        }
        return featureds
    }
    
}
