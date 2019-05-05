//
//  ShowSimilarProductCell.swift
//  paishop
//
//  Created by Admin on 8/9/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class ShowSimilarProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!    
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var treasureLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ product: ProductListModel) {
        if (product.images?.count)! > 0 {
            self.productImageView.sd_setShowActivityIndicatorView(true)
            self.productImageView.sd_setIndicatorStyle(.gray)
            
            if let productUrl = product.images?.first, productUrl != "" {
                let resizedProductUrl = Utils.getResizedImageUrlString(productUrl, width: "400")
                self.productImageView.sd_setImage(with: URL(string: resizedProductUrl), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        
        productNameLabel.text = product.name
        productPriceLabel.text = "¥ " + product.price!
        treasureLabel.text = "藏宝:\(product.treasureRatio!)%"
        
        var restitutionRate: Double = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.periodRatio != nil {
            restitutionRate = appDelegate.restitutionRate
        } else {
            restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        var periodIndex = 0
        periodIndex = product.treasureRatio! - 1
        if periodIndex < 0 {
            periodIndex = 0
        }
        let periodDouble = Double(PAISHOP_PERIODS_TABLE[periodIndex])! * 135 / restitutionRate
        let roundedPeriod = round(periodDouble)
        let period = Int(roundedPeriod)
        self.periodLabel.text = "周期:\(period)"
    }

    
}
