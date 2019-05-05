//
//  HomeProductDetailHeaderCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class HomeStoreDetailHeaderCell: UITableViewCell {
    
    @IBOutlet weak var cellTitleButton: RoundButton!
    @IBOutlet weak var product1Frame: RoundRectView!
    @IBOutlet weak var product2Frame: RoundRectView!
    
    @IBOutlet weak var product1ImageView: UIImageView!
    @IBOutlet weak var product1NameLabel: UILabel!
    @IBOutlet weak var product1PriceLabel: UILabel!
    @IBOutlet weak var product1TreasureLabel: UILabel!
    @IBOutlet weak var product1PeriodLabel: UILabel!
    
    @IBOutlet weak var product2ImageView: UIImageView!
    @IBOutlet weak var product2NameLabel: UILabel!
    @IBOutlet weak var product2PriceLabel: UILabel!
    @IBOutlet weak var product2TreasureLabel: UILabel!
    @IBOutlet weak var product2PeriodLabel: UILabel!
    
    @IBOutlet weak var imageView1Constraint: NSLayoutConstraint!
    @IBOutlet weak var imageView2Constraint: NSLayoutConstraint!
    
    var parentVC: HomeStoreDetailVC!
    var product1: ProductListModel!
    var product2: ProductListModel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCellContent(_ vc: HomeStoreDetailVC, indexPath: IndexPath) {
        
        var restitutionRate: Double = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.periodRatio != nil {
            restitutionRate = appDelegate.restitutionRate
        } else {
            restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        self.parentVC = vc
        
        if indexPath.section == 1 {
            cellTitleButton.backgroundColor = UIColor.init(colorWithHexValue: 0xf825b5)
            cellTitleButton.setTitle("店铺热卖", for: .normal)
        } else {
            cellTitleButton.backgroundColor = UIColor.init(colorWithHexValue: 0xd744f6)
            cellTitleButton.setTitle("所有商品", for: .normal)
        }
        
        // product 1 setting...
        if indexPath.section == 1 {
            product1 = parentVC.storeBestItems[indexPath.row * 2]
        } else {
            product1 = parentVC.storeItems[indexPath.row * 2]
        }
        
        if (product1.images?.count)! > 0 {
            self.product1ImageView.sd_setShowActivityIndicatorView(true)
            self.product1ImageView.sd_setIndicatorStyle(.gray)
            
            if let product1Url = product1.images?.first, product1Url != "" {
                let resizedProduct1Url = Utils.getResizedImageUrlString(product1Url, width: "400")
                self.product1ImageView.sd_setImage(with: URL(string: resizedProduct1Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        
        product1NameLabel.text = product1.name
        product1PriceLabel.text = "¥ " + product1.price!
        product1TreasureLabel.text = "藏宝:\(product1.treasureRatio!)%"
        
        var periodIndex1 = 0
        periodIndex1 = product1.treasureRatio! - 1
        if periodIndex1 < 0 {
            periodIndex1 = 0
        }
        let periodDouble1 = Double(PAISHOP_PERIODS_TABLE[periodIndex1])! * 135 / restitutionRate
        let roundedPeriod1 = round(periodDouble1)
        let period1 = Int(roundedPeriod1)
        self.product1PeriodLabel.text = "周期:\(period1)"
        
        //product2 setting...
        if indexPath.section == 1 {
            if parentVC.storeBestItems.count < (indexPath.row + 1) * 2 {
                product2Frame.isHidden = true
                return
            }
            product2 = parentVC.storeBestItems[indexPath.row * 2 + 1]
            product2Frame.isHidden = false
        } else {
            if parentVC.storeItems.count < (indexPath.row + 1) * 2 {
                product2Frame.isHidden = true
                return
            }
            product2 = parentVC.storeItems[indexPath.row * 2 + 1]
            product2Frame.isHidden = false
        }
        
        if (product2.images?.count)! > 0 {
            self.product2ImageView.sd_setShowActivityIndicatorView(true)
            self.product2ImageView.sd_setIndicatorStyle(.gray)
            
            if let product2Url = product2.images?.first, product2Url != "" {
                let resizedProduct2Url = Utils.getResizedImageUrlString(product2Url, width: "400")
                self.product2ImageView.sd_setImage(with: URL(string: resizedProduct2Url), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            }
        }
        
        product2NameLabel.text = product2.name
        product2PriceLabel.text = "¥ " + product2.price!
        product2TreasureLabel.text = "藏宝:\(product2.treasureRatio!)%"
        
        var periodIndex2 = 0
        periodIndex2 = product2.treasureRatio! - 1
        if periodIndex2 < 0 {
            periodIndex2 = 0
        }
        let periodDouble2 = Double(PAISHOP_PERIODS_TABLE[periodIndex2])! * 135 / restitutionRate
        let roundedPeriod2 = round(periodDouble2)
        let period2 = Int(roundedPeriod2)
        self.product2PeriodLabel.text = "周期:\(period2)"
        
        let label1Lines = product1NameLabel.calculateMaxLines()
        let label2Lines = product2NameLabel.calculateMaxLines()
        imageView1Constraint.constant = 0
        imageView2Constraint.constant = 0
        
        if label1Lines > label2Lines {
            imageView2Constraint.constant = -(product1NameLabel.font.lineHeight*CGFloat(label1Lines-label2Lines))
        } else if label1Lines < label2Lines {
            imageView1Constraint.constant = -(product1NameLabel.font.lineHeight*CGFloat(label2Lines-label1Lines))
        }
        
    }
    
    @IBAction func selectProduct1(_ sender: UIButton) {
        if product1 != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = product1.id!
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectProduct2(_ sender: UIButton) {
        if product2 != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = product2.id!
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}










