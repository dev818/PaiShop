//
//  HomeProductDetailCell.swift


import UIKit

class HomeProductDetailCell: UITableViewCell {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var pinImageView: UIImageView! {
        didSet {
            pinImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    @IBOutlet weak var storeAddressLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCategoryLabel: UILabel! {
        didSet {
            if UIScreen.ts_width < 330 {
                productCategoryLabel.font = UIFont.systemFont(ofSize: 13)
            }
        }
    }
    @IBOutlet weak var degreeImageView: UIImageView! /*{
        didSet {
            degreeImageView.clipsToBounds = true
            degreeImageView.layer.borderWidth = 1
            degreeImageView.layer.borderColor = UIColor.init(colorWithHexValue: 0xFF3E03).cgColor
        }
    }*/
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAmountLabel: UILabel! {
        didSet {
            if UIScreen.ts_width < 330 {
                productAmountLabel.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }
    @IBOutlet weak var productTreasureRatioLabel: UILabel! {
        didSet {
            if UIScreen.ts_width < 330 {
                productTreasureRatioLabel.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
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
    
    
    var parentVC: HomeProductDetailVC!
    var productDetail: ProductDetailModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ productDetail: ProductDetailModel, vc: HomeProductDetailVC) {
        self.parentVC = vc
        self.productDetail = productDetail
        
        if let store = productDetail.store, !store.name!.isEmpty {
            self.storeAddressLabel.text = productDetail.store?.address
            if productDetail.store?.image != "" {
                let resizedUrl = Utils.getResizedImageUrlString((productDetail.store?.image)!, width: "200")
                self.storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
            }
            
        } else {
            self.storeAddressLabel.text = productDetail.user?.address
            if (productDetail.user?.address?.isEmpty)! {
                pinImageView.isHidden = true
            }
            if productDetail.user?.image != "" {
                let resizedUrl = Utils.getResizedImageUrlString((productDetail.user?.image)!, width: "200")
                self.storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
            }
            
            productPriceLabel.isHidden = true
            productAmountLabel.isHidden = true
            productTreasureRatioLabel.isHidden = true
        }
        
        productNameLabel.text = productDetail.name
        productCategoryLabel.text = productDetail.category?.name
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        let degreeId = productDetail.user!.degreeId!
        degreeImageView.isHidden = true
        if degreeImages.count > 0 && degreeId > 0 {
            if degreeImages.count >= degreeId {
                degreeImageView.isHidden = false
                degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
            }
        }
        
        productPriceLabel.text = "¥ " + productDetail.price!
        
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
        self.productAmountLabel.text = "周期:\(period)"
        
        productTreasureRatioLabel.text = "藏宝:" + String(productDetail.treasureRatio!) + "%"
        productDescriptionLabel.text = productDetail.description
        
        if productDetail.paymentType! == 1 {
            piImageView.isHidden = false
            yuanImageView.isHidden = true
            productAmountLabel.isHidden = false
            productTreasureRatioLabel.isHidden = false
        } else if productDetail.paymentType! == 2 {
            piImageView.isHidden = true
            yuanImageView.isHidden = false
            productAmountLabel.isHidden = true
            productTreasureRatioLabel.isHidden = true
        }
        
        
        let headerTap = UITapGestureRecognizer(target: self, action: #selector(selectStoreImageView))
        storeImageView.isUserInteractionEnabled = true
        storeImageView.addGestureRecognizer(headerTap)
        
        let pinTap = UITapGestureRecognizer(target: self, action: #selector(goToMap))
        pinImageView.isUserInteractionEnabled = true
        pinImageView.addGestureRecognizer(pinTap)
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(goToMap))
        storeAddressLabel.isUserInteractionEnabled = true
        storeAddressLabel.addGestureRecognizer(addressTap)        
    }
    
    @objc func selectStoreImageView() {
        Utils.applyTouchEffect(storeImageView)
        if let store = productDetail.store, !store.name!.isEmpty {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = self.productDetail.store?.storeId
            parentVC.pushAndHideTabbar(vc)
        }
    }
    
    @objc func goToMap() {
        guard let store = productDetail.store else { return }
        let latitude = store.lat!
        let longitude = store.lng!
        if latitude != 0.0 && longitude != 0.0 {
            Utils.applyTouchEffect(pinImageView)
            Utils.applyTouchEffect(storeAddressLabel)
            
            let guideMapVC = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: GuideMapVC.nameOfClass) as! GuideMapVC
            guideMapVC.markerName = (productDetail.store?.name)!
            guideMapVC.markerLat = latitude
            guideMapVC.markerLon = longitude
            guideMapVC.makerDescription = store.introduction
            guideMapVC.storeImage = store.image
            guideMapVC.storeId = store.storeId!
            guideMapVC.degree = self.productDetail.user?.degreeId
            parentVC.pushAndHideTabbar(guideMapVC)
        }
    }
    
    
}














