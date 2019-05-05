//
//  NearbyStoreDetailProductCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NearbyStoreDetailProductCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
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
        if product.images != nil && product.images!.count >= 0 {
            let resizedUrlString = Utils.getResizedImageUrlString(product.images!.first!, width: "400")
            productImageView.setImageWithURLString(resizedUrlString, placeholderImage: ImageAsset.default_image.image)
        }
        nameLabel.text = product.name
        priceLabel.text = "¥ " + product.price!
        
        if product.paymentType! == 1 {
            //paiImageView.isHidden = false
            //yuanImageView.isHidden = true
            
            treasureLabel.isHidden = false
            periodLabel.isHidden = false
            
            var periodIndex = 0
            periodIndex = product.treasureRatio! - 1
            if periodIndex < 0 {
                periodIndex = 0
            }
            
            var restitutionRate: Double = 0
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.periodRatio != nil {
                restitutionRate = appDelegate.restitutionRate
            } else {
                restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
            }
            let periodDouble = Double(PAISHOP_PERIODS_TABLE[periodIndex])! * 135 / restitutionRate
            let roundedPeriod = round(periodDouble)
            let period = Int(roundedPeriod)
            periodLabel.text = "周期:\(period)"
            treasureLabel.text = "藏宝:" + String(product.treasureRatio!) + "%"
        } else {
            //paiImageView.isHidden = true
            //yuanImageView.isHidden = false
            
            treasureLabel.isHidden = true
            periodLabel.isHidden = true
        }
        
    }
    
}
