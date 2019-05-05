//
//  NearbyStoreDetailTopCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MonkeyKing
import XLActionController
import MapKit

class NearbyStoreDetailTopCell: UITableViewCell {

    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var storeOpeningLabel: UILabel!
    @IBOutlet weak var storeAddressLabel: UILabel!
    @IBOutlet weak var favorImageView: UIImageView!
    
    @IBOutlet weak var NavFrameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var navFrameTopConstraint: NSLayoutConstraint!
    
    
    var parentVC: NearbyStoreDetailVC!
    var storeDetail: StoreDetailModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if Utils.isIphoneX() {
            NavFrameHeightConstraint.constant = 88
            topConstraint.constant = -44
            navFrameTopConstraint.constant = -44
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCellContent(_ store: StoreDetailModel, vc: NearbyStoreDetailVC) {
        self.parentVC = vc
        self.storeDetail = store
        
        if let storeUrl = storeDetail.image, storeUrl != "" {
            let resizedUrl = Utils.getResizedImageUrlString(storeUrl, width: "800")
            storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        }
        storeNameLabel.text = storeDetail.name
        viewsLabel.text = "浏览" + String(storeDetail.views!)
        storeOpeningLabel.text = storeDetail.opening
        storeAddressLabel.text = storeDetail.address
        if storeDetail.address!.isEmpty {
            storeAddressLabel.text = storeDetail.user?.address
        }
        
        if storeDetail.favorites! > 0 {
            favorImageView.image = UIImage(named: "ic_home_star_filled")
        } else {
            favorImageView.image = UIImage(named: "ic_home_star")
        }
    }
    
    @IBAction func selectBack(_ sender: UIButton) {
        if self.parentVC.senderVC != nil {
            let info: [String : Any] = [
                "senderVC" : self.parentVC.senderVC!,
                "senderIndex" : self.parentVC.senderIndex,
                "storeDetail" : self.storeDetail
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.STORE_DETAIL_CHANGE), object: nil, userInfo: info)
        }
        
        self.parentVC.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectFavor(_ sender: UIButton) {
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录!")
            return
        }
        
        if Int64(UserInstance.storeId!) == self.storeDetail.storeId! {
            ProgressHUD.showSuccessWithStatus("这是你的商店!")
            return
        }
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : self.storeDetail.storeId!
        ]
        if storeDetail.favorites! > 0 {
            /*HomeAPI.shared.storeFavoriteDelete(params: parameters, completion: { (json, success) in
             if success {
             print("Store Favorite Delete...")
             print(json)
             self.storeDetail.favorites = 0
             self.favorLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
             self.favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
             } else {
             // try again...
             HomeAPI.shared.storeFavoriteDelete(params: parameters, completion: { (json, success1) in
             if success1 {
             self.storeDetail.favorites = 0
             self.favorLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
             self.favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
             }
             })
             }
             })*/
        } else {
            sender.isEnabled = false
            ProgressHUD.showWithStatus()
            HomeAPI.shared.storeFavoriteAdd(params: parameters) { (json, success) in
                sender.isEnabled = true
                ProgressHUD.dismiss()
                if success {
                    print("Store Favorite Add...")
                    print(json)
                    self.storeDetail.favorites = 1
                    self.favorImageView.image = UIImage(named: "ic_home_star_filled")
                } else {
                    let errors = json["errors"].dictionaryValue
                    if let error = errors.values.first {
                        if let firstError =  error.arrayObject?.first as? String {
                            ProgressHUD.showErrorWithStatus(firstError)
                        } else {
                            ProgressHUD.showErrorWithStatus("失败.")
                        }
                    } else {
                        ProgressHUD.showErrorWithStatus("失败.")
                    }
                }
            }
        }
    }
    
    @IBAction func selectShare(_ sender: UIButton) {
        MonkeyKing.registerAccount(.weChat(appID: "wx987358b52f62b2ad", appKey: "e215123acf16ce7cee560820fdad895e", miniAppID: nil))
        let shareText = storeDetail.name!
        //let deepLinkString = "paishop://store/\(storeId!)"
        let deepLinkString = "http://paikepaifu.cn/share?store=\(parentVC.storeId!)"
        
        let deepLinkUrl = URL.init(string: deepLinkString)!
        let info = MonkeyKing.Info(
            title: shareText,
            description: storeDetail.introduction,
            thumbnail: nil,
            media: .url(deepLinkUrl)//.image(UIImage(named: "wechat_timeline")!)//nil
        )
        let sessionMessage = MonkeyKing.Message.weChat(.session(info: info))
        let weChatSessionActivity = AnyActivity(
            type: UIActivity.ActivityType(rawValue: "com.longcai.paishop.WeChat.Session"),
            title: NSLocalizedString("微信", comment: ""),
            image: UIImage(named: "wechat_session")!,
            message: sessionMessage) { (success) in
                print("Session success: \(success)")
        }
        let vc = UIActivityViewController(activityItems: [shareText, deepLinkUrl], applicationActivities: [weChatSessionActivity])
        if let popoverController = vc.popoverPresentationController {
            popoverController.sourceView = self.parentVC.view
            popoverController.sourceRect = CGRect(x: self.parentVC.view.bounds.midX, y: self.parentVC.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.parentVC.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func selectRoute(_ sender: UIButton) {
        if self.parentVC.userLocationCoordinate == nil {
            ProgressHUD.showWarningWithStatus("无法获得您的位置!")
            return
        }
        
        let actionController = PeriscopeActionController()
        actionController.addAction(Action.init("通过苹果地图导航", style: .default, handler: { (action) in
            let coordinate = CLLocationCoordinate2D(latitude: self.storeDetail.lat!, longitude: self.storeDetail.lng!)
            let regionDistance: CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue.init(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue.init(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.storeDetail.name
            mapItem.openInMaps(launchOptions: options)
        }))
        actionController.addAction(Action.init("通过百度地图导航", style: .default, handler: { (action) in
            let urlString = String.init(format: "baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&rc=cab", self.parentVC.userLocationCoordinate.latitude, self.parentVC.userLocationCoordinate.longitude, self.storeDetail.lat!, self.storeDetail.lng!)
            //let urlString = String.init(format: "baidumap://map/direction?origin=%f,%f&destination=latlng:%f,%f|name=target&mode=driving", self.userLocationCoordinate.latitude, self.userLocationCoordinate.longitude, self.markerLat, self.markerLon)
            let url = URL.init(string: urlString)
            if url != nil {
                print("URL...", url!)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    ProgressHUD.showWarningWithStatus("请安装百度地图应用程序!")
                }
            }
        }))
        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action("取消", style: .cancel, handler:nil))
        
        self.parentVC.present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func selectMap(_ sender: UIButton) {
        let latitude = storeDetail.lat!
        let longitude = storeDetail.lng!
        if latitude != 0.0 && longitude != 0.0 {
            let guideMapVC = UIStoryboard(name: "Guide", bundle: nil).instantiateViewController(withIdentifier: GuideMapVC.nameOfClass) as! GuideMapVC
            guideMapVC.markerName = storeDetail.name!
            guideMapVC.markerLat = latitude
            guideMapVC.markerLon = longitude
            guideMapVC.makerDescription = storeDetail.introduction
            guideMapVC.storeImage = storeDetail.image
            guideMapVC.storeId = storeDetail.storeId!
            guideMapVC.isFromStoreDetail = true
            guideMapVC.degree = storeDetail.user?.degreeId
            self.parentVC.navigationController?.pushViewController(guideMapVC, animated: true)
        }
    }
    
    @IBAction func selectPhone(_ sender: UIButton) {
        if storeDetail.user?.id == UserInstance.userId {
            return
        }
        let phoneString = storeDetail.phoneNumber
        if let phoneStr = phoneString, !phoneStr.isEmpty {
            if let phoneCallURL:URL = URL(string: "tel://\(phoneStr)") {
                print("call phone=\(phoneStr)")
                let application:UIApplication = UIApplication.shared
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
}
