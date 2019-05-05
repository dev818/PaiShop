

import UIKit

class MyStoreOrderCell: UITableViewCell {
    
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var pricePerUnitLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.isHidden = true
        }
    }
    //paymentTypeImageView2.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
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
    @IBOutlet weak var addtionPiImageView: UIImageView! {
        didSet {
            addtionPiImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
            addtionPiImageView.isHidden = true
        }
    }
    @IBOutlet weak var btnViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmBtn: RoundButton! {
        didSet {
            confirmBtn.isHidden = true
        }
    }
    @IBOutlet weak var refuseBtn: RoundButton! {
        didSet {
            refuseBtn.isHidden = true
        }
    }
    
    var orderItem: OrderItemModel!    

    override func awakeFromNib() {
        super.awakeFromNib()
        
         // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 0->all, 2->pending, 3->delivering, 1->completed, 4->refund
    func setupUI(selectedTab: Int) {
        switch selectedTab {
        case 0:
            statusLabel.isHidden = false
            btnViewHeightConstraint.constant = 0
            break        
        case 4:
            btnViewHeightConstraint.constant = 58
            confirmBtn.isHidden = false
            refuseBtn.isHidden = false
            break
        default:
            statusLabel.isHidden = true
            btnViewHeightConstraint.constant = 0
        }
    }
    
    func setCellContent(_ orderItem: OrderItemModel) {
        self.orderItem = orderItem
        
        deliveryDateLabel.text = orderItem.order.createdAt
        
        if (orderItem.product.images?.count)! > 0 {
            if let orderUrl = orderItem.product.images?.first, orderUrl != "" {
                let resizedOrderUrl = Utils.getResizedImageUrlString(orderUrl, width: "200")
                productImageView.setImageWithURLString(resizedOrderUrl, placeholderImage: ImageAsset.default_image.image)
            } 
        }
        
        productNameLabel.text = orderItem.product.name
        countLabel.text = "x" + String(orderItem.order.count!)
        priceLabel.text = "¥" + orderItem.order.price!
        pricePerUnitLabel.text = "¥" + orderItem.order.price!
        
        if orderItem.product.paymentType! == 1 {
            piImageView.isHidden = false
            yuanImageView.isHidden = true
            addtionPiImageView.isHidden = true
        } else if orderItem.product.paymentType! == 2 {
            piImageView.isHidden = true
            yuanImageView.isHidden = false
            addtionPiImageView.isHidden = true
        }
        
        switch orderItem.order.status! {
        case 0:
            statusLabel.text = "取消"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
        case 1:
            statusLabel.text = "交易完成"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFFA400) //0x03A678
        case 2:
            statusLabel.text = "等待"
            statusLabel.textColor = UIColor.lightGray
        case 3:
            statusLabel.text = "卖家已发货"
            statusLabel.textColor = UIColor.init(colorWithHexValue: 0xFFA400)
        default:
            statusLabel.text = "等待"
            statusLabel.textColor = UIColor.lightGray            
        }
        
    }
    
    
}








