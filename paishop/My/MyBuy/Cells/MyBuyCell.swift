
import UIKit

class MyBuyCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalDescriptionLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
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
    
    @IBOutlet weak var plusButton: RoundRectButton!
    @IBOutlet weak var calcCountView: RoundRectView!
    @IBOutlet weak var minusButton: RoundRectButton!
    
    var parentVC: MyBuyVC!
    var product: ProductDetailModel!
    var row: Int!
    var count: Int = 1

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
    
    func setCellContent(_ product: ProductDetailModel, row: Int, vc: MyBuyVC, count: Int) {
        self.parentVC = vc
        self.product = product
        self.row = row
        self.count = count
        
        if !(product.images?.first?.isEmpty)! {
            let resizedUrl = Utils.getResizedImageUrlString((product.images?.first)!, width: "400")
            productImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        }
        productNameLabel.text = product.name
        productPriceLabel.text = "¥" + product.price!
        
        if product.paymentType! == 1 {
            piImageView.isHidden = false
            yuanImageView.isHidden = true
        } else if product.paymentType! == 2 {
            piImageView.isHidden = true
            yuanImageView.isHidden = false
        }
        
        self.setCountRelatedContent()
    }
    
    private func setCountRelatedContent() {
        countLabel.text = "\(count)"
        
        totalDescriptionLabel.text = "共\(count)件商品  小计:"
        let productPrice = Double(product.price!)! * Double(count)
        let totalPrice = productPrice
        totalPriceLabel.text = "¥" + String(totalPrice)
    }
    
    private func updateParentFields() {
        parentVC.productCounts[row] = count
        parentVC.setTotalPriceLabel()
    }
    
}








