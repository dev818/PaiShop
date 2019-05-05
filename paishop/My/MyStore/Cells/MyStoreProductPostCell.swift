
import UIKit

class MyStoreProductPostCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    
    var myStoreProductPostVC: MyStoreProductPostVC!
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCellContent(_ customImage: CustomImageModel, index: Int, vc: MyStoreProductPostVC) {
        self.index = index
        self.myStoreProductPostVC = vc
        if customImage.isImage {
            postImageView.image = customImage.image
        } else {
            postImageView.setImageWithURLString(customImage.imageURL!, placeholderImage: ImageAsset.default_image.image)
        }
        
        let imageWidth: Int = Int(UIScreen.ts_width) - 32 - 40
        var imageHeight = imageWidth * 2 / 3
        if customImage.isImage {
            if let image = customImage.image {
                let width = Int(image.size.width)
                let height = Int(image.size.height)
                if width > 0 && height > 0 {
                    imageHeight = height * imageWidth / width
                }
            }
        } else {
            if let imageUrl = customImage.imageURL {                
                let sizeOfWH = Utils.getImageSizeFromUrl(imageUrl)
                let width = sizeOfWH[0]
                let height = sizeOfWH[1]
                
                if width > 0 && height > 0 {
                    imageHeight = height * imageWidth / width
                }
            }
        }
        
        imageHeightConstraint.constant = CGFloat(imageHeight)
        
    }
    
    @IBAction func selectDelete(_ sender: Any) {
        if !myStoreProductPostVC.customImageArray[index].isImage {
            myStoreProductPostVC.deletedImages.append(myStoreProductPostVC.customImageArray[index].imageURL!)
        }
        myStoreProductPostVC.customImageArray.remove(at: index)
        
        myStoreProductPostVC.updateTableViewHeight()
    }
    
    
}
