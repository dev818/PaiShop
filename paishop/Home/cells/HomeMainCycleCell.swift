//
//  HomeMainCycleCell.swift
//  paishop
//
//  Created by Mac on 1/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SDCycleScrollView

class HomeMainCycleCell: UITableViewCell {
    
    @IBOutlet weak var cycleView: SDCycleScrollView! {
        didSet {
            //cycleView.imageURLStringsGroup = imgUrls
        }
    }
    
    @IBOutlet weak var menuCollectionView: UICollectionView! {
        didSet {
            menuCollectionView.dataSource = self
            menuCollectionView.delegate = self
        }
    }
    
    
    let menuItemData: [(name: String, iconImage: UIImage)] = [
        ("家电", ImageAsset.home_menu1.image),
        ("化妆", ImageAsset.home_menu2.image),
        ("百货", ImageAsset.home_menu3.image),
        ("服装", ImageAsset.home_menu4.image),
        ("箱包", ImageAsset.home_menu5.image),
        ("家纺", ImageAsset.home_menu6.image),
        ("食晶", ImageAsset.home_menu7.image),
        ("家装", ImageAsset.home_menu8.image),
        ("电子", ImageAsset.home_menu9.image),
        ("更多", ImageAsset.home_menu10.image),
    ]
    var homeVC: HomeVC!
    var categories: [CategoryModel] = []
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.menuCollectionView.register(HomeHeaderMenuItemCell.ts_Nib(), forCellWithReuseIdentifier: HomeHeaderMenuItemCell.customId)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let itemSizeWidth = ( UIScreen.ts_width - 20 ) / 5
        var itemSizeHeight: CGFloat = 70.0
        if Utils.isIpad() {
            itemSizeHeight = 100.0
        }
        layout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
        self.menuCollectionView.collectionViewLayout = layout
    }
    
    public func setupCycleView(_ categories: [CategoryModel], vc: HomeVC) {
        //Setup cycleView
        cycleView.placeholderImage = UIImage(named: "default.png")
        cycleView.currentPageDotColor = MainColors.pageSelected
        cycleView.pageDotColor = MainColors.pageUnSelected
        cycleView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight
        cycleView.autoScrollTimeInterval = 3
        cycleView.bannerImageViewContentMode = .scaleAspectFill
        cycleView.pageControlBottomOffset = 8
        
        self.categories = categories
        self.homeVC = vc
        self.menuCollectionView.reloadData()
    }
    
    public func setupImages(_ imgUrls: [String]) {
        cycleView.imageURLStringsGroup = imgUrls
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}



extension HomeMainCycleCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.categories.count > 10 {
            return 10
        }
        return self.categories.count //self.menuItemData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHeaderMenuItemCell.customId, for: indexPath) as! HomeHeaderMenuItemCell
        let category = self.categories[indexPath.item] //let itemData = self.menuItemData[indexPath.item]
        
        // h.g.n
        cell.itemImage.image = checkImgExtention(imageURL: category.imageURL!)
        //cell.itemImage.setImageWithURLString(category.imageURL) //cell.itemImage.image = itemData.iconImage
        cell.itemLabel.text = category.name //cell.itemLabel.text = itemData.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //homeVC.performSegue(withIdentifier: HomeListVC.nameOfClass, sender: indexPath.row)
        let homeListVC = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeListVC.nameOfClass) as! HomeListVC
        homeListVC.currentIndex = indexPath.row
        homeListVC.categories = self.categories
        homeVC.pushAndHideTabbar(homeListVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    
}












