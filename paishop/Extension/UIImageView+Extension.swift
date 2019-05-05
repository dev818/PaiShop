
import UIKit
import Kingfisher
import SDWebImage


extension UIImageView {
    
    func setImageWithURLString(_ URLString: String?, placeholderImage: UIImage? = nil) {
        //kingfisher...
        /*guard let URLString = URLString, let URL = URL.init(string: URLString) else { return  }
        self.kf.setImage(with: URL, placeholder: placeholderImage)*/
        
        self.sd_setShowActivityIndicatorView(true)
        self.sd_setIndicatorStyle(.gray)
//        self.sd_setImage(with: URL(string: URLString!), placeholderImage: placeholderImage, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
//            //finished loading...
//        })
        
        if URLString != nil {
            self.sd_setImage(with: URL.init(string: URLString!), placeholderImage: placeholderImage, options:SDWebImageOptions.scaleDownLargeImages, completed: { (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                
                if ((error) != nil) {
                    self.image = ImageAsset.default_image.image
                }
            })
        }
        else{
            self.image = ImageAsset.default_image.image
        }
        
    }
    
    func setImageWithURLStringNoCache(_ URLString: String?, placeholderImage: UIImage? = nil) {
        guard let URLString = URLString, let URL = URL.init(string: URLString) else { return  }
        self.kf.setImage(with: URL, placeholder: placeholderImage, options: [.forceRefresh])
    }
    
    func setCircularImageWithURLString(_ URLString: String?, placeholderImage: UIImage? = nil) {
        self.setRoundedImageWithURLString(URLString, placeholderImage: placeholderImage, cornerRadiusRatio: self.ts_width / 2)
    }
    
    func setCornerRadiusImageWithURLString(_ URLString: String?, placeholderImage: UIImage? = nil, cornerRadiusRatio: CGFloat? = nil) {
        self.setRoundedImageWithURLString(URLString, placeholderImage: placeholderImage, cornerRadiusRatio: cornerRadiusRatio)
    }
    
    func setRoundedImageWithURLString(_ URLString: String?, placeholderImage: UIImage? = nil, cornerRadiusRatio: CGFloat? = nil, progressBlock: ImageDownloaderProgressBlock? = nil) {
        guard let URLString = URLString, let URL = URL.init(string: URLString) else { return  }
        
        let memoryImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: URLString)
        let diskImage = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: URLString)
        guard let image = memoryImage ?? diskImage  else {
            let optionInfo: KingfisherOptionsInfo = [ .forceRefresh ]
            KingfisherManager.shared.downloader.downloadImage(with: URL, options: optionInfo, progressBlock: progressBlock, completionHandler: { (image, error, imageURL, originalData) in
                if let image = image, let originalData = originalData {
                    DispatchQueue.global(qos: .default).async {
                        let roundedImage = image.ts_roundWithCornerRadius(image.size.width * (cornerRadiusRatio ?? 0.5))
                        KingfisherManager.shared.cache.store(roundedImage, original: originalData, forKey: URLString, toDisk: true, completionHandler: {
                            self.setImageWithURLString(URLString)
                        })
                    }
                }
            })
            return
        }
        self.image = image
    }
    
    
    func setTintColor(_ color: UIColor) {
        self.image = self.image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
    
    func setResizeImageWithURLString(_ URLString: String, placeholderImage: UIImage? = nil, size: Int) {
        //let sizeOfWH = Utils.getImageSizeFromUrl(URLString)
        //let imgWidth = sizeOfWH[0]
        //let imgHeight = sizeOfWH[1]
        
    }
    
    
}




















