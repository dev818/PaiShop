//
//  SecondLevelMemberTableViewCell.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/08/31.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

protocol SecondLevelMemberTableViewCellDelegate {
    func didTapButtonSecondVisiteProfile(index: NSInteger, indexSection: NSInteger)
}

class SecondLevelMemberTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionViewList: UICollectionView!
    var arrayList = NSArray()
    var indexSection = NSInteger()
    var delegate: SecondLevelMemberTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initMainView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initMainView() {
        collectionViewList.delegate = self
        collectionViewList.dataSource = self
//        collectionViewList.isScrollEnabled = false
//        collectionViewList.alwaysBounceVertical = true
        collectionViewList.register(UINib.init(nibName: "SecondLevelMemberCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SecondLevelMemberCollectionViewCell")
    }
    
    // collection view datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLevelMemberCollectionViewCell", for: indexPath) as! SecondLevelMemberCollectionViewCell
        cell.setInfo(dic: arrayList[indexPath.row] as! NSDictionary)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 87)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didTapButtonSecondVisiteProfile(index: indexPath.row, indexSection: indexSection)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
