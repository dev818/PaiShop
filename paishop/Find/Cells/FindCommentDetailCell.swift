//
//  FindCommentDetailCell.swift
//  paishop
//
//  Created by Admin on 8/23/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FindCommentDetailCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setInfo(dic: NSDictionary) {
        print(">>> dic:", dic)

        var user = NSDictionary()
        var strImage = String()
        var strName = String()
        var strCreatedAt = String()
        var strText = String()
        
        if dic["user"] != nil {
            user = dic["user"] as! NSDictionary
            
            if user["image"] != nil {
                strImage = user["image"] as! String
            } else {
                strImage = ""
            }
            
            if user["name"] != nil {
                strName = user["name"] as! String
            } else {
                strName = ""
            }
        }
        
        if dic["created_at"] != nil {
            strCreatedAt = dic["created_at"] as! String
        } else {
            strCreatedAt = ""
        }
        
        if dic["text"] != nil {
            strText = dic["text"] as! String
            strText = strText.replacingOccurrences(of: "some(\"", with: "")
            strText = strText.replacingOccurrences(of: "\")", with: "")
        } else {
            strText = ""
        }
        
        nameLabel.text = strName
        let resizedUrl = Utils.getResizedImageUrlString(strImage, width: "400")
        avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        dateLabel.text = self.getFormattedDateString(strCreatedAt)
        descriptionLabel.text = strText
//        lblView.text = String(format: "浏览 %li", dicFeature["views"] as! NSInteger)
//        lblComment.text = String(format: "%li", dicFeature["comment_count"] as! NSInteger)
//        lblLike.text = String(format: "%li", dicFeature["like_count"] as! NSInteger)
        
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
        
    }
}
