
import UIKit

class MyBillingReturnCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var piImageView: UIImageView! {
        didSet {
            piImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        }
    }
    @IBOutlet weak var paiAmountLabel: UILabel!
    @IBOutlet weak var treasureRatioLabel: UILabel!
    @IBOutlet weak var treasurePeriodLabel: UILabel!
    @IBOutlet weak var treasureReturnLabel: UILabel!
    
    @IBOutlet weak var totalPriceFrame: UIView!
    @IBOutlet weak var totalPriceHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ release: ReleaseModel, type: Bool) {
        
        paiAmountLabel.text = release.paiPrice
        treasurePeriodLabel.text = "\(release.releasePeriod!)"
        treasureReturnLabel.text = type ? release.sellerRestitution : release.buyerRestitution
        
        if release.activityId! > 0 { //Degree Upgrade
            dateLabel.text = release.activityCreatedAt
            var degreeImages: [String] = []
            var degreeProfitRatios: [Int] = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.degreeImageArray.count > 0 {
                degreeImages = appDelegate.degreeImageArray
            } else {
                degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
            }
            if appDelegate.degreeProfitRatioArray.count > 0 {
                degreeProfitRatios = appDelegate.degreeProfitRatioArray
            } else {
                degreeProfitRatios = UserDefaultsUtil.shared.getDegreeProfitRatioArray()
            }
            print("Degree Images..........", degreeImages)
            print("release.activityDegreeId.........", release)
            if degreeImages.count >= release.activityDegreeId! {
                if release.activityDegreeId! > 0 {
                    productImageView.setImageWithURLString(degreeImages[release.activityDegreeId! - 1])
                } else {
                    productImageView.setImageWithURLString(degreeImages[release.activityDegreeId!])
                }
                
            }
            productNameLabel.text = release.activityContent
            productPriceLabel.text = ""
            countLabel.text = ""
            if degreeProfitRatios.count >= release.activityDegreeId! {
                if release.activityDegreeId! > 0 {
                    treasureRatioLabel.text = "\(degreeProfitRatios[release.activityDegreeId! - 1])%"
                } else {
                    treasureRatioLabel.text = "\(degreeProfitRatios[release.activityDegreeId!])%"
                }
                
            }
            totalPriceFrame.isHidden = true
            totalPriceHeightConstraint.constant = 0
            
        } else {
            dateLabel.text = release.orderCreatedAt
            if release.images!.count > 0 {
                let resizedUrl = Utils.getResizedImageUrlString((release.images?.first)!, width: "200")
                productImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)//productImageView.setImageWithURLString(API.IMAGE_URL + (release.images?.first)!, placeholderImage: ImageAsset.default_image.image)
            }
            productNameLabel.text = release.productName
            productPriceLabel.text = "¥" + release.price!
            countLabel.text = "x\(release.count!)"
            
            let totalPrice = Double(release.price!)! * Double(release.count!)
            let totalPriceString = String.init(format: "%.2f", totalPrice)
            totalPriceLabel.text = "共\(release.count!)件商品  合计:¥" + totalPriceString            
            treasureRatioLabel.text = "\(release.treasureRatio!)%"
            
            totalPriceFrame.isHidden = false
            totalPriceHeightConstraint.constant = 44
        }
        
        
        
    }
    
}





