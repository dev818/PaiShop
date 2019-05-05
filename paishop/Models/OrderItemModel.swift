
import Foundation
import SwiftyJSON

public struct OrderItemModel {
    var product: ProductListModel
    var order: OrderModel
    
    init(product: ProductListModel, order: OrderModel) {
        self.product = product
        self.order = order
    }
    
}
