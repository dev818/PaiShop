

import UIKit
import SwiftyJSON

class ChatImageModel: NSObject {
    var imageHeight: CGFloat?
    var imageWidth: CGFloat?
    //var imageId: String?
    var imageUrl: String?
    var image: UIImage?
    
    override init() {
        super.init()
    }
    
    init(_ imageUrl: String, size: String) {
        super.init()
        
        self.imageHeight = kChatImageMaxHeight
        self.imageWidth = kChatImageMaxWidth
        self.imageUrl = imageUrl
        
        if !size.isEmpty {
            let json = JSON(parseJSON: size)
            let array: [CGFloat] = json.arrayObject as! [CGFloat]
            if array.count > 1 {
                self.imageWidth = array[0]
                self.imageHeight = array[1]
            }
        }
    }
    
    init(_ image: UIImage) {
        self.imageHeight = image.size.height
        self.imageWidth = image.size.width
        self.image = image
    }
    

}
