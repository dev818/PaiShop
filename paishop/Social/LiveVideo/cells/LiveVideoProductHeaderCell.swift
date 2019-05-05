//
//  LiveVideoProductHeaderCell.swift
//  paishop
//
//  Created by SeniorCorder on 4/30/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LiveVideoProductHeaderCell: UITableViewCell {
    
    var store: StoreDetailModel!
    var playerVC: LiveVideoPlayerVC!
    var playBackVC: LiveVideoPlayBackVC!
    
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var degreeImageView: RoundImageView!
    
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var favorLabel: UILabel!
    @IBOutlet weak var favorPlusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPlayerCellContent(_ store: StoreDetailModel, playerVC: LiveVideoPlayerVC) {
        self.store = store
        self.playerVC = playerVC
        self.setCellContent(store)
    }
    
    func setPlayerBackCellContent(_ store: StoreDetailModel, playBackVC: LiveVideoPlayBackVC) {
        self.store = store
        self.playBackVC = playBackVC
        self.setCellContent(store)
    }
    
    private func setCellContent(_ store: StoreDetailModel) {
        let resizedUrl = Utils.getResizedImageUrlString(store.image!, width: "200")
        storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        storeNameLabel.text = store.name
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        let degreeId = store.user!.degreeId!
        degreeImageView.isHidden = true
        if degreeImages.count > 0 && degreeId > 0 {
            if degreeImages.count >= degreeId {
                degreeImageView.isHidden = false
                degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
            }
        }
        
        if store.favorites! > 0 {
            favorLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
            favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
        } else {
            favorLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
            favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0x686868)
        }
        
    }
    
    @IBAction func selectFavor(_ sender: UIButton) {
        Utils.applyTouchEffect(favorLabel)
        Utils.applyTouchEffect(favorPlusLabel)
        
        if !UserInstance.isLogin {
            ProgressHUD.showWarningWithStatus("你应该登录!")
            return
        }
        
        if Int64(UserInstance.storeId!) == self.store.storeId! {
            ProgressHUD.showSuccessWithStatus("这是你的商店!")
            return
        }
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : self.store.storeId!
        ]
        if store.favorites! > 0 {
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
                    self.store.favorites = 1
                    if self.playerVC != nil {
                        self.playerVC.videoModel.store?.favorites = 1
                    } else if self.playBackVC != nil {
                        self.playBackVC.videoModel.store?.favorites = 1
                    }
                    
                    self.favorLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
                    self.favorPlusLabel.textColor = UIColor.init(colorWithHexValue: 0xFF3E03)
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
    
    
}
