
import UIKit
import SwiftyJSON

public struct CategoryModel {
    
    var id: Int64?
    var name: String?
    var parent: Int64?
    var imageURL: String?
    
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.name = json["name"].stringValue
        self.parent = json["parent"].int64Value
        self.imageURL = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
    }
    
    static func getCategoriesFromJson(_ jsons: JSON) -> [CategoryModel] {
        var categories: [CategoryModel] = []
        for json in jsons.arrayValue {
            let category = CategoryModel(json)
            categories.append(category)
        }
        return categories
    }
    
}
