//
//  CategoryVC+DropDown.swift
//  paishop
//
//  Created by SeniorCorder on 6/15/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import DropDown


extension CategoryVC {
    
    func setupTab1DropDown() {
        tab1DropDown = DropDown()
        tab1DropDown.anchorView = tab1AnchorView
        let dropDownData = [
            "     500米      ",
            "     1000米     ",
            "     2000米     ",
            "     5000米     ",
            ]
        tab1DropDown.dataSource = dropDownData
        
        let dropDownDataToDisplay = [
            "500米",
            "1000米",
            "2000米",
            "5000米",
            ]
        
        tab1DropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.resetTabLabels()
            //print("Selected item: \(item) at index: \(index)")
            self.selectedTab1Index = index
            self.tab1Label.text = dropDownDataToDisplay[index]
            self.tab1DropDown.hide()
            
            self.selectedTab = 1
            self.loadProductLists(resetData: true, loadFirst: true)
        }
    }
    
    func setupTab2DropDown() {
        tab2DropDown = DropDown()
        tab2DropDown.anchorView = tab2AnchorView
        var categoryNames: [String] = []
        var categoryNamesToDisplay: [String] = []
        for category in self.categories {
            categoryNames.append("     " + category.name! + "     ")
            categoryNamesToDisplay.append(category.name!)
        }
        tab2DropDown.dataSource = categoryNames
        tab2DropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.resetTabLabels()
            //print("Selected item: \(item) at index: \(index)")
            self.selectedCategoryId = self.categories[index].id!
            self.tab2Label.text = categoryNamesToDisplay[index]
            self.tab2DropDown.hide()
            
            self.selectedTab = 2
            self.loadProductLists(resetData: true, loadFirst: true)
        }
    }
    
    
    func setupTab3DropDown() {
        tab3DropDown = DropDown()
        tab3DropDown.anchorView = tab4AnchorView
        let dropDownData = [
            "      推荐      ",
            "      人气      ",
            "      销量      ",
        ]
        tab3DropDown.dataSource = dropDownData
        
        let dropDownDataToDisplay = [
            "推荐",
            "人气",
            "销量",
        ]
        
        tab3DropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.resetTabLabels()
            //print("Selected item: \(item) at index: \(index)")
            self.selectedTab3Index = index
            self.tab3Label.text = dropDownDataToDisplay[index]
            self.tab3DropDown.hide()
            
            self.selectedTab = 3
            self.loadProductLists(resetData: true, loadFirst: true)
        }
        
    }
    
    
}











