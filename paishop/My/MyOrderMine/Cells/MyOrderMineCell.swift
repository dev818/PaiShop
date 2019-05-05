
import UIKit

class MyOrderMineCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var productItemView: UIView!
    
    var vc: UIViewController!
    var orderItem: OrderItemModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ orderItem: OrderItemModel, vc: UIViewController) {
        self.orderItem = orderItem
        self.vc = vc
        
        dateLabel.text = orderItem.order.createdAt!
        if (orderItem.product.images?.count)! > 0 {
            if let productUrl = orderItem.product.images?.first, productUrl != "" {
                let resizedProductUrl = Utils.getResizedImageUrlString(productUrl, width: "150")
                productImageView.setImageWithURLString(resizedProductUrl, placeholderImage: ImageAsset.default_image.image)
            } 
        }
        
        productNameLabel.text = orderItem.product.name
        countLabel.text = "x" + String(orderItem.order.count!)
        priceLabel.text = "¥" + orderItem.order.price!
        
        let totalPrice = Double(orderItem.order.price!)! * Double(orderItem.order.count!)
        totalPriceLabel.text = "共\(orderItem.order.count!)件商品  合计:¥\(totalPrice)"
        
        switch orderItem.order.status! {
        case 0:
            statusLabel.text = "取消"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
        case 1:
            statusLabel.text = "完成"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0x03A678)
        case 2:
            statusLabel.text = "等待"
            statusLabel.textColor = UIColor.lightGray
        case 3:
            statusLabel.text = "已发货"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFFA400)
        default:
            statusLabel.text = "等待"
            statusLabel.textColor = UIColor.lightGray
        }
    }
    
    
    
}
