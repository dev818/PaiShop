

import Foundation
import SwiftyJSON

public struct StoreRecommendModel {
    var id: Int?
    var storeId: Int64?
    var name: String?
    var opening: String?
    var image: String?
    var address: String?
    var user: UserModel?
    var category: CategoryModel?
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        
        let storeJson = json["store"]
        self.storeId = storeJson["id"].int64Value
        self.name = storeJson["name"].stringValue
        self.opening = storeJson["opening"].stringValue
        self.image = storeJson["image"].stringValue
        self.address = storeJson["address"].stringValue
        self.user = UserModel.init(storeJson["user"])
        self.category = CategoryModel.init(storeJson["category"])
    }
    
    static func getStoreRecommendsFromJson(_ jsons: JSON) -> [StoreRecommendModel] {
        var storeRecommends: [StoreRecommendModel] = []
        for json in jsons.arrayValue {
            let storeRecommend = StoreRecommendModel(json)
            storeRecommends.append(storeRecommend)
        }
        return storeRecommends
    }
    
}
