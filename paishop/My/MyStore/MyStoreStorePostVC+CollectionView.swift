//
//  MyStoreStorePostVC+CollectionView.swift
//  paishop
//
//  Created by SeniorCorder on 6/8/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

extension MyStoreStorePostVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyStoreTypeCell = collectionView.ts_dequeueReusableCell(MyStoreTypeCell.self, forIndexPath: indexPath)
        cell.setCellContent(self.categories[indexPath.item], index: indexPath.item, selectedIndex: self.getSelectedCategoryIndex())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 280 / 3
        let height = (250 - 16) / 4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategoryId = categories[indexPath.item].id!
        self.categoryLabel.text = categories[indexPath.item].name
        self.categoryLabel.textColor = MainColors.themeEndColors[selectedTheme]
        self.storeTypeCollectionView.reloadData()
        
    }
    
}
