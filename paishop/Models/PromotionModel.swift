
import UIKit
import SwiftyJSON

class PromotionModel: NSObject {
    
    var id: Int?
    var image: String?
    var link: String?
    
    var itemId: Int64?
    var storeId: Int64?
    var siteUrl: String?
    
    init(_ json: JSON) {
        super.init()
        
        self.id = json["id"].intValue
        self.image = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
        self.link = json["link"].stringValue
        
        /*if let link = self.link, !link.isEmpty {
            let elements = link.split(separator: "/")
            if elements.count > 1 {
                self.itemId = Int64(elements.last!)
            }            
        }*/
        let str = self.link!
        if str == "" {
            return
        }
        if str.range(of: "item") != nil {
            let elements = str.split(separator: "/")
            itemId = Int64(elements.last!)
        } else if str.range(of: "store") != nil {
            let elements = str.split(separator: "/")
            storeId = Int64(elements.last!)
        } else if str.range(of: "http") != nil {
            siteUrl = str
        } else if str.range(of: "https") != nil {
            siteUrl = str
        }
    }
    
    static func getPromotionsFromJson(_ jsons: JSON) -> [PromotionModel] {
        var promotions: [PromotionModel] = []
        for json in jsons.arrayValue {
            let promotion = PromotionModel.init(json)
            promotions.append(promotion)
        }
        return promotions
    }

}
