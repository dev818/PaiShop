
import Foundation


extension GuideVC {
    func setupButtonBarView() {
        if Utils.isIpad() {
            buttonBarView.snp.makeConstraints({ (make) in
                make.height.equalTo(120)
            })
        } else {
            buttonBarView.snp.makeConstraints({ (make) in
                make.height.equalTo(80)
            })
        }
        
        settings.style.buttonBarBackgroundColor = MainColors.buttonBarBgColor
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



extension GuideVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonBarTitleAndImageCell.customId, for: indexPath) as? ButtonBarTitleAndImageCell else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        
        let category = self.categories[indexPath.item] //let menuItem = self.menuItemData[indexPath.item]
        
        cell.itemLabel.text = category.name //menuItem.name
        cell.itemLabel.font = settings.style.buttonBarItemFont
        cell.itemImage.setImageWithURLString(category.imageURL) //cell.itemImage.image = menuItem.iconImage
        if indexPath.item == self.currentIndex {
            cell.itemLabel.textColor = settings.style.buttonBarItemSelectedTitleColor
            //cell.itemImage.setTintColor(settings.style.buttonBarItemSelectedTitleColor)
        } else {
            cell.itemLabel.textColor = settings.style.buttonBarItemTitleColor
            //cell.itemImage.setTintColor(UIColor.white)
        }
        
        cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor
        cell.backgroundColor = settings.style.buttonBarItemBackgroundColor
        
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
            self.currentIndex = indexPath.row
            
            self.selectedCityId = nil
            self.listCityText = "请选择"
            self.cityLabel.text = self.listCityText
            //self.searchBar.text = self.listSearchText
            
            if self.searchText.isEmpty {
                self.tableView.isHidden = false
                self.searchTableView.isHidden = true
                self.stores = []
                self.tableView.ts_reloadData {
                    self.loadStores(resetData: true, loadFirst: true)
                }
            } else {
                self.tableView.isHidden = true
                self.searchTableView.isHidden = false
                let parameters: [String : Any] = [
                    "keyword" : self.searchText,
                    "category" : categories[currentIndex].id!
                ]
                self.searchStoreInListMode(parameters)
            }
        }
        self.buttonBarView.reloadData()
    }
    
}







