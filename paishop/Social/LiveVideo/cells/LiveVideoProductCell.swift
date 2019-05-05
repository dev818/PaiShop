//
//  LiveVideoProductCell.swift
//  paishop
//
//  Created by SeniorCorder on 4/30/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LiveVideoProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var yuanImageView: UIImageView! {
        didSet {
            yuanImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    @IBOutlet weak var paiImageView: UIImageView! {
        didSet {
            paiImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    @IBOutlet weak var treasureRatioLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(_ storeItem: ProductListModel) {
        if storeItem.images != nil && storeItem.images!.count >= 0 {
            let resizedUrlString = Utils.getResizedImageUrlString(storeItem.images!.first!, width: "400")
            productImageView.setImageWithURLString(resizedUrlString, placeholderImage: ImageAsset.default_image.image)
        }
        
        nameLabel.text = storeItem.name
        priceLabel.text = "¥ " + storeItem.price!
        
        if storeItem.paymentType! == 1 {
            paiImageView.isHidden = false
            yuanImageView.isHidden = true
            
            treasureRatioLabel.isHidden = false
            periodLabel.isHidden = false
            
            var periodIndex = 0
            periodIndex = storeItem.treasureRatio! - 1
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
            treasureRatioLabel.text = "藏宝:" + String(storeItem.treasureRatio!) + "%"
        } else {
            paiImageView.isHidden = true
            yuanImageView.isHidden = false
            
            treasureRatioLabel.isHidden = true
            periodLabel.isHidden = true
        } 
        
    }
    
}
