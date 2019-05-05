//
//  FeaturedPostCollectionViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/06.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol FeaturedPostCollectionViewCellDelegate {
    func didTapButtonFeaturedPostCollectionViewCell(index: NSInteger)
    func didTapButtonFeaturedPostCollectionViewCellAdd()
}

class FeaturedPostCollectionViewCell: UICollectionViewCell {

    var delegate: FeaturedPostCollectionViewCellDelegate?
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var viewAdd: UIView!
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
    
    var index = NSInteger()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setInfo(model: CustomImageModel) {
        viewImage.isHidden = false
        viewAdd.isHidden = true
        
        if model.isImage {
            imgPost.transform = CGAffineTransform(rotationAngle: 0)
            imgPost.image = model.image
            imgPlay.isHidden = true
        } else {
            imgPost.transform = CGAffineTransform(rotationAngle: .pi / 2)
            imgPost.image = model.image
            imgPlay.isHidden = false
        }
        
    }
    
    func setAdd() {
        viewImage.isHidden = true
        viewAdd.isHidden = false
    }
    
    @IBAction func tapBtnDelete(_ sender: Any) {
        self.delegate?.didTapButtonFeaturedPostCollectionViewCell(index: index)
    }
    
    @IBAction func tapBtnAdd(_ sender: Any) {
        self.delegate?.didTapButtonFeaturedPostCollectionViewCellAdd()
    }
    
    
}
