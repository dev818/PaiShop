//
//  MyFavorProductCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyFavorProductCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var favorCountLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var findProductBtn: UIButton!
    
    var parentVC: MyFavorProductsVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //h.g.n
        findProductBtn.backgroundColor = .clear
        findProductBtn.layer.cornerRadius = 5
        findProductBtn.layer.borderWidth = 1
        findProductBtn.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: MyFavorProductsVC) {
        self.parentVC = vc
    }
    
    func setCellContent(_ product: ProductListModel) {
        let resizedUrl = Utils.getResizedImageUrlString((product.images?.first)!, width: "200")
        productImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
        productNameLabel.text = product.name
        productPriceLabel.text = "¥ " + product.price!
        favorCountLabel.text = "\(product.favoritesCount!)人收藏"
    }   
    
    
}
