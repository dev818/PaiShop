//
//  NotificationVC.swift
//  paishop
//
//  Created by SeniorCorder on 5/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(NotificationCell.self)
        }
    }
    
    var notifications: [NotificationListModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.loadNotificationLists()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "公告咨询"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func loadNotificationLists() {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        ProgressHUD.showWithStatus()
        HomeAPI.shared.notificationList { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.notifications = NotificationListModel.getNotificationListsFromJson(json["notifications"])
                print("Notifications........", json)
                DispatchQueue.main.async(execute: {
                    self.tableView.ts_reloadData { }
                })
            } else {
                //load again...
                HomeAPI.shared.notificationList(completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        print("Notifications........", json)
                        self.notifications = NotificationListModel.getNotificationListsFromJson(json["notifications"])
                        DispatchQueue.main.async(execute: {
                            self.tableView.ts_reloadData { }
                        })
                    }
                })
            }
        }
    }

}


extension NotificationVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationCell = tableView.ts_dequeueReusableCell(NotificationCell.self)
        cell.setCellContent(notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = self.notifications[indexPath.row]
        
        if notification.itemId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = notification.itemId!
            self.navigationController?.pushViewController(vc, animated: true)
        } else if notification.storeId != nil {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = notification.storeId!
            self.navigationController?.pushViewController(vc, animated: true)
            self.pushAndHideTabbar(vc)
        } else if notification.siteUrl != nil {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: WebViewVC.nameOfClass) as! WebViewVC
            vc.urlString = notification.siteUrl!
            vc.navBarTitle = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}






extension NotificationVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
