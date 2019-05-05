//
//  MyRecommenderMainVC.swift
//  paishop
//
//  Created by Admin on 8/20/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyRecommenderMainVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var levelImg: UIImageView!
    @IBOutlet weak var userProfileImg: RoundImageView!
    @IBOutlet weak var levelNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        // Do any additional setup after loading the view. 合伙人
    }
    
    private func setupUI() {
        self.userNameLabel.text = Utils.getNickName()
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.userProfileImg.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.levelImg.image = levelImages[UserInstance.level_id!]
        if UserInstance.level_id! > 0 {
            self.levelNameLbl.text = "(" + levelNames[UserInstance.level_id!] + ")"
        } else {
            self.levelNameLbl.text = ""
        }
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "合伙人"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    //buy level page!
    @IBAction func raiseLevelBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmBuyLevelVC.nameOfClass) as! MyRecmBuyLevelVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // first Tile!
    @IBAction func myMemberBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecommenderDetailVC.nameOfClass) as! MyRecommenderDetailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // second Tile!
    @IBAction func incomeDetailBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmIncomeDetailVC.nameOfClass) as! MyRecmIncomeDetailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // third Tile!
    @IBAction func stockInvestBtnTapped(_ sender: Any) {
        self.loadMyRecmWebViewController(index: 3)
    }
    
    // fourth Tile!
    @IBAction func cityPartnerBtnTapped(_ sender: Any) {
        self.loadMyRecmWebViewController(index: 4)
    }
    
    // fifth Tile!
    @IBAction func transferBtnTapped(_ sender: Any) {
        self.loadMyRecmWebViewController(index: 5)
    }

    // sixth Tile!
    @IBAction func promotionBtnTapped(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmQRcode2VC.nameOfClass) as! MyRecmQRcode2VC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadMyRecmWebViewController(index: NSInteger) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
        vc.index = index
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadSafari(index: NSInteger) {
        let mainUrl = "http://paikepaifu.cn/"
        let subAddr3 = "gpqq"
        let subAddr4 = "cshhr"
        let subAddr5 = "hhr_z"
        
        let token = UserInstance.accessToken!
        var strUrl = String()
        
        if index == 3 {
            strUrl = mainUrl + subAddr3 + "?token_id=" + token
            
        } else if index == 4 {
            strUrl = mainUrl + subAddr4 + "?token_id=" + token
            
        } else if index == 5 {
            strUrl = mainUrl + subAddr5 + "?token_id=" + token

        }
        
        print(">>>> strUrl:\n", strUrl)
        
        UIApplication.shared.open(URL(string: strUrl)!, options: [:], completionHandler: nil)
        
    }
    
    private func showAlert() {
        // create the alert
        let alert = UIAlertController(title: "", message: "您的等级未达到无法参与。", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
}

extension MyRecommenderMainVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
