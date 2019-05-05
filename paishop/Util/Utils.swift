
import Foundation
import AssistantKit
import SwiftyJSON

// stolen from Kingfisher: https://github.com/onevcat/Kingfisher/blob/master/Sources/ThreadHelper.swift
func dispatch_async_safely_to_main_queue(_ block: @escaping ()->()) {
    dispatch_async_safely_to_queue(DispatchQueue.main, block)
}

// This methd will dispatch the `block` to a specified `queue`.
// If the `queue` is the main queue, and current thread is main thread, the block
// will be invoked immediately instead of being dispatched.
func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->()) {
    if queue === DispatchQueue.main && Thread.isMainThread {
        block()
    } else {
        queue.async {
            block()
        }
    }
}

public var levelPayment = true

public let levelImages: [UIImage] = [
    ImageAsset.level0.image,
    ImageAsset.level1.image,
    ImageAsset.level2.image,
    ImageAsset.level3.image,
    ImageAsset.level4.image,
    ImageAsset.level5.image
]

public let levelNames: [String] = [
    "", "铜卡", "银卡", "金卡", "钻卡", "城市合伙人"
]

public let levelNames2: [String] = [
    "", "升级为铜卡会员", "升级为银卡会员", "升级为金卡会员", "升级为钻卡会员", "升级为城市合伙人会员"
]

let upgradeImages: [UIImage] = [
    ImageAsset.my_upgrade_bronze.image,
    ImageAsset.my_upgrade_silver.image,
    ImageAsset.my_upgrade_gold.image,
    ImageAsset.my_upgrade_supreme.image,
]

//h.g.n -> checking extension of Images
public func checkImgExtention(imageURL: String) -> UIImage {
    
    let index = imageURL.index(imageURL.endIndex, offsetBy: -3)
    let extString = imageURL[index...]
    var image: UIImage!
    
    if extString == "gif" {
        image = UIImage.gifImageWithURL(imageURL)
        
    } else {
        let url = URL(string: imageURL)
        let data = try? Data(contentsOf: url!)
        
        if let imageData = data {
            image = UIImage(data: imageData)
        }
    }

    if image != nil {
        return image
        
    } else {
        return UIImage.init()
    }

}


class Utils {
    
    class func isIphoneX() -> Bool {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            let screenSize = UIScreen.main.bounds.size
            if screenSize.height >=  812.0 {
                return true
            }
        }
        return false
    }
    
    class func isIpad() -> Bool {
        if Device.type == .pad {
            return true
        }
        return false
    }
    
    class func getButtonBarFontSize() -> CGFloat {
        var fontSize: CGFloat = 13
        if Utils.isIpad() {
            fontSize = 17
        }
        return fontSize
    }
    
    class func applyTouchEffect(_ target: UIView) {
        target.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            target.alpha = 1.0
        }
    }
    
    class func parseStringToArray(_ string: String) -> [String] {
        let json = JSON(parseJSON: string)
        var stringArray: [String] = []
        if json.arrayObject != nil {
            stringArray = json.arrayObject as! [String]
        }
        
        return stringArray        
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts decimal degrees to radians              ///
    ///////////////////////////////////////////////////////////////////////
    class func deg2rad(_ deg:Double) -> Double {
        return deg * Double.pi / 180
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    class func rad2deg(_ rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }
    
    class func distanceFromLatLon(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta))
        dist = acos(dist)
        dist = rad2deg(dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    class func getNickName() -> String {
        var nickName = UserInstance.nickname!
        let phoneNumber = UserInstance.loginName!
        
        if nickName.isEmpty && phoneNumber.count > 6 {
            
            let startIndex = phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)
            let startString = phoneNumber[..<startIndex]
            
            let endIndex = phoneNumber.index(phoneNumber.endIndex, offsetBy: -3)
            let endString = phoneNumber[endIndex...]
            
            nickName = startString + "****" + endString
        }
        return nickName
    }
    
    class func getNickNameFromPhoneNumber(_ phoneNumber: String) -> String {
        let startIndex = phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)
        let startString = phoneNumber[..<startIndex]
        
        let endIndex = phoneNumber.index(phoneNumber.endIndex, offsetBy: -3)
        let endString = phoneNumber[endIndex...]
        
        let nickName = startString + "****" + endString
        return String(nickName)
    }
    
    class func getObjectKeyFromImageUrl(_ imageUrl: String) -> String {
        let indexStartOfText = imageUrl.index(imageUrl.startIndex, offsetBy: Constants.ALIYUN_URL_PREFIX.count)
        return String(imageUrl[indexStartOfText...])
    }
    
    class func getObjectKeysFromImageUrls(_ imageUrls: [String]) -> [String] {
        var objectKeys = [String]()
        for imageUrl in imageUrls {
            let indexStartOfText = imageUrl.index(imageUrl.startIndex, offsetBy: Constants.ALIYUN_URL_PREFIX.count)
            objectKeys.append(String(imageUrl[indexStartOfText...]))
        }
        return objectKeys
    }
    
    class func getImageSizeFromUrl(_ urlString: String) -> [Int] {
        var width: Int = 0
        var height: Int = 0
        //http://192.168.0.100/paishop/storage/app/public/item/e66da07c1372f15595b7776be38582c1_720x1280.jpg
        let imageInfos = urlString.split(separator: "_")
        if imageInfos.count > 1 {
            let sizeUrl1 = imageInfos.last!
            let sizeUrls = sizeUrl1.split(separator: ".")
            if sizeUrls.count > 1 {
                let sizeUrl = sizeUrls.first!
                if sizeUrl.contains("x") {
                    let sizes = sizeUrl.split(separator: "x")
                    if sizes.count == 2 {
                        width = Int(sizes[0])!
                        height = Int(sizes[1])!
                    }
                }
            }
        }
        
        return [width, height]        
    }
    
    class func getResizedImageUrlString(_ urlString: String, width: String) -> String {
        let widthString = "w_" + width
        let resizeUrlString = urlString + Constants.ALIYUN_IMAGE_RESIZE_PRIFIX + widthString
        return resizeUrlString
    }
    
    
}




let PAISHOP_PERIODS_TABLE: [String] = [
    "1177", "600", "408", "312", "254", "216", "188", "168", "152", "139",
    "128", "120", "112", "106", "100", "96", "91", "88", "84", "81",
    "78", "76", "74", "72", "70", "68", "66", "65", "63", "62",
    "61", "60", "59", "57", "57", "56", "55", "54", "53", "52",
    "52", "51", "50", "50", "49", "49", "48", "48", "47", "47",
    "46", "46", "45", "45", "45", "44", "44", "43", "43", "43",
    "42", "42", "42", "42", "41", "41", "41", "41", "40", "40",
    "40", "40", "39", "39", "39", "39", "39", "38", "38", "38",
    "38", "38", "37", "37", "37", "37", "37", "37", "37", "36",
    "36", "36", "36", "36", "36", "36", "35", "35", "35", "35",
]









