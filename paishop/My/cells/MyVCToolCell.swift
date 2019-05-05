//
//  MyVCToolCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyVCToolCell: UITableViewCell {
    
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
    }
    
    @IBAction func selectTool1(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyFavorStoresVC.nameOfClass)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectTool2(_ sender: UIButton) {
//        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyFavorProductsVC.nameOfClass)
//        parentVC.navigationController?.pushViewController(vc, animated: true)
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
        vc.index = 8
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectTool3(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: NotificationVC.nameOfClass)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectTool4(_ sender: UIButton) {
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
//        vc.urlString = API.WEB_LINK + "/qrcode" // "http://192.168.0.100/paishop/public/qrcode"
//        vc.navBarTitle = "派世界"
//        parentVC.navigationController?.pushViewController(vc, animated: true)
        
        
//            let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmQRcode2VC.nameOfClass) as! MyRecmQRcode2VC
//            parentVC.navigationController?.pushViewController(vc, animated: true)
        
        if UserInstance.referee_id != 0 {
            let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
            vc.index = 7
            parentVC.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass)
            parentVC.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}
