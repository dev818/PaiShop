//
//  MyVCRecommendCollectionCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/6/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class MyVCRecommendCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ item: ItemRecommendModel) {
        if (item.images?.count)! > 0 {
            
            self.itemImageView.sd_setShowActivityIndicatorView(true)
            self.itemImageView.sd_setIndicatorStyle(.gray)
            if let itemUrl = item.images?.first, itemUrl != "" {
                let resizedItemUrl = Utils.getResizedImageUrlString(itemUrl, width: "400")
                self.itemImageView.sd_setImage(with: URL(string: resizedItemUrl), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            } else {
                self.itemImageView.sd_setImage(with: URL(string: (item.images?.first)!), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        
        itemDescriptionLabel.text = item.name
    }

}
