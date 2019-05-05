//
//  FindContentDetailVC.swift
//  paishop
//
//  Created by Admin on 8/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
import Alamofire

class FindContentDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!    
    
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!    
    @IBOutlet weak var lblView: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var collectionList: UICollectionView! {
        didSet {
            collectionList.delegate = self
            collectionList.dataSource = self
            collectionList.isScrollEnabled = true
            collectionList.allowsSelection = false
            collectionList.register(UINib.init(nibName: "MediaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaCollectionViewCell")
        }
    }
    @IBOutlet weak var contentImg1: UIImageView!
    @IBOutlet weak var contentImg2: UIImageView!
    @IBOutlet weak var contentImg3: UIImageView!
    @IBOutlet var imageViewList: [UIImageView]!
    
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentViewHConstraint: NSLayoutConstraint! {
        didSet {
            commentViewHConstraint.constant = 50
        }
    }
    @IBOutlet weak var writeCommentTextView: UITextView! {
        didSet {
            writeCommentTextView.isHidden = true
        }
    }
    @IBOutlet weak var saveCommentButton: RoundRectButton! {
        didSet {
            saveCommentButton.isHidden = true
        }
    }
    
    @IBOutlet weak var commentsTableView: UITableView! {
        didSet {
            commentsTableView.ts_registerCellNib(FindCommentDetailCell.self)
            commentsTableView.rowHeight = UITableView.automaticDimension
            commentsTableView.estimatedRowHeight = 100
            commentsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            //commentsTableView.isEditing = true
            //commentsTableView.isUserInteractionEnabled = true
        }
    }
    
    var model: FeaturedModel!
    var dicFeature = NSDictionary()
    var showCommentTextView = false
    var isLiked: Bool = false
    
    var arrayImage = NSArray()
    
    var arrayComment = NSArray()
    var arrayLike = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setUserInfo()
        requestAddView(postId: dicFeature["id"] as! NSInteger)
        requestGetComments(postId: dicFeature["id"] as! NSInteger)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "精选"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    func setupUI(_ model: FeaturedModel) {
        let resizedUrl = Utils.getResizedImageUrlString((model.user?.image)!, width: "400")
        self.userProfileImg.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.userNameLabel.text = model.user?.name
        self.dateLabel.text = self.getFormattedDateString(model.createdAt!)
        self.descriptionLabel.text = model.text

        collectionList.reloadData()
    }
    
    func setUserInfo() {
        let strArrayImage = dicFeature["images"] as! String
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
        
        if dicFeature["user"] != nil {
            let user = dicFeature["user"] as! NSDictionary
            
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
            strPhoto = ""
        }
        
        if dicFeature["created_at"] != nil {
            strCreatedAt = dicFeature["created_at"] as! String
        } else {
            strCreatedAt = ""
        }
        
        if dicFeature["text"] != nil {
            strText = dicFeature["text"] as! String
        } else {
            strText = ""
        }
        
        // like
        if dicFeature["like"] is NSNull {
            isLiked = false
            
        } else {
            arrayLike = dicFeature["like"] as! NSArray
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
        
        userNameLabel.text = strName
        let resizedUrl = Utils.getResizedImageUrlString(strPhoto, width: "400")
        userProfileImg.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        dateLabel.text = self.getFormattedDateString(strCreatedAt)
        descriptionLabel.text = strText
        lblView.text = String(format: "浏览 %li", dicFeature["views"] as! NSInteger)
        lblComment.text = String(format: "%li", dicFeature["comment_count"] as! NSInteger)
        lblLike.text = String(format: "%li", dicFeature["like_count"] as! NSInteger)

    }
    
    func setLikeButton() {
        if isLiked == true {
            likeImage.image = UIImage.init(named: "find_like_red.png")
        } else {
            likeImage.image = UIImage.init(named: "find_dislike.png")
        }
        
        likeImage.setNeedsDisplay()
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
    
    @IBAction func likeBtnTapped(_ sender: UIButton) {
        let cntLike = Int(lblLike.text!)
        
        let parameters: Parameters = [
            "id": dicFeature["id"] as! NSInteger
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
                    
                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
                
            }
        }
        
    }
    
    @IBAction func commentBtnTapped(_ sender: UIButton) {
        showCommentTextView = !showCommentTextView
        writeCommentTextView.isHidden = !writeCommentTextView.isHidden
        saveCommentButton.isHidden = !saveCommentButton.isHidden
        if showCommentTextView {
            commentViewHConstraint.constant = 171
        } else {
            commentViewHConstraint.constant = 50
        }
        
    }
    
    @IBAction func commentSave(_ sender: UIButton) {
        if writeCommentTextView.text.count == 0 {
            ProgressHUD.showErrorWithStatus("失败.")
        } else {
            
            // create comment
            let parameters: Parameters = [
                "id": dicFeature["id"] as! NSInteger,
                "text": writeCommentTextView.text
            ]
            
            ProgressHUD.showWithStatus()
            FindAPI.shared.createComment(params: parameters) { (dic, success) in
                ProgressHUD.dismiss()
                
                if success == true {
                    print(">>> add View:", dic)
                    ProgressHUD.showSuccessWithStatus("成功！")

                    self.writeCommentTextView.text = ""
                    
                    // hidden comment text view
                    self.writeCommentTextView.isHidden = true
                    self.saveCommentButton.isHidden = true
                    self.commentViewHConstraint.constant = 50

                    // get comments
                    self.requestGetComments(postId: self.dicFeature["id"] as! NSInteger)

                } else {
                    ProgressHUD.showErrorWithStatus("失败.")
                }
                
            }
            
        }
        
        
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

    // MARK: - request
    func requestAddView(postId: NSInteger) {
        let parameters: Parameters = [
            "id": postId
        ]
        
        FindAPI.shared.addView(params: parameters) { (dic, success) in
            if success == true {
                print(">>> add View:", dic)
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
    }
    
    func requestGetComments(postId: NSInteger) {
        let parameters: Parameters = [
            "id": postId
        ]
        
        ProgressHUD.showWithStatus()
        FindAPI.shared.getComments(params: parameters) { (dic, success) in
            if success == true {
                ProgressHUD.dismiss()
                
                print(">>> dic:", dic)
                self.arrayComment = NSArray.init()
                
                if dic["data"] is NSNull || dic["data"] == nil {
                    
                } else {
                    self.arrayComment = dic["data"] as! NSArray
                    self.commentsTableView.reloadData()
                }
                
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
        
        self.commentsTableView.reloadData()
    }
    
}

extension FindContentDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FindContentDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayComment.count > 0 {
            return arrayComment.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FindCommentDetailCell = tableView.ts_dequeueReusableCell(FindCommentDetailCell.self)
        cell.setInfo(dic: arrayComment[indexPath.row] as! NSDictionary)

        return cell
    }    
    
}
