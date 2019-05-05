//
//  MyStorePorductMediaCollectionViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/08.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol MyStorePorductMediaCollectionViewCellDelegate {
    func didTapButtonMyStorePorductMediaCollectionViewCellDelete(index: NSInteger, collectionViewIndex: NSInteger)
    func didTapButtonMyStorePorductMediaCollectionViewCellAdd(collectionViewIndex: NSInteger)
}

class MyStorePorductMediaCollectionViewCell: UICollectionViewCell {

    var delegate: MyStorePorductMediaCollectionViewCellDelegate?
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var viewAdd: UIView!
    
    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
    
    var index = NSInteger()
    var collectionViewIndex = NSInteger()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setInfo(model: CustomImageModel, isImage: Bool) {
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
    
    func setAdd(isImage: Bool) {
        if isImage == true {
            imgAdd.image = UIImage.init(named: "my_store_add_photo.png")
        } else {
            imgAdd.image = UIImage.init(named: "my_store_add_video.png")
        }
        
        viewImage.isHidden = true
        viewAdd.isHidden = false
    }
    
    @IBAction func tapBtnDelete(_ sender: Any) {
        self.delegate?.didTapButtonMyStorePorductMediaCollectionViewCellDelete(index: index, collectionViewIndex: collectionViewIndex)
    }
    
    @IBAction func tapBtnAdd(_ sender: Any) {
        self.delegate?.didTapButtonMyStorePorductMediaCollectionViewCellAdd(collectionViewIndex: collectionViewIndex)
    }
}
