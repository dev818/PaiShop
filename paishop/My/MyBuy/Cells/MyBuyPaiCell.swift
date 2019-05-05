
import UIKit

class MyBuyPaiCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalDescriptionLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var piPriceLabel: UILabel!
    @IBOutlet weak var returnPeriodLabel: UILabel!
    @IBOutlet weak var returnPriceLabel: UILabel!
    
    @IBOutlet weak var plusButton: RoundRectButton!
    @IBOutlet weak var calcCountView: RoundRectView!
    @IBOutlet weak var minusButton: RoundRectButton!
    
    
    
    var parentVC: MyBuyVC!
    var product: ProductDetailModel!
    var row: Int!
    var count: Int = 1
    var currencyRate: Double!
    var restitutionRate: Double!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupTheme()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        plusButton.borderColor = MainColors.themeEndColors[selectedTheme]
        plusButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        calcCountView.borderColor = MainColors.themeEndColors[selectedTheme]
        countLabel.textColor = MainColors.themeEndColors[selectedTheme]
        minusButton.borderColor = MainColors.themeEndColors[selectedTheme]
        minusButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        totalPriceLabel.textColor = MainColors.themeEndColors[selectedTheme]
        
        piPriceLabel.textColor = MainColors.themeEndColors[selectedTheme]
        returnPriceLabel.textColor = MainColors.themeEndColors[selectedTheme]
        returnPeriodLabel.textColor = MainColors.themeEndColors[selectedTheme]
        
    }
    
    @IBAction func selectCalcPlus(_ sender: UIButton) {
        self.count += 1
        self.setCountRelatedContent()
        self.updateParentFields()
    }
    
    @IBAction func selectCalcMinus(_ sender: UIButton) {
        if self.count > 1 {
            self.count -= 1
            self.setCountRelatedContent()
            self.updateParentFields()
        }
    }
    
    func setCellContent(_ product: ProductDetailModel, row: Int, vc: MyBuyVC, count: Int, currencyRate: Double, restitutionRate: Double) {
        self.parentVC = vc
        self.product = product
        self.row = row
        self.count = count
        self.currencyRate = currencyRate
        self.restitutionRate = restitutionRate
        
        if !(product.images?.first?.isEmpty)! {
            let resizedUrl = Utils.getResizedImageUrlString((product.images?.first)!, width: "200")
            productImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        }
        productNameLabel.text = product.name
        productPriceLabel.text = "¥" + product.price!
        
        self.setCountRelatedContent()
    }
    
    private func setCountRelatedContent() {
        countLabel.text = "\(count)"
        
        totalDescriptionLabel.text = "共\(count)件商品  小计:"
        let productPrice = Double(product.price!)! * Double(count)
        let totalPrice = productPrice
        totalPriceLabel.text = "¥" + String(totalPrice)
        
        let paiPrice = totalPrice / currencyRate
        piPriceLabel.text = String.init(format: "%.2f", paiPrice) + "π"
        
        var treasureRatio = product.treasureRatio!
        if treasureRatio < 1 {
            treasureRatio = 1
        }
        
        var restitutionRate: Double = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.periodRatio != nil {
            restitutionRate = appDelegate.restitutionRate
        } else {
            restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        let periodDouble = Double(PAISHOP_PERIODS_TABLE[treasureRatio - 1])! * 135 / restitutionRate
        let roundedPeriod = round(periodDouble)
        let period = Int(roundedPeriod)
        returnPeriodLabel.text = "\(period)"
        let buyerReturn = paiPrice / Double(period)
        returnPriceLabel.text = String.init(format: "%.2f", buyerReturn)
    }
    
    private func updateParentFields() {
        parentVC.productCounts[row] = count
        parentVC.setTotalPriceLabel()
    }
    
}







