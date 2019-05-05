//
//  MyVCWalletCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyVCWalletCell: UITableViewCell {
    
    @IBOutlet weak var walletLabel1: UILabel!
    @IBOutlet weak var walletLabel2: UILabel!
    @IBOutlet weak var walletLabel3: UILabel!
    @IBOutlet weak var walletLabel4: UILabel!
    
    @IBOutlet weak var newsTableView: UITableView! {
        didSet {
            newsTableView.isPagingEnabled = true
            newsTableView.dataSource = self
            newsTableView.delegate = self
            newsTableView.isScrollEnabled = false
            newsTableView.ts_registerCellNib(MyVCNewsCell.self)
        }
    }
    
    
    var notifications: [NotificationListModel] = []
    var parentVC: MyVC!
    var currentPage = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: MyVC, notifications: [NotificationListModel]) {
        self.parentVC = vc
        self.notifications = notifications
        newsTableView.reloadData {
            if vc.timer != nil {
                vc.timer.invalidate()
                vc.timer = nil
             }
             vc.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timerDidFire), userInfo: nil, repeats: true)
            self.newsTableView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
        }
        
        walletLabel1.text = UserInstance.paiBalance
        walletLabel2.text = UserInstance.point
        
    }
    
    @objc func timerDidFire() {
        var contentOffset = CGPoint.zero
        
        if currentPage >= (self.notifications.count - 1) {
            currentPage = 0
            contentOffset = CGPoint(x: 0, y: 0)
            newsTableView.setContentOffset(contentOffset, animated: false)
        }
        
        currentPage += 1
        contentOffset = CGPoint(x: 0, y: 36 * currentPage)
        
        if contentOffset != CGPoint.zero {
            newsTableView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    
    //go to pi
    @IBAction func selectWallet1(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingListVC.nameOfClass) as! MyBillingListVC
        vc.currency = 1
        vc.type = false
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to point
    @IBAction func selectWallet2(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingListVC.nameOfClass) as! MyBillingListVC
        vc.currency = 3
        vc.type = false
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to return pi
    @IBAction func selectWallet3(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingReturnListVC.nameOfClass) as! MyBillingReturnListVC
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to withdraw record
    @IBAction func selectWallet4(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletWithdrawRecordVC.nameOfClass) as! MyWalletWithdrawRecordVC
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to all
    @IBAction func selectWallet5(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletVC.nameOfClass)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectNews(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: NotificationVC.nameOfClass)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}




extension MyVCWalletCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyVCNewsCell = tableView.ts_dequeueReusableCell(MyVCNewsCell.self)
        cell.setCellContent(notifications[indexPath.row])        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: NotificationVC.nameOfClass)
        //parentVC.navigationController?.pushViewController(vc, animated: true)
        
    }
}










