//
//  HomeProductDetailTopCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class HomeProductDetailTopCell: UITableViewCell {
    
    @IBOutlet weak var NavFrameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCategoryButtonLabel: RoundRectButton!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTreasureLabel: UILabel!
    @IBOutlet weak var productPeriodLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var piImageView: UIImageView! {
        didSet {
            piImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    @IBOutlet weak var yuanImageView: UIImageView! {
        didSet {
            yuanImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    
    @IBOutlet weak var viewCheck: UIView!
    @IBOutlet weak var viewCheck1: UIView!
    @IBOutlet weak var viewCheck2: UIView!
    @IBOutlet weak var viewCheck3: UIView!
    
    @IBOutlet weak var imgCheck1: UIImageView!
    @IBOutlet weak var imgCheck2: UIImageView!
    @IBOutlet weak var imgCheck3: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!    
    @IBOutlet weak var navFrameTopConstraint: NSLayoutConstraint!
    
    
    var parentVC: HomeProductDetailVC!
    var productDetail: ProductDetailModel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if Utils.isIphoneX() {
            NavFrameHeightConstraint.constant = 88
            topConstraint.constant = -44
            navFrameTopConstraint.constant = -44
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ productDetail: ProductDetailModel, vc: HomeProductDetailVC) {
        self.parentVC = vc
        self.productDetail = productDetail
        
        if productDetail.images?.first != "" {
            let resizedUrl = Utils.getResizedImageUrlString((productDetail.images?.first)!, width: "800")
            topImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        }
    
        productNameLabel.text = productDetail.name
        productCategoryButtonLabel.setTitle(productDetail.category?.name, for: .normal)
        productPriceLabel.text = "¥ " + productDetail.price!
        productTreasureLabel.text = "藏宝:" + String(productDetail.treasureRatio!) + "%"
        addressLabel.text = productDetail.store?.address
        
        var periodIndex = 0
        periodIndex = productDetail.treasureRatio! - 1
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
        self.productPeriodLabel.text = "周期:\(period)"
        
        if productDetail.paymentType! == 1 {
            piImageView.isHidden = false
            yuanImageView.isHidden = true
            productPeriodLabel.isHidden = false
            productTreasureLabel.isHidden = false
        } else if productDetail.paymentType! == 2 {
            piImageView.isHidden = true
            yuanImageView.isHidden = false
            productPeriodLabel.isHidden = true
            productTreasureLabel.isHidden = true
        }
        
        if productDetail.refundInWeek == true {
            imgCheck1.image = UIImage.init(named: "ic_nearby_check.png")
        } else {
            imgCheck1.image = UIImage.init(named: "ic_nearby_uncheck.png")
        }
        
        if productDetail.refundOnOff == true {
            imgCheck2.image = UIImage.init(named: "ic_nearby_check.png")
        } else {
            imgCheck2.image = UIImage.init(named: "ic_nearby_uncheck.png")
        }
        
        if productDetail.deliveryOnOff == true {
            imgCheck3.image = UIImage.init(named: "ic_nearby_check.png")
        } else {
            imgCheck3.image = UIImage.init(named: "ic_nearby_uncheck.png")
        }

    }
    
    @IBAction func selectBack(_ sender: UIButton) {
        if parentVC.senderVC != nil {
            let info: [String : Any] = [
                "senderVC" : parentVC.senderVC!,
                "senderIndex" : parentVC.senderIndex,
                "productDetail" : parentVC.productDetail
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.PRODUCT_DETAIL_CHANGE), object: nil, userInfo: info)
        }
        self.parentVC.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectCart(_ sender: UIButton) {
        if UserInstance.isLogin {
//            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ShoppingCartVC.nameOfClass)
//            parentVC.navigationController?.pushViewController(vc, animated: true)
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
            vc.selectedIndex = 1
            parentVC.navigationController?.pushViewController(vc, animated: true)
        } else {
            parentVC.goToLoginVC()
        }
    }
    
    
    
}
