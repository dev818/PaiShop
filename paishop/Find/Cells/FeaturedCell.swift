//
//  FeaturedCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Alamofire

protocol FeaturedCellDelegate: class {
    func didTapButtonFeaturedCellFavorite()
    func didTapButtonFeaturedCellLike()
    func didTapButtonFeaturedCellDelete()
    func didTapButtonFeaturedCellActive()
}

class FeaturedCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate:FeaturedCellDelegate?
    
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var collectionList: UICollectionView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
        
    @IBOutlet var imageViewList: [UIImageView]!
    @IBOutlet weak var likeImgView: UIImageView!
    @IBOutlet weak var freqFindButton: RoundRectButton!
    
    @IBOutlet weak var lblView: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    
    
    var likeBtnStatus = true
    var parentVC: FindVC!
    var arrayImage = NSArray()
    
    var dicPost = NSDictionary()
    
    var isFavorited: Bool = false
    var isLiked: Bool = false
    var isReported: Bool = false
    var isActived: Bool = false
    var showAuthor: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(_ vc: FindVC) {
        self.parentVC = vc
        if parentVC.selectedTabIndex == 1 || parentVC.selectedTabIndex == 2 || parentVC.selectedTabIndex == 3 {
            freqFindButton.borderColor = UIColor.magenta
            freqFindButton.setTitleColor(.magenta, for: .normal)
            freqFindButton.setTitle("已关注", for: .normal)
        } else if parentVC.selectedTabIndex == 5 {
            freqFindButton.borderColor = UIColor.gray
            freqFindButton.setTitleColor(.gray, for: .normal)
            freqFindButton.setTitle("私密", for: .normal)
        }
        
        // collectionView
        collectionList.delegate = self
        collectionList.dataSource = self
        collectionList.isScrollEnabled = true
        collectionList.allowsSelection = false
        collectionList.register(UINib.init(nibName: "MediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaCollectionViewCell")
        
        arrayImage = NSArray.init()
        
        // count
        lblView.text = "0"
        lblComment.text = "0"
        lblLike.text = "0"
        
    }
    
    func setCellContent(_ model: FeaturedModel) {
        let resizedUrl = Utils.getResizedImageUrlString((model.user?.image)!, width: "400")
        self.avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.nameLabel.text = model.user?.name
        self.dateLabel.text = self.getFormattedDateString(model.createdAt!)
        descriptionLabel.text = model.text
        
        collectionList.reloadData()
    }
    
    func setInfo(dic: NSDictionary) {
        dicPost = NSDictionary.init(dictionary: dic)
        
        let strArrayImage = dic["images"] as! String
        do {
            let data  = try JSONSerialization.jsonObject(with: strArrayImage.data(using: .utf8)!, options: .allowFragments) as? NSArray

            arrayImage = NSArray.init(array: data!)
            arrayImage = data!
            collectionList.reloadData()
        }
        catch {
        }
        
        var strName = String()
        var strPhoto = String()
        var strCreatedAt = String()
        var strText = String()
        var arrayLike = NSArray()
        var arrayFavorite = NSArray()
        var arrayReport = NSArray()

        if dic["user"] != nil {
            let user = dic["user"] as! NSDictionary
            
            if user["name"] != nil {
                strName = user["name"] as! String
            } else {
                strName = ""
            }
            
            if user["image"] != nil {
                strPhoto = user["image"] as! String
            } else {
                strPhoto = ""
            }

        } else {
            strName = UserInstance.nickname!
            strPhoto = UserInstance.avatar!
        }
        
        if dic["created_at"] != nil {
            strCreatedAt = dic["created_at"] as! String
        } else {
            strCreatedAt = ""
        }

        if dic["text"] != nil {
            strText = dic["text"] as! String
        } else {
            strText = ""
        }
        
        // like
        if dic["like"] is NSNull {
            isLiked = false
            
        } else {
            arrayLike = dic["like"] as! NSArray
            if arrayLike.count > 0 {
                for dicLike in arrayLike {
                    if (dicLike as! NSDictionary)["user_id"] as? Int == UserInstance.userId {
                        isLiked = true
                        break
                        
                    } else {
                        isLiked = false
                    }
                }
            } else {
                isLiked = false
            }
        }
        
        self.setLikeButton()
        
        // favorite
        if dic["favorite"] is NSNull {
            isFavorited = false
            
        } else {
            arrayFavorite = dic["favorite"] as! NSArray
            if arrayFavorite.count > 0 {
                for dicFavorite in arrayFavorite {
                    if (dicFavorite as! NSDictionary)["user_id"] as? Int == UserInstance.userId {
                        isFavorited = true
                        break
                        
                    } else {
                        isFavorited = false
                    }
                }
            } else {
                isFavorited = false
            }
        }

        self.setFavoriteButton()
        
        // report
        if dic["report"] is NSNull {
            isReported = false
            
        } else {
            arrayReport = dic["report"] as! NSArray
            if arrayReport.count > 0 {
                for dicReport in arrayReport {
                    if (dicReport as! NSDictionary)["user_id"] as? Int == UserInstance.userId {
                        isReported = true
                        break
                        
                    } else {
                        isReported = false
                    }
                }
            } else {
                isReported = false
            }
        }

        // active
        if dic["deleted_at"] is NSNull {
            isActived = true
        } else {
            isActived = false
        }
        
        self.setActiveButton()
        
        nameLabel.text = strName
        let resizedUrl = Utils.getResizedImageUrlString(strPhoto, width: "400")
        avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        dateLabel.text = self.getFormattedDateString(strCreatedAt)
        descriptionLabel.text = strText
        lblView.text = String(format: "%li", dic["views"] as! NSInteger)
        lblComment.text = String(format: "%li", dic["comment_count"] as! NSInteger)
        lblLike.text = String(format: "%li", dic["like_count"] as! NSInteger)
     
        
        nameLabel.setNeedsDisplay()
        avatarImageView.setNeedsDisplay()
        dateLabel.setNeedsDisplay()
        descriptionLabel.setNeedsDisplay()
        lblView.setNeedsDisplay()
        lblComment.setNeedsDisplay()
        lblLike.setNeedsDisplay()
        freqFindButton.setNeedsDisplay()
    }

    
    @IBAction func dropdownTapped(_ sender: Any) {
        if parentVC.selectedTabIndex == 1 || parentVC.selectedTabIndex == 2 || parentVC.selectedTabIndex == 3 {
            self.mainPageDropdown()
        } else if parentVC.selectedTabIndex == 5 {
            self.myPageDropdown()
        }
    }
    
    func mainPageDropdown() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var titleFavorite = ""
        var titleReport = ""

        if isFavorited == true {
            titleFavorite = "取消关注"
        } else {
            titleFavorite = "关注"
        }
        
        if isReported == true {
            titleReport = "取消举报"
        } else {
            titleReport = "举报"
        }
        
        let addOrRemoveFind = UIAlertAction(title: titleFavorite, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addOrRemoveFavorite()

        })
        
        if isFavorited == true {
            addOrRemoveFind.setValue(UIColor.red, forKey: "titleTextColor")
        } else {
            addOrRemoveFind.setValue(UIColor.darkGray, forKey: "titleTextColor")
        }
        
        let cutUserContent = UIAlertAction(title: "屏蔽动态", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.cutUserContent()
        })
        cutUserContent.setValue(UIColor.darkGray, forKey: "titleTextColor")
        
        let reportContent = UIAlertAction(title: titleReport, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addOrRemoveReport()
        })
        
        if isReported == true {
            reportContent.setValue(UIColor.red, forKey: "titleTextColor")
        } else {
            reportContent.setValue(UIColor.darkGray, forKey: "titleTextColor")
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.darkGray, forKey: "titleTextColor")
        
        sheet.addAction(addOrRemoveFind)
        sheet.addAction(cutUserContent)
        sheet.addAction(reportContent)
        sheet.addAction(cancelAction)
        
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView =  self.parentVC.view
            popoverController.sourceRect = CGRect(x:  self.parentVC.view.bounds.midX, y:  self.parentVC.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.parentVC.present(sheet, animated: true, completion: nil)
    }
    
    func myPageDropdown() {
        var titleActive = ""
        
        if isActived == true {
            titleActive = "私密"
        } else {
            titleActive = "公开"
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let addOrRemoveFind = UIAlertAction(title: "编辑", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.editMyContent()
        })
        addOrRemoveFind.setValue(UIColor.darkGray, forKey: "titleTextColor")
        
        let cutUserContent = UIAlertAction(title: titleActive, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.secretMyContent()
        })
        cutUserContent.setValue(UIColor.darkGray, forKey: "titleTextColor")
        
        let reportContent = UIAlertAction(title: "册除", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.deletMyContent()
        })
        reportContent.setValue(UIColor.darkGray, forKey: "titleTextColor")
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.darkGray, forKey: "titleTextColor")
        
        sheet.addAction(addOrRemoveFind)
        sheet.addAction(cutUserContent)
        sheet.addAction(reportContent)
        sheet.addAction(cancelAction)
        
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView =  self.parentVC.view
            popoverController.sourceRect = CGRect(x:  self.parentVC.view.bounds.midX, y:  self.parentVC.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.parentVC.present(sheet, animated: true, completion: nil)
        
    }
    
    private func addOrRemoveFind() {
        freqFindButton.isHidden = false
    }
    
    private func cutUserContent() {
        let parameters: Parameters = [
            "author_id": dicPost["user_id"] as! NSInteger
        ]
        
        // hide authoe
        ProgressHUD.showWithStatus()
        FindAPI.shared.hideAuthor(params: parameters) { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                
                ProgressHUD.showSuccessWithStatus("屏蔽动态成功！")
                
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
    }
    
    private func reportContent() {
        
    }
    
    private func editMyContent() {
        
    }
    
    private func secretMyContent() {
        let parameters: Parameters = [
            "post": dicPost["id"] as! NSInteger
        ]
        
        if isActived == true {
            // inActive
            ProgressHUD.showWithStatus()
            FindAPI.shared.postInActive(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    
                    self.isActived = !self.isActived
                    self.setActiveButton()
                    ProgressHUD.showSuccessWithStatus("私密成功！")
                    
                    self.delegate?.didTapButtonFeaturedCellActive()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
            }
        
        } else {
            // active
            ProgressHUD.showWithStatus()
            FindAPI.shared.postActive(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()

                    self.isActived = !self.isActived
                    self.setActiveButton()
                    ProgressHUD.showSuccessWithStatus("公开成功！")
                    self.delegate?.didTapButtonFeaturedCellActive()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
            }

        }
        
    }
    
    private func deletMyContent() {
        let parameters: Parameters = [
            "post": dicPost["id"] as! NSInteger
        ]
        
        // delete
        ProgressHUD.showWithStatus()
        FindAPI.shared.postDelete(params: parameters) { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                ProgressHUD.showSuccessWithStatus("册除成功！")
                
                self.delegate?.didTapButtonFeaturedCellDelete()
                
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
        
        
    }
    
    func addOrRemoveFavorite() {
        let parameters: Parameters = [
            "id": dicPost["id"] as! NSInteger
        ]

        if isFavorited == true {
            // remove favorite
            ProgressHUD.showWithStatus()
            FindAPI.shared.removeFavorite(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    
                    self.isFavorited = !self.isFavorited
                    self.setFavoriteButton()
                    ProgressHUD.showSuccessWithStatus("成功！")

                    // request get favorite
                    self.delegate?.didTapButtonFeaturedCellFavorite()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
            }
            
        } else {
            // add favorite
            ProgressHUD.showWithStatus()
            FindAPI.shared.addFavorite(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    
                    self.isFavorited = !self.isFavorited
                    self.setFavoriteButton()
                    ProgressHUD.showSuccessWithStatus("关注成功！")

                    // request get favorite
                    self.delegate?.didTapButtonFeaturedCellFavorite()

                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
            }
            
        }
        
    }
    
    
    func addOrRemoveReport() {
        let parameters: Parameters = [
            "id": dicPost["id"] as! NSInteger
        ]
        
        if isReported == true {
            // remove favorite
            ProgressHUD.showWithStatus()
            FindAPI.shared.removeReport(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    ProgressHUD.showSuccessWithStatus("成功！")
                    self.isReported = !self.isReported
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
            }
            
        } else {
            // add report
            ProgressHUD.showWithStatus()
            FindAPI.shared.addReport(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    ProgressHUD.showSuccessWithStatus("举报成功！")

                    self.isReported = !self.isReported
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
            }
            
        }
        
    }
    
    func setFavoriteButton() {
        if parentVC.selectedTabIndex <= 3 {
            if isFavorited == true {
                self.freqFindButton.isHidden = false
                self.freqFindButton.isEnabled = true
                
            } else {
                self.freqFindButton.isHidden = true
                self.freqFindButton.isEnabled = false
            }
        }
    }
    
    func setActiveButton() {
        if parentVC.selectedTabIndex == 5 {
            if isActived == true {
                self.freqFindButton.isHidden = true
                self.freqFindButton.isEnabled = false
                
            } else {
                self.freqFindButton.isHidden = false
                self.freqFindButton.isEnabled = true
            }
        }
    }
    
    func setLikeButton() {
        if isLiked == true {
            likeImgView.image = UIImage.init(named: "find_like_red.png")
        } else {
            likeImgView.image = UIImage.init(named: "find_dislike.png")
        }
    }
    
    @IBAction func disableFindBtn(_ sender: Any) {
        let parameters: Parameters = [
            "id": dicPost["id"] as! NSInteger
        ]
        
        if parentVC.selectedTabIndex <= 3 {
            
            ProgressHUD.showWithStatus()
            FindAPI.shared.addFavorite(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    
                    self.isFavorited = !self.isFavorited
                    self.setFavoriteButton()
                    ProgressHUD.showSuccessWithStatus("关注成功！")
                    
                    self.delegate?.didTapButtonFeaturedCellFavorite()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }

            }


        } else if parentVC.selectedTabIndex == 5 {
            
            ProgressHUD.showWithStatus()
            FindAPI.shared.postActive(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    
                    self.isActived = !self.isActived
                    self.setActiveButton()
                    ProgressHUD.showSuccessWithStatus("成功！")
                    
                    self.delegate?.didTapButtonFeaturedCellActive()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
                
            }
            
        }
        
        
        
    }
    

    
    @IBAction func likeBtnTapped(_ sender: Any) {
        let cntLike = Int(lblLike.text!)

        let parameters: Parameters = [
            "id": dicPost["id"] as! NSInteger
        ]
        
        if isLiked == true {
            // remove like
            ProgressHUD.showWithStatus()
            FindAPI.shared.removeLike(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    self.isLiked = !self.isLiked;
                    self.setLikeButton()
                    
                    self.lblLike.text = String(format: "%li", cntLike! - 1)
                    self.delegate?.didTapButtonFeaturedCellLike()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
                
            }
            
        } else {
            // add like
            ProgressHUD.showWithStatus()
            FindAPI.shared.addLike(params: parameters) { (dic, success) in
                if success == true {
                    ProgressHUD.dismiss()
                    self.isLiked = !self.isLiked;
                    self.setLikeButton()
                    
                    self.lblLike.text = String(format: "%li", cntLike! + 1)
                    self.delegate?.didTapButtonFeaturedCellLike()
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
                
            }
        }
        
        
    }
    
    
    private func getFormattedDateString(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: dateString)!
        let timeAgo = Date.timeAgoSinceDate(date, numericDates: true)
        
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([
            NSCalendar.Unit.minute,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.day,
            NSCalendar.Unit.weekOfYear,
            NSCalendar.Unit.month,
            NSCalendar.Unit.year,
            NSCalendar.Unit.second
            ], from: date)
        
        let dateString = timeAgo + "  " + String(components.month!) + "月" + String(components.day!) + "日  " + String(components.hour!) + ":" + String(components.minute!)
        return dateString
    }
    
    // collection view datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayImage.count > 0 {
            if arrayImage.count > 6 {
                return 6
            } else {
                return arrayImage.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCollectionViewCell", for: indexPath) as! MediaCollectionViewCell
        
        if arrayImage.count > 0 {
            if arrayImage[indexPath.row] is NSDictionary {
                cell.setInfo(model: arrayImage[indexPath.row] as! NSDictionary)
                cell.setNeedsDisplay()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionList.bounds.size.width
        let collectionHeight = collectionList.bounds.size.height
        
        let wi = (collectionWidth - 2 * 4) / 3
        let he = collectionHeight
        
        return CGSize(width: wi, height: he)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }


}


















