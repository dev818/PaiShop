

import Foundation
import SwiftyJSON

public struct ItemRecommendModel {
    var id: Int?
    var itemId: Int64?
    var profitRatio: Int?
    var name: String?
    var images: [String]?
    var currency: Int? //1: pi, 2: yen
    var price: String?
    
    init(_ json: JSON) {
        self.id = json["id"].intValue
        
        let itemJson = json["item"]
        self.itemId = itemJson["id"].int64Value
        self.profitRatio = itemJson["profit_ratio"].intValue
        self.name = itemJson["name"].stringValue
        self.images = Utils.parseStringToArray(itemJson["images"].stringValue)
        self.currency = itemJson["currency"].intValue
        self.price = itemJson["price"].stringValue
    }
    
    static func getItemRecommendsFromJson(_ jsons: JSON) -> [ItemRecommendModel] {
        var itemRecommends: [ItemRecommendModel] = []
        for json in jsons.arrayValue {
            let itemRecommend = ItemRecommendModel(json)
            itemRecommends.append(itemRecommend)
        }
        return itemRecommends
    }
    
}
