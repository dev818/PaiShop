
import Foundation
import SwiftyJSON

public struct CartModel {
    
    var id: Int64?
    var item: ProductDetailModel?
    var itemId: Int64?
    var count: Int?
    
    var checked = false
    
    init(_ json: JSON) {
        self.id = json["id"].int64Value
        self.item = ProductDetailModel.init(json["item"])
        self.itemId = json["item_id"].int64Value
        self.count = json["count"].intValue
    }
    
    static func getCartsFromJson(_ jsons: JSON) -> [CartModel] {
        var carts: [CartModel] = []
        for json in jsons.arrayValue {
            let cart = CartModel(json)
            carts.append(cart)
        }
        return carts
    }
    
    
}




