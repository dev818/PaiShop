

import UIKit

class HomeProductDetailImageCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var parentVC: HomeProductDetailVC!
    var index: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ imageUrl: String, index: Int, vc: HomeProductDetailVC) {
        let imageWidth = Int(UIScreen.ts_width) - 32
        var imageHeight = imageWidth * 2 / 3
                
        let arrayOfWH = Utils.getImageSizeFromUrl(imageUrl)
        let width = arrayOfWH[0]
        let height = arrayOfWH[1]
        
        if width > 0 && height > 0 {
            imageHeight = height * imageWidth / width
        }
        imageHeightConstraint.constant = CGFloat(imageHeight)
        
        self.parentVC = vc
        self.index = index
        
//        let url = URL(string: imageUrl)
//        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                productImageView.image = UIImage(data: data!)
        
        productImageView.setImageWithURLString(imageUrl, placeholderImage: ImageAsset.default_image.image)
        
        let imageViewTap = UITapGestureRecognizer(target: self, action: #selector(selectProductImageView))
        productImageView.isUserInteractionEnabled = true
        productImageView.addGestureRecognizer(imageViewTap)
    }
    
    @objc func selectProductImageView() {
        parentVC.tapProductImageView(self.index)
    }
    
}
