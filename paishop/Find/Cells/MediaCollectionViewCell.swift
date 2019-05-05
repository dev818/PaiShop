//
//  MediaCollectionViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/04.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import MobileCoreServices
import Photos

class MediaCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    func setInfo(model: NSDictionary) {
        let url = model["url"] as! String
        let type = model["type"] as! NSInteger
        
        if type == 0 {
            imgPlay.isHidden = true
            
            imgMedia.sd_setImage(with: URL(string: url), completed: nil)
            imgMedia.transform = CGAffineTransform(rotationAngle: 0)
            
        } else {
            imgPlay.isHidden = false
            
            // get thumbnail from video url
            let asset = AVURLAsset(url: URL(string: url)!, options: nil)
            let imageGen = AVAssetImageGenerator(asset: asset)
            
            var cgImage = try? imageGen.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            
            if cgImage == nil {
                cgImage = try? imageGen.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            }
            
            if cgImage != nil {
                let uiImage = UIImage(cgImage: cgImage!)
                imgMedia.image = uiImage
                imgMedia.transform = CGAffineTransform(rotationAngle: .pi / 2)
            }
            
        }
        
        imgMedia.setNeedsDisplay()
    }
    
    
}
