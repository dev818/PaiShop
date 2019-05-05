//
//  FindVideoCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FindVideoCell: UITableViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var durationBgView: RoundRectView! {
        didSet {
            durationBgView.isHidden = true
        }
    }
    @IBOutlet weak var durationLabel: UILabel! {
        didSet {
            durationLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var pinImageView: UIImageView! {
        didSet {
            pinImageView.setTintColor(UIColor.white)
        }
    }
    @IBOutlet weak var cityLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCellContent(_ model: LiveVideoModel) {
        let resizedVideoUrl = Utils.getResizedImageUrlString(model.image!, width: "800")
        videoImageView.setImageWithURLString(resizedVideoUrl, placeholderImage: ImageAsset.default_image.image)
        durationBgView.isHidden = true
        durationLabel.isHidden = true
        if model.live! {
            statusLabel.text = "直播中"
        } else {
            statusLabel.text = "回放"
            if model.duration! > 0 {
                durationBgView.isHidden = false
                durationLabel.isHidden = false
                durationLabel.text = getDurationString(model.duration!)
            }
        }
        let views = model.views!
        let viewsCount = "\(views)人"
        viewsLabel.text = viewsCount
        if let storeUrl = model.store?.image, storeUrl != "" {
            let resizedStoreUrl = Utils.getResizedImageUrlString(storeUrl, width: "100")
            businessImageView.setImageWithURLString(resizedStoreUrl, placeholderImage: ImageAsset.icon_store.image)
        }
        
        businessNameLabel.text = model.store?.name
        self.titleLabel.text = model.title
        cityLabel.text = model.store?.city?.name
    }
    
    func getFormattedDateString(_ string: String) -> String {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dataFormatter.date(from: string)
        
        return Date.messageAgoSinceDate(date!)
    }
    
    private func getDurationString(_ duration: Int) -> String {
        var hour = 0, minute = 0, second = 0
        var hourStr = "00", minuteStr = "00", secondStr = "00"
        hour = duration / 3600
        minute = (duration % 3600) / 60
        second = (duration % 3600 ) % 60
        if hour < 10 {
            hourStr = "0\(hour)"
        } else {
            hourStr = "\(hour)"
        }
        
        if minute < 10 {
            minuteStr = "0\(minute)"
        } else {
            minuteStr = "\(minute)"
        }
        
        if second < 10 {
            secondStr = "0\(second)"
        } else {
            secondStr = "\(second)"
        }
        
        if hour > 0 {
            return hourStr + ":" + minuteStr + ":" + secondStr
        } else {
            return minuteStr + ":" + secondStr
        }
        
    }
    
}









