
import UIKit

class MyFavorStoreCell: UITableViewCell {
    
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var degreeImageView: UIImageView! /*{
        didSet {
            degreeImageView.clipsToBounds = true
            degreeImageView.layer.borderWidth = 1
            degreeImageView.layer.borderColor = UIColor.init(colorWithHexValue: 0xFF3E03).cgColor
        }
    }*/
    @IBOutlet weak var openingLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ store: StoreDetailModel) {
        let resizedUrl = Utils.getResizedImageUrlString(store.image!, width: "400")
        storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        storeNameLabel.text = store.name
        openingLabel.text = store.opening
        categoryLabel.text = store.category?.name
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        let degreeId = store.user!.degreeId!
        degreeImageView.isHidden = true
        if degreeImages.count > 0 && degreeId > 0 {
            if degreeImages.count >= degreeId {
                degreeImageView.isHidden = false
                degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
            }
        }
        
    }
    
}
