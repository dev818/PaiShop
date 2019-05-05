//
//  HomeStoreDetailTopCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import MonkeyKing
import XLActionController
import DropDown

protocol HomeStoreDetailTopCellDelegate {
    func didTapButtonHomeStoreDetailTopCell(index: NSInteger)
}

class HomeStoreDetailTopCell: UITableViewCell {
    
    var delegate: HomeStoreDetailTopCellDelegate?
    
    @IBOutlet weak var storeImageView: RoundRectImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var favorButton: RoundRectButton!
    
    @IBOutlet weak var btnTab1: UIButton!
    @IBOutlet weak var btnTab2: UIButton!
    @IBOutlet weak var btnTab3: UIButton!
    @IBOutlet weak var btnTab4: UIButton!
    @IBOutlet weak var btnTab5: UIButton!
    
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var lineView2: UIView!
    @IBOutlet weak var lineView3: UIView!
    @IBOutlet weak var lineView4: UIView!
    @IBOutlet weak var lineView5: UIView!
    
    var tab5DropDown: DropDown!
    
    var parentVC: HomeStoreDetailVC!
    var storeDetail: StoreDetailModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // tab
        btnTab1.tag = 1
        btnTab2.tag = 2
        btnTab3.tag = 3
        btnTab4.tag = 4
        btnTab5.tag = 5
        
        self.setSelectedTab(index: 1)
        setupTab5DropDown()

    }
    
    func setCellContent(_ store: StoreDetailModel, vc: HomeStoreDetailVC) {
        self.parentVC = vc
        self.storeDetail = store
        
        if let storeUrl = storeDetail.image, storeUrl != "" {
            let resizedUrl = Utils.getResizedImageUrlString(storeUrl, width: "200")
            storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        }
        storeNameLabel.text = storeDetail.name
        viewsLabel.text = "浏览" + String(storeDetail.views!)
        addressLabel.text = storeDetail.address
        if storeDetail.address!.isEmpty {
            addressLabel.text = storeDetail.user?.address
        }
        if storeDetail.favorites! > 0 {
            favorButton.setTitleColor(MainColors.themeEndColors[0], for: .normal)
            favorButton.borderColor = MainColors.themeEndColors[0]
        } else {
            favorButton.setTitleColor(MainColors.defaultSubTitle, for: .normal)
            favorButton.borderColor = MainColors.defaultSubTitle
        }
        
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
            ProgressHUD.showWithStatus()
            sender.isEnabled = false
            HomeAPI.shared.storeFavoriteDelete(params: parameters, completion: { (json, success) in
                ProgressHUD.dismiss()
                sender.isEnabled = true
                if success {
                    print("Store Favorite Delete...")
                    print(json)
                    self.storeDetail.favorites = 0
                    self.parentVC.storeDetail.favorites = 0
                    self.favorButton.setTitleColor(MainColors.defaultSubTitle, for: .normal)
                    self.favorButton.borderColor = MainColors.defaultSubTitle
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
            })
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
                    self.parentVC.storeDetail.favorites = 1
                    self.favorButton.setTitleColor(MainColors.themeEndColors[0], for: .normal)
                    self.favorButton.borderColor = MainColors.themeEndColors[0]
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
    
    @IBAction func selectLocation(_ sender: UIButton) {
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
    
    @IBAction func tapBtnTab(_ sender: UIButton) {
        let tag = sender.tag
        self.setSelectedTab(index: tag)
    }
    
    func setSelectedTab(index: Int) {
        lineView1.isHidden = true
        lineView2.isHidden = true
        lineView3.isHidden = true
        lineView4.isHidden = true
        lineView5.isHidden = true
        
        switch index {
        case 1:
            lineView1.isHidden = false
            break
        case 2:
            lineView2.isHidden = false
            break
        case 3:
            lineView3.isHidden = false
            break
        case 4:
            lineView4.isHidden = false
            break
        case 5:
            lineView5.isHidden = false
            if tab5DropDown != nil {
                self.tab5DropDown.show()
            }
            break
        default:
            break
        }
        
        self.delegate?.didTapButtonHomeStoreDetailTopCell(index: index)
    }
    
}
