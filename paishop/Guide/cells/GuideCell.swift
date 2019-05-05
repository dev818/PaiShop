
import UIKit

class GuideCell: UITableViewCell {
    
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var openingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var degreeImageView: UIImageView! /*{
        didSet {
            degreeImageView.clipsToBounds = true
            degreeImageView.layer.borderWidth = 1
            degreeImageView.layer.borderColor = UIColor.init(colorWithHexValue: 0xFF3E03).cgColor
        }
    }*/
    
    var guideVC: GuideVC!
    var store: StoreDetailModel!
    var indexPath: IndexPath!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        distanceLabel.text = "0m"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(_ store: StoreDetailModel, vc: GuideVC, indexPath: IndexPath) {
        self.guideVC = vc
        self.store = store
        self.indexPath = indexPath
        
        if store.image! == "" {
            let resizedUrl = Utils.getResizedImageUrlString(store.image!, width: "200")
            storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        } else {
            let resizedUrlString = Utils.getResizedImageUrlString(store.image!, width: "200")
            storeImageView.setImageWithURLString(resizedUrlString, placeholderImage: ImageAsset.icon_store.image)
        }        
        
        nameLabel.text = store.name
        descriptionLabel.text = store.address
        openingLabel.text = store.opening
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        let degreeId = store.user!.degreeId!
        degreeImageView.isHidden = true
        if degreeImages.count > 0 && degreeId > 0 {
            if degreeImages.count >= degreeId {
                degreeImageView.isHidden = false
                degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
            }
        }
        
        if guideVC.userLocationCoordinate != nil {
            let distanceInKilo = Utils.distanceFromLatLon(lat1: (store.lat)!, lon1: (store.lng)!, lat2: guideVC.userLocationCoordinate.latitude, lon2: guideVC.userLocationCoordinate.longitude, unit: "K")
            if distanceInKilo >= 10 {
                distanceLabel.text = "\(Int(distanceInKilo))km"
            } else {
                distanceLabel.text = "\(Int(distanceInKilo * 1000))m"
            }
        } else {
            distanceLabel.text = ""
        }
    }
    
}












