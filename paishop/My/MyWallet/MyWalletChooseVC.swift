//
//  MyWalletChooseVC.swift
//  paishop
//
//  Created by Admin on 8/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyWalletChooseVC: UIViewController {
    
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var myPaiLabel: UILabel!
    @IBOutlet weak var chargeBtn: RoundRectButton!
    @IBOutlet weak var convertBtn: RoundRectButton!
    
    var serverPaiAddress: String = ""
    var serverPaiPhone: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupUI()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "钱包"
        navBar.delegate = self
        navBar.setDefaultNav()
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.serverPaiAddress != nil {
            self.serverPaiAddress = appDelegate.serverPaiAddress
        } else {
            self.serverPaiAddress = UserDefaultsUtil.shared.getServerPaiAddress()
        }
        if appDelegate.serverPaiPhone != nil {
            self.serverPaiPhone = appDelegate.serverPaiPhone
        } else {
            self.serverPaiPhone = UserDefaultsUtil.shared.getServerPaiPhone()
        }
        
        self.setupHeaderFields()
    }
    
    private func setupHeaderFields() {
        
        self.myPaiLabel.text = UserInstance.paiBalance!
    }
    
    @IBAction func chargeBtnTapped(_ sender: Any) {
        
        if UserInstance.paiAddress!.isEmpty {
            self.presentAlert("没有π账号", message: "你没有π账号. \n 请添加你的π账号详细信息.")
            return
        }
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletRechargeVC.nameOfClass) as! MyWalletRechargeVC
        vc.serverPaiAddress = self.serverPaiAddress
        vc.serverPaiPhone = self.serverPaiPhone
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func convertBtnTapped(_ sender: Any) {
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletWithdrawVC.nameOfClass) as! MyWalletWithdrawVC
        vc.serverPaiAddress = self.serverPaiAddress
        vc.serverPaiPhone = self.serverPaiPhone
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MyWalletChooseVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
