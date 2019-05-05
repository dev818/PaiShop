//
//  Nearby+ButtonBarView.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation


extension NearbyVC {
    
    func setupButtonBarView() {
        if Utils.isIpad() {
            buttonBarView.snp.makeConstraints({ (make) in
                make.height.equalTo(100)
            })
        } else {
            buttonBarView.snp.makeConstraints({ (make) in
                make.height.equalTo(72)
            })
        }
        
        settings.style.buttonBarBackgroundColor = MainColors.buttonBarBgColor
        settings.style.selectedBarBackgroundColor = MainColors.themeEndColors[selectedTheme]
        settings.style.buttonBarItemSelectedTitleColor = MainColors.themeEndColors[selectedTheme]
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: ButtonBarTitleAndImageCell.nameOfClass, bundle: Bundle(for: ButtonBarTitleAndImageCell.self), width: { [weak self] (itemTitle) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont
            label.text = itemTitle
            let labelSize = label.intrinsicContentSize
            return labelSize.width + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
        })
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.style.buttonBarMinimumInteritemSpacing
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: settings.style.buttonBarLeftContentInset , bottom: sectionInset.bottom, right: settings.style.buttonBarRightContentInset )
        //let cellWidth = UIScreen.ts_width / 5
        //flowLayout.itemSize = CGSize(width: cellWidth, height: self.buttonBarView.ts_height + 50)
        
        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        
        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight
        buttonBarView.selectedBarVerticalAlignment = settings.style.selectedBarVerticalAlignment
        
        //register button bar item cell
        switch buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: ButtonBarTitleAndImageCell.customId)
        case .cellClass:
            buttonBarView.register(ButtonBarTitleAndImageCell.self, forCellWithReuseIdentifier:ButtonBarTitleAndImageCell.customId)
        }
        
        self.view.layoutIfNeeded()
    }
    
    
}



extension NearbyVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonBarTitleAndImageCell.customId, for: indexPath) as? ButtonBarTitleAndImageCell else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        if indexPath.item == self.currentIndex {
            cell.itemLabel.textColor = settings.style.buttonBarItemSelectedTitleColor
        } else {
            cell.itemLabel.textColor = settings.style.buttonBarItemTitleColor
        }
        cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor
        cell.backgroundColor = settings.style.buttonBarItemBackgroundColor
        
        if indexPath.item == 0 {
            cell.itemLabel.text = "精选"
            cell.itemImage.image = UIImage(named: "ic_home_star")
            if self.currentIndex == 0 {
                cell.itemImage.setTintColor(settings.style.buttonBarItemSelectedTitleColor)
            } else {
                cell.itemImage.setTintColor(MainColors.defaultSubTitle)
            }
            
            return cell
        }
        if indexPath.item == (self.categories.count + 1 ){
            cell.itemLabel.text = "全部分类"
            cell.itemImage.image = UIImage(named: "ic_my_store_order")
            cell.itemImage.layer.cornerRadius = 0
            if self.currentIndex == (self.categories.count + 1 ) {
                cell.itemImage.setTintColor(settings.style.buttonBarItemSelectedTitleColor)
            } else {
                cell.itemImage.setTintColor(MainColors.defaultSubTitle)
            }
            return cell
        }
        
        let category = self.categories[indexPath.item - 1]
        cell.itemLabel.text = category.name
        cell.itemLabel.font = settings.style.buttonBarItemFont
        // h.g.n
        cell.itemImage.image = checkImgExtention(imageURL: category.imageURL!)
        //cell.itemImage.setImageWithURLString(category.imageURL)        
        return cell
    }
    
    @objc open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let cellWidth = UIScreen.ts_width / 5
        if Utils.isIpad() {
            return CGSize(width: cellWidth, height: self.buttonBarView.ts_height - 24)
        }
        return CGSize(width: cellWidth, height: self.buttonBarView.ts_height - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        if self.currentIndex != indexPath.item {
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            self.currentIndex = indexPath.item
            self.nAll = 0
            self.nTotal = 0
            self.loadStoreLists()
        }
        self.buttonBarView.reloadData()
        
        self.storeItems = []
        self.selectedStoreId = nil
        self.tableView.reloadData()
    }
    
}























