

import UIKit

class HomeProductDetailInfoCell: UITableViewCell {
    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var commentCountView: UIStackView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likeCountView: UIStackView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    
    
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
        
        if productDetail.views != nil {
            self.viewsLabel.text = String(productDetail.views!)
        }
        if productDetail.favoritesCount != nil {
            self.likesLabel.text = String(productDetail.favoritesCount!)
        }
        self.commentsLabel.text = String(productDetail.commentsCount!)
        if productDetail.favorites! > 0 {
            self.likesImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
        } else {
            self.likesImageView.setTintColor(UIColor.init(colorWithHexValue: 0x686868))
        }
        
        let commentCountTap = UITapGestureRecognizer(target: self, action: #selector(selectCommentCount))
        commentCountView.isUserInteractionEnabled = true
        commentCountView.addGestureRecognizer(commentCountTap)
        
        let likeCountTap = UITapGestureRecognizer(target: self, action: #selector(selectLikeCount))
        likeCountView.isUserInteractionEnabled = true
        likeCountView.addGestureRecognizer(likeCountTap)
    }
    
    @objc func selectCommentCount() {
        Utils.applyTouchEffect(commentCountView)
        /*let homeCommentVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeCommentVC.nameOfClass) as! HomeCommentVC
        homeCommentVC.productId = self.productDetail.id!
        parentVC.pushAndHideTabbar(homeCommentVC)*/
    }
    
    @objc func selectLikeCount() {
        if productDetail.favorites! > 0 {
            return
        }
        
        if productDetail.user?.id == UserInstance.userId {
            return
        }
        
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录!")
            return
        }
        
        Utils.applyTouchEffect(likeCountView)
        let parameters: [String : Any] = [
            "id" : productDetail.id!
        ]
        HomeAPI.shared.itemLike(params: parameters) { (json, success) in
            if success {
                print("Item Like...")
                print(json)
                self.productDetail.favoritesCount! += 1
                self.productDetail.favorites = 1
                self.likesLabel.text = String(self.productDetail.favoritesCount!)
                self.likesImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
                
                self.parentVC.productDetail.favorites = 1
                self.parentVC.productDetail.favoritesCount! += 1
            } else {
                // try again...
                HomeAPI.shared.itemLike(params: parameters, completion: { (json, success1) in
                    if success1 {
                        self.productDetail.favoritesCount! += 1
                        self.productDetail.favorites = 1
                        self.likesLabel.text = String(self.productDetail.favoritesCount!)
                        self.likesImageView.setTintColor(UIColor.init(colorWithHexValue: 0xFF3E03))
                        self.parentVC.productDetail.favorites = 1
                        self.parentVC.productDetail.favoritesCount! += 1
                    }
                })
            }
        }
    }
    
    
}














