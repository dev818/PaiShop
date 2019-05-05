//
//  MyOrderMineTab3Cell.swift
//  paishop
//
//  Created by SeniorCorder on 6/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import BEMCheckBox

class MyOrderMineTab3Cell: UITableViewCell {
    
    @IBOutlet weak var headerCheckBox: BEMCheckBox!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var totalPriceDescriptionLabel: UILabel!
    
    var vc: UIViewController!
    var orderItem: OrderItemModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setupTheme()
        
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        headerCheckBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        headerCheckBox.onFillColor = MainColors.themeEndColors[selectedTheme]
        headerCheckBox.onCheckColor = UIColor.white
        checkBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onFillColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onCheckColor = UIColor.white
    }
    
    
    func setCellContent(_ orderItem: OrderItemModel, vc: UIViewController) {
        
        checkBox.delegate = self
        headerCheckBox.delegate = self
        
        self.orderItem = orderItem
        self.vc = vc
        
        storeNameLabel.text = orderItem.product.store?.name
        if (orderItem.product.images?.count)! > 0 {
            if let productUrl = orderItem.product.images?.first, productUrl != "" {
                let resizedProductUrl = Utils.getResizedImageUrlString(productUrl, width: "150")
                productImageView.setImageWithURLString(resizedProductUrl, placeholderImage: ImageAsset.default_image.image)
            }
        }
        productNameLabel.text = orderItem.product.name
        countLabel.text = "x" + String(orderItem.order.count!)
        priceLabel.text = "¥" + orderItem.order.price!
        let totalPrice = Double(orderItem.order.price!)! * Double(orderItem.order.count!)
        totalPriceLabel.text = "¥\(totalPrice)"
        totalPriceDescriptionLabel.text = "共\(orderItem.order.count!)件商品"        
    }
    
}

extension MyOrderMineTab3Cell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox == self.checkBox {
            self.headerCheckBox.on = self.checkBox.on
        } else {
            self.checkBox.on = self.headerCheckBox.on
        }
    }
}







