
import UIKit
import SDWebImage

class HomeListCell: UITableViewCell {

    var parentVC: UIViewController!
    var productList: ProductListModel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var pinImageView: UIImageView! {
        didSet {
            pinImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    @IBOutlet weak var storeAddressLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var degreeImageView: UIImageView!
    @IBOutlet weak var productCategoryLabel: UILabel! {
        didSet {
            if UIScreen.ts_width < 330 {
                productCategoryLabel.font = UIFont.systemFont(ofSize: 13)
            }
        }
    }
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
    @IBOutlet weak var productImageView1: UIImageView!
    @IBOutlet weak var productImageView2: UIImageView!
    @IBOutlet weak var productImageView3: UIImageView!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productDateLabel: UILabel! {
        didSet {
            productDateLabel.isHidden = true
        }
    }
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!    
    @IBOutlet weak var commentLabel: UILabel!

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
    
    @IBOutlet var productImageViewList: [UIImageView]!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ productList: ProductListModel, vc: UIViewController) {
        self.productList = productList
        self.parentVC = vc
        
        productAmountLabel.isHidden = false
        productPriceLabel.isHidden = false
        productTreasureRatioLabel.isHidden = false
        pinImageView.isHidden = false
        
        if let store = productList.store, !store.name!.isEmpty {
            self.storeAddressLabel.text = productList.store?.address
            let resizedUrlString = Utils.getResizedImageUrlString((productList.store?.image)!, width: "200")
            self.storeImageView.setImageWithURLString(resizedUrlString, placeholderImage: ImageAsset.icon_store.image)
        } else {
            self.storeAddressLabel.text = productList.user?.address
            if (productList.user?.address?.isEmpty)! {
                pinImageView.isHidden = true
            }
            let resizedUrlString = Utils.getResizedImageUrlString((productList.store?.image)!, width: "200")
            self.storeImageView.setImageWithURLString(resizedUrlString, placeholderImage: ImageAsset.icon_avatar.image)
            productAmountLabel.isHidden = true
            productPriceLabel.isHidden = true
            productTreasureRatioLabel.isHidden = true
        }
        
        self.productNameLabel.text = productList.store?.name //self.productNameLabel.text = productList.name
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        let degreeId = productList.user!.degreeId!
        degreeImageView.isHidden = true
        if degreeImages.count > 0 && degreeId > 0 {
            if degreeImages.count >= degreeId {
                degreeImageView.isHidden = false
                degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
            }
        }
        
        self.productCategoryLabel.text = productList.category?.name
        self.productPriceLabel.text = "¥ " + productList.price!
        
        var periodIndex = 0
        periodIndex = productList.treasureRatio! - 1
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
        self.productTreasureRatioLabel.text = "藏宝:" + String(productList.treasureRatio!) + "%"
        self.productDescriptionLabel.text = productList.description
        self.productDateLabel.text = self.getFormattedDateString(productList.createdAt!)
        if productList.views != nil {
            self.viewsLabel.text = String(productList.views!)
        }
        if productList.favoritesCount != nil {
            self.likesLabel.text = String(productList.favoritesCount!)
        }
        if productList.favorites! > 0 {
            self.likesImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        } else {
            self.likesImageView.setTintColor(UIColor.init(colorWithHexValue: 0x686868))
        }
        self.commentLabel.text = String(productList.commentsCount!)
        
        if productList.paymentType! == 1 {
            paiImageView.isHidden = false
            yuanImageView.isHidden = true
            
            self.productAmountLabel.isHidden = false
            self.productTreasureRatioLabel.isHidden = false
        } else if productList.paymentType! == 2 {
            paiImageView.isHidden = true
            yuanImageView.isHidden = false
            
            self.productAmountLabel.isHidden = true
            self.productTreasureRatioLabel.isHidden = true
        }
        
        guard let images = productList.images else { return }
        if images.count >= 3 {
            DispatchQueue.main.async {
                for i in 0..<3 {
                    //self.productImageViewList[i].setImageWithURLString(API.IMAGE_URL + images[i], placeholderImage: ImageAsset.default_image.image)
                    self.productImageViewList[i].sd_setShowActivityIndicatorView(true)
                    self.productImageViewList[i].sd_setIndicatorStyle(.gray)
                    let resizedUrlString = Utils.getResizedImageUrlString(images[i], width: "400")
                    self.productImageViewList[i].sd_setImage(with: URL(string: resizedUrlString), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                        //finished loading...
                    })
                }
            }
            
        } else {
            DispatchQueue.main.async {
                for i in 0..<images.count {
                    //self.productImageViewList[i].setImageWithURLString(API.IMAGE_URL + images[i], placeholderImage: ImageAsset.default_image.image)
                    self.productImageViewList[i].sd_setShowActivityIndicatorView(true)
                    self.productImageViewList[i].sd_setIndicatorStyle(.gray)
                    let resizedUrlString = Utils.getResizedImageUrlString(images[i], width: "400")
                    self.productImageViewList[i].sd_setImage(with: URL(string: resizedUrlString), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                        //finished loading...
                    })
                }
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHeaderView(_:)))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tap)        
        
        let pinTap = UITapGestureRecognizer(target: self, action: #selector(goToMap))
        pinImageView.isUserInteractionEnabled = true
        pinImageView.addGestureRecognizer(pinTap)
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(goToMap))
        storeAddressLabel.isUserInteractionEnabled = true
        storeAddressLabel.addGestureRecognizer(addressTap)
        
    }
    
    @objc func tapHeaderView(_ gesture: UITapGestureRecognizer) {
        Utils.applyTouchEffect(headerView)
        if let store = productList.store, !store.name!.isEmpty {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = self.productList.store?.storeId
            self.parentVC.pushAndHideTabbar(vc)
        }        
    }
    
    @objc func goToMap() {
        if let store = productList.store, !store.name!.isEmpty {
            let latitude = store.lat!
            let longitude = store.lng!
            if latitude != 0.0 && longitude != 0.0 {
                Utils.applyTouchEffect(pinImageView)
                Utils.applyTouchEffect(storeAddressLabel)
                
                let guideMapVC = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: GuideMapVC.nameOfClass) as! GuideMapVC
                guideMapVC.markerName = store.name!
                guideMapVC.markerLat = latitude
                guideMapVC.markerLon = longitude
                guideMapVC.makerDescription = store.introduction
                guideMapVC.storeImage = store.image
                guideMapVC.storeId = store.storeId!
                guideMapVC.degree = productList.user?.degreeId
                self.parentVC.pushAndHideTabbar(guideMapVC)
            }
        }
        
    }
    
    private func getFormattedDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: dateString)!
        let timeAgo = Date.timeAgoSinceDate(date, numericDates: true)
        
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([
            NSCalendar.Unit.minute,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.day,
            NSCalendar.Unit.weekOfYear,
            NSCalendar.Unit.month,
            NSCalendar.Unit.year,
            NSCalendar.Unit.second
            ], from: date)
        
        let dateString = timeAgo + "  " + String(components.month!) + "月" + String(components.day!) + "日  " + String(components.hour!) + ":" + String(components.minute!)
        return dateString
    }
    
}








