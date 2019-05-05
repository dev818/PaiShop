//
//  MyStoreProductPostVC+Dropdown.swift
//  paishop
//
//  Created by Admin on 8/2/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import DropDown

extension MyStoreProductPostVC {

    func setupCategoryDropDown() {
        categoryDropDown = DropDown()
        categoryDropDown.anchorView = categoryAnchorView
        var categoryNames: [String] = []
        var categoryNamesToDisplay: [String] = []
        for category in self.categories {
            categoryNames.append("     " + category.name! + "     ")
            categoryNamesToDisplay.append(category.name!)
        }
        categoryDropDown.dataSource = categoryNames
        categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            //print("Selected item: \(item) at index: \(index)")
            //self.selectedCategoryId = self.categories[index].id!
            self.categorySelectLabel.text = categoryNamesToDisplay[index]
            self.categoryDropDown.hide()            
            
        }
    }
    
    func loadCategories() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        HomeAPI.shared.categoryRoot { (json, success) in
            if success {
                self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                self.setupCategoryDropDown()
            } else {
                //load again...
                HomeAPI.shared.categoryRoot(completion: { (json, success1) in
                    if success1 {
                        self.categories = CategoryModel.getCategoriesFromJson(json["category"])
                        self.setupCategoryDropDown()
                    }
                })
            }
        }
    }
    
}
