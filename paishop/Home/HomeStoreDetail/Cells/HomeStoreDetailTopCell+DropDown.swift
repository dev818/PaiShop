//
//  CategoryVC+DropDown.swift
//  paishop
//
//  Created by SeniorCorder on 6/15/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import DropDown


extension HomeStoreDetailTopCell {
    
    func setupTab5DropDown() {
        tab5DropDown = DropDown()
        tab5DropDown.anchorView = lineView5
        let dropDownData = [
            "      关注动态      ",
            "      最新动态      ",
        ]
        tab5DropDown.dataSource = dropDownData
        
//        let dropDownDataToDisplay = [
//            "关注动态",
//            "最新动态",
//        ]
        
        tab5DropDown.selectionAction = { (index: Int, item: String) in
//            self.resetTabLabels()
            print("Selected item: \(item) at index: \(index)")
//            self.selectedTab3Index = index
//            self.tab3Label.text = dropDownDataToDisplay[index]
//            self.tab3DropDown.hide()
//
//            self.selectedTab = 3
//            self.loadProductLists(resetData: true, loadFirst: true)
        }
        
    }
    
    
}











