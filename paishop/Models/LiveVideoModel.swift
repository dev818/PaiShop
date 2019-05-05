
import UIKit
import SwiftyJSON

public struct LiveVideoModel {
    
    var id: String?//Int64?
    var streamName: String?
    var expiresAt: String?
    var createdAt: String?
    var appName: String?
    var title: String?
    var bucket: String?
    var active: Bool? // true(in live post)
    var type: Bool? 
    var count: Int?
    var image: String?
    var storeId: Int64?
    var views: Int?
    var store: StoreDetailModel?
    var forbidden: Bool?
    var duration: Int?
    var live: Bool?
    
    
    init(_ json: JSON) {
        self.id = json["id"].stringValue//int64Value
        self.streamName = json["stream_name"].stringValue
        self.expiresAt = json["expires_at"].stringValue
        self.createdAt = json["created_at"].stringValue
        self.appName = json["app_name"].stringValue
        self.title = json["title"].stringValue
        self.bucket = json["bucket"].stringValue
        self.active = json["active"].boolValue
        self.type = json["type"].boolValue
        self.count = json["count"].intValue
        self.image = json["image"].stringValue
        self.storeId = json["store_id"].int64Value
        self.views = json["views"].intValue
        self.store = StoreDetailModel.init(json["store"])
        self.forbidden = json["forbidden"].boolValue
        self.duration = json["duration"].intValue
        self.live = json["live"].boolValue
    }
    
    static func getLiveVideosFromJson(_ jsons: JSON) -> [LiveVideoModel] {
        var liveVideos: [LiveVideoModel] = []
        for json in jsons.arrayValue {
            let liveVideo = LiveVideoModel(json)
            liveVideos.append(liveVideo)
        }
        return liveVideos
    }
    
}
