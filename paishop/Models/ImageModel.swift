

import Foundation
import SwiftyJSON

public struct ImageModel {
    var type: Int64?
    var url: String?

    init(_ json: JSON) {
        self.type = json["type"].int64Value
        self.url = json["url"].stringValue
    }
    
    static func getImagesFromJson(_ jsons: JSON) -> [ImageModel] {
        var images: [ImageModel] = []
        for json in jsons.arrayValue {
            let image = ImageModel.init(json)
            images.append(image)
        }
        return images
    }
    
}
