//
//  FeaturedPostImageCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FeaturedPostImageCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    
    var parentVC: FeaturedPostVC!
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ customImage: CustomImageModel, index: Int, vc: FeaturedPostVC) {
        self.index = index
        self.parentVC = vc
        if customImage.isImage {
            postImageView.image = customImage.image
        } else {
            postImageView.setImageWithURLString(customImage.imageURL!, placeholderImage: ImageAsset.default_image.image)
        }
        
        let imageWidth: Int = Int(UIScreen.ts_width) - 32 - 40
        var imageHeight = imageWidth * 2 / 3
        if customImage.isImage {
            if let image = customImage.image {
                let width = Int(image.size.width)
                let height = Int(image.size.height)
                if width > 0 && height > 0 {
                    imageHeight = height * imageWidth / width
                }
            }
        } else {
            if let imageUrl = customImage.imageURL {
                let sizeOfWH = Utils.getImageSizeFromUrl(imageUrl)
                let width = sizeOfWH[0]
                let height = sizeOfWH[1]
                
                if width > 0 && height > 0 {
                    imageHeight = height * imageWidth / width
                }
            }
        }
        
        imageHeightConstraint.constant = CGFloat(imageHeight)
        
    }
    
    @IBAction func selectDelete(_ sender: Any) {
        if !parentVC.customImageArray[index].isImage {
            parentVC.deletedImages.append(parentVC.customImageArray[index].imageURL!)
        }
        parentVC.customImageArray.remove(at: index)
        
        parentVC.updateTableViewHeight()
    }
    
}
