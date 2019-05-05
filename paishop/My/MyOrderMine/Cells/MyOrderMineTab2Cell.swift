//
//  MyOrderMineTab2Cell.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import BEMCheckBox

class MyOrderMineTab2Cell: UITableViewCell {
    
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var productSelectView: UIView!
    @IBOutlet weak var calculatorView: UIView! {
        didSet {
            calculatorView.isHidden = true
        }
    }
    @IBOutlet weak var calcNumberLabel: UILabel!
    @IBOutlet weak var calcPlusButton: RoundRectButton!
    @IBOutlet weak var calcMinusButton: RoundRectButton!
    @IBOutlet weak var calcCompleteButtonBg: GradientView!
    @IBOutlet weak var calcNumberFrame: RoundRectView!
    
    var cart: CartModel!
    var parentVC: MyOrderMineTab2VC!
    var productCount: Int = 1
    var indexPath: IndexPath!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.updateProductNumber()
        
        let checkBoxViewTap = UITapGestureRecognizer(target: self, action: #selector(selectCheckBoxView))
        checkBoxView.isUserInteractionEnabled = true
        checkBoxView.addGestureRecognizer(checkBoxViewTap)
        
        /*let productImageViewTap = UITapGestureRecognizer(target: self, action: #selector(selectProduct))
        productImageView.isUserInteractionEnabled = true
        productImageView.addGestureRecognizer(productImageViewTap)*/
        
        let productSelectViewTap = UITapGestureRecognizer(target: self, action: #selector(selectProduct))
        productSelectView.isUserInteractionEnabled = true
        productSelectView.addGestureRecognizer(productSelectViewTap)
        
        setupTheme()
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        checkBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onFillColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onCheckColor = UIColor.white
        calcPlusButton.borderColor = MainColors.themeEndColors[selectedTheme]
        calcPlusButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        calcMinusButton.borderColor = MainColors.themeEndColors[selectedTheme]
        calcMinusButton.setTitleColor(MainColors.themeEndColors[selectedTheme], for: .normal)
        calcNumberLabel.textColor = MainColors.themeEndColors[selectedTheme]
        calcCompleteButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        calcCompleteButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        calcNumberFrame.borderColor = MainColors.themeEndColors[selectedTheme]
    }
    
    func setContent(_ cart: CartModel, vc: MyOrderMineTab2VC, indexPath: IndexPath) {
        self.cart = cart
        self.parentVC = vc
        self.indexPath = indexPath
        
        checkBox.delegate = self
        checkBox.on = cart.checked
        self.productCount = cart.count!
        let item = cart.item
        
        if (item?.images?.count)! > 0 {
            if let itemUrl = item?.images?.first, itemUrl != "" {
                let resizedItemUrl = Utils.getResizedImageUrlString(itemUrl, width: "200")
                productImageView.setImageWithURLString(resizedItemUrl)
            } 
        }
        
        productNameLabel.text = item?.name
        priceLabel.text = "¥" + (item?.price)!
        productPriceLabel.text = "¥" + (item?.price)!
        self.updateProductNumber()
    }
    
    @IBAction func selectEdit(_ sender: UIButton) {
        calculatorView.isHidden = false
    }
    
    @IBAction func selectCalcComplete(_ sender: UIButton) {
        let parameters: [String: Any] = [
            "id" : cart.id!,
            "count" : productCount
        ]
        MyAPI.shared.cartChange(params: parameters) { (json, success) in
            if success {
                self.calculatorView.isHidden = true
                //print("Change Cart...")
                //print(json)
                let storeId = self.parentVC.storeIds[self.indexPath.section]
                self.parentVC.cartsDic[storeId]![self.indexPath.row].count = self.productCount
                
                let cartId = self.parentVC.cartsDic[storeId]![self.indexPath.row].id!
                for i in 0..<self.parentVC.carts.count {
                    if self.parentVC.carts[i].id! == cartId {
                        self.parentVC.carts[i].count = self.productCount
                    }
                }
                
                self.parentVC.tableView.ts_reloadData {
                    self.parentVC.calculateSum()
                }
            } else {
                // try again
                MyAPI.shared.cartChange(params: parameters, completion: { (json, success1) in
                    self.calculatorView.isHidden = true
                    if success1 {
                        let storeId = self.parentVC.storeIds[self.indexPath.section]
                        self.parentVC.cartsDic[storeId]![self.indexPath.row].count = self.productCount
                        let cartId = self.parentVC.cartsDic[storeId]![self.indexPath.row].id!
                        for i in 0..<self.parentVC.carts.count {
                            if self.parentVC.carts[i].id! == cartId {
                                self.parentVC.carts[i].count = self.productCount
                            }
                        }
                    }
                    
                    self.parentVC.tableView.ts_reloadData {
                        self.parentVC.calculateSum()
                    }
                })
            }
            
            
        }
    }
    
    @IBAction func selectCalcPlus(_ sender: UIButton) {
        self.productCount += 1
        self.updateProductNumber()
    }
    
    @IBAction func selectCalcMinus(_ sender: UIButton) {
        if self.productCount > 1 {
            self.productCount -= 1
            self.updateProductNumber()
        }
    }
    
    @IBAction func selectDelete(_ sender: UIButton) {
        var selectedIds: [Int64] = []
        selectedIds.append(self.cart.id!)
        self.parentVC.deleteSelectedCarts(ids: selectedIds)
    }
    
    
    @objc func selectCheckBoxView() {
        self.checkBox.setOn(!self.checkBox.on, animated: true)
        self.updateCheckBox()
    }
    
    @objc func selectProduct() {
        let storeId = self.parentVC.storeIds[indexPath.section]
        let cart = self.parentVC.cartsDic[storeId]![indexPath.row]
        let productId = (cart.item?.id)!
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = productId
        self.parentVC.pushAndHideTabbar(vc)
    }
    
    private func updateProductNumber() {
        numberLabel.text = "x\(productCount)"
        calcNumberLabel.text = "\(productCount)"
    }
    
    private func updateCheckBox() {
        let storeId = parentVC.storeIds[indexPath.section]
        parentVC.cartsDic[storeId]![indexPath.row].checked = self.checkBox.on
        
        let cartId = parentVC.cartsDic[storeId]![indexPath.row].id!
        for i in 0..<parentVC.carts.count {
            if parentVC.carts[i].id! == cartId {
                parentVC.carts[i].checked = checkBox.on
            }
        }
        
        let storeCarts = parentVC.cartsDic[storeId]!
        var allSelected = true
        for storeCart in storeCarts {
            if !storeCart.checked {
                allSelected = false
            }
        }
        if allSelected {
            parentVC.stores[indexPath.section].checked = true
        } else {
            parentVC.stores[indexPath.section].checked = false
        }
        
        self.parentVC.allCheckBox.on = self.parentVC.checkAllSelected()
        
        parentVC.tableView.ts_reloadData {
            self.parentVC.calculateSum()
        }
    }
    
}


extension MyOrderMineTab2Cell: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        self.updateCheckBox()
    }
}











