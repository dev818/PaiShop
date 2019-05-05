//
//  HomeNewsCell.swift
//  paishop
//
//  Created by Mac on 2/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class HomeNewsCell: UITableViewCell {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.isPagingEnabled = true
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isScrollEnabled = false
            tableView.ts_registerCellNib(HomeNewsTableViewCell.self)
        }
    }
    
    var currentPage = 0
    
    var notifications: [NotificationListModel] = []
    var parentVC: HomeVC!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ notifications: [NotificationListModel], vc: HomeVC) {
        
        /*for i in 0..<11 {
            var string = "News Item here...\(i)"
            if i == 0 {
                string = "News Item here...10"
            }
            self.dataSource.append(string)
        }*/
        
        if notifications.count < 1 {
            return
        }
        
        self.notifications = notifications
        self.parentVC = vc
        
        tableView.ts_reloadData {
            /*if vc.timer != nil {
                vc.timer.invalidate()
                vc.timer = nil
            }
            vc.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.timerDidFire), userInfo: nil, repeats: true)*/
        }
        
    }
    
    @objc func timerDidFire() {
        var contentOffset = CGPoint.zero
        
        if currentPage >= 10 {
            currentPage = 0
            contentOffset = CGPoint(x: 0, y: 0)
            tableView.setContentOffset(contentOffset, animated: false)
        }
        
        currentPage += 1
        contentOffset = CGPoint(x: 0, y: 44 * currentPage)
        
        if contentOffset != CGPoint.zero {
            tableView.setContentOffset(contentOffset, animated: true)
        }
    }
    
}



extension HomeNewsCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeNewsTableViewCell = tableView.ts_dequeueReusableCell(HomeNewsTableViewCell.self)
        cell.setCellContent(notifications[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*print("Home News Cell Selected At...", indexPath.row)
        let notification = self.notifications[indexPath.row]
        
        if notification.itemId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = notification.itemId!
            parentVC.pushAndHideTabbar(vc)
        } else if notification.storeId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = notification.storeId!
            parentVC.pushAndHideTabbar(vc)
        } else if notification.siteUrl != nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
            vc.urlString = notification.siteUrl!
            vc.navBarTitle = ""
            parentVC.pushAndHideTabbar(vc)
        }*/
        
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: NotificationVC.nameOfClass)
        parentVC.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}














