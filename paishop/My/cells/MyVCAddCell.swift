//
//  MyVCAddCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyVCAddCell: UITableViewCell {
    
    var parentVC: MyVC!
    @IBOutlet weak var myLevelImg: UIImageView!
    
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
        self.myLevelImg.image = levelImages[UserInstance.level_id!]
    }   
    
    @IBAction func recommendPageBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecommenderMainVC.nameOfClass) as! MyRecommenderMainVC
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func buyRecmLevelBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmBuyLevelVC.nameOfClass) as! MyRecmBuyLevelVC
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myMembersBtnTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecommenderDetailVC.nameOfClass) as! MyRecommenderDetailVC
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myIncomeBtnTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmIncomeDetailVC.nameOfClass) as! MyRecmIncomeDetailVC
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myOptionBtnTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
        vc.index = 3
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
}
