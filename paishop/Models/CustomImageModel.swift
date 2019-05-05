//
//  CustomImageModel.swift
//  paishop
//
//  Created by Mac on 2/3/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class CustomImageModel: NSObject {
    var imageURL: String?
    var image: UIImage?
    var isImage: Bool!
    
    init(imageURL: String?, image: UIImage?, isImage: Bool) {
        super.init()
        self.imageURL = imageURL
        self.image = image
        self.isImage = isImage
    }
}
