//
//  NearbyBottomCollectionCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage

class NearbyBottomCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var storeImageView: RoundRectImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeCityLabel: UILabel!
    @IBOutlet weak var storeCategoryLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ store: StoreDetailModel, userLocation: CLLocationCoordinate2D!) {
        self.storeImageView.sd_setShowActivityIndicatorView(true)
        self.storeImageView.sd_setIndicatorStyle(.gray)
        
        if let storeUrl = store.image, storeUrl != "" {
            let resizedStoreUrl = Utils.getResizedImageUrlString(storeUrl, width: "500")
            self.storeImageView.sd_setImage(with: URL(string: resizedStoreUrl), placeholderImage: ImageAsset.default_image.image, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                //finished loading...
            })
        }
        storeNameLabel.text = store.name
        storeCityLabel.text = store.city?.name
        storeCategoryLabel.text = store.category?.name
        
        if userLocation != nil {
            let distanceInKilo = Utils.distanceFromLatLon(lat1: (store.lat)!, lon1: (store.lng)!, lat2: userLocation.latitude, lon2: userLocation.longitude, unit: "K")
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
