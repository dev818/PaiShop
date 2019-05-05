//
//  MyOrderMineTab5Cell.swift
//  paishop
//
//  Created by SeniorCorder on 6/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyOrderMineTab5Cell: UITableViewCell {

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
    }
    
    func setCellContent(_ orderItem: OrderItemModel, vc: UIViewController) {
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
    
    @IBAction func selectOrderDelete(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        let parameters: [String : Any] = [
            "id" : orderItem.order.id!
        ]
        ProgressHUD.showWithStatus()
        sender.isEnabled = false
        MyAPI.shared.orderDelete(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                sender.isEnabled = true
                DispatchQueue.main.async {
                    if self.vc is MyOrderMineTab1VC {
                        (self.vc as! MyOrderMineTab1VC).loadOrderItems(resetData: true, loadFirst: true)
                    } else {
                        (self.vc as! MyOrderMineTab5VC).loadOrderItems(resetData: true, loadFirst: true)
                    }
                }
            } else {
                // try again...
                MyAPI.shared.orderDelete(params: parameters, completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    sender.isEnabled = true
                    if success1 {
                        DispatchQueue.main.async {
                            if self.vc is MyOrderMineTab1VC {
                                (self.vc as! MyOrderMineTab1VC).loadOrderItems(resetData: true, loadFirst: true)
                            } else {
                                (self.vc as! MyOrderMineTab5VC).loadOrderItems(resetData: true, loadFirst: true)
                            }
                        }
                    } else {
                        let errors = json1["errors"].dictionaryValue
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
                })
            }
        }
        
    }
    
    @IBAction func selectComment(_ sender: UIButton) {
    }
    
    
    
}






