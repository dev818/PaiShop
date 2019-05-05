//
//  MyOrderRecmCell.swift
//  paishop
//
//  Created by Admin on 8/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyOrderRecmCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.ts_registerCellNib(MyVCRecommendCollectionCell.self)
        }
    }
    
    
    var parentVC: UIViewController! //MyOrderMineTab1VC!
    var itemRecommends: [ItemRecommendModel] = []
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: UIViewController, items: [ItemRecommendModel]) {
        self.parentVC = vc
        self.itemRecommends = items
        self.collectionView.reloadData()
    }
    
    //    @IBAction func selectRecommendAll(_ sender: UIButton) {
    //
    //    }
    
}


extension MyOrderRecmCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(itemRecommends.count)
        return itemRecommends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MyVCRecommendCollectionCell = collectionView.ts_dequeueReusableCell(MyVCRecommendCollectionCell.self, forIndexPath: indexPath)
        cell.setCellContent(itemRecommends[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //return CGSize(width: collectionView.frame.height*7/9, height: collectionView.frame.height)
        //let height = itemRecommends[indexPath.item].images[indexPath.item]
        return CGSize(width: collectionView.frame.width*0.48, height: collectionView.frame.width*0.7)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        loadRecmFirst = false
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
        vc.itemId = itemRecommends[indexPath.item].itemId!
        parentVC.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
