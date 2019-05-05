//
//  MyVCStoreCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyVCStoreCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!    
    @IBOutlet weak var noStoreFrame: RoundRectView! {
        didSet {
            noStoreFrame.isHidden = true
        }
    }
    
    
    var parentVC: MyVC!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: MyVC) {
        self.parentVC = vc
        nameLabel.text = UserInstance.nickname! + "的商店"
        
        let degreeId = UserInstance.degreeId!
        if degreeId  > 0 {
            var degreeNames: [String] = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.degreeNameArray.count > 0 {
                degreeNames = appDelegate.degreeNameArray
            } else {
                degreeNames = UserDefaultsUtil.shared.getDegreeNameArray()
            }
            if degreeNames.count >= degreeId {
                self.degreeLabel.text = degreeNames[degreeId - 1]
            }
        } else {
            self.degreeLabel.text = "免费版"
        }
        
        if UserInstance.hasStore() {
            noStoreFrame.isHidden = true
        } else {
            noStoreFrame.isHidden = false
        }
    }
    
    
    @IBAction func selectStore1(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreProductManageVC.nameOfClass)
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectStore2(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreStorePostVC.nameOfClass)
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectStore3(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderVC.nameOfClass)
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectStore4(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyVideoPlayVC.nameOfClass)
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectStoreAll(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreVC.nameOfClass)
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectNewStore(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreStorePostVC.nameOfClass)
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
