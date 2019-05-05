//
//  MyOrderMineTab2CellHeader.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import BEMCheckBox

class MyOrderMineTab2CellHeader: UITableViewHeaderFooterView {

    var store: StoreModel!
    var parentVC: MyOrderMineTab2VC!
    var section: Int!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setContent(_ store: StoreModel, vc: MyOrderMineTab2VC, section: Int) {
        self.store = store
        self.parentVC = vc
        self.section = section
        
        checkBox.delegate = self
        checkBox.on = store.checked
        nameLabel.text = store.name
        
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        checkBox.onTintColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onFillColor = MainColors.themeEndColors[selectedTheme]
        checkBox.onCheckColor = UIColor.white
        
    }

}


extension MyOrderMineTab2CellHeader: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        self.parentVC.stores[section].checked = checkBox.on
        
        let storeId = self.store.storeId!
        
        for i in 0..<self.parentVC.cartsDic[storeId]!.count {
            self.parentVC.cartsDic[self.store.storeId!]![i].checked = checkBox.on
        }
        
        for i in 0..<self.parentVC.carts.count {
            if self.parentVC.carts[i].item?.store?.storeId! == storeId {
                self.parentVC.carts[i].checked = checkBox.on
            }
        }
        
        self.parentVC.allCheckBox.on = self.parentVC.checkAllSelected()
        
        self.parentVC.tableView.reloadData {
            self.parentVC.calculateSum()
        }
    }
}
