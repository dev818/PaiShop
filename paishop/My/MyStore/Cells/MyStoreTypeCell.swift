//
//  MyStoreTypeCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/8/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyStoreTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var storeTypeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellContent(_ category: CategoryModel, index: Int, selectedIndex: Int) {
        storeTypeLabel.text = category.name
        if index == selectedIndex {
            let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
            storeTypeLabel.textColor = MainColors.themeEndColors[selectedTheme]
        }  else {
            storeTypeLabel.textColor = UIColor.black
        }
    }

}
