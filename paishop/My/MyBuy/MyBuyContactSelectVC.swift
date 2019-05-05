//
//  MyBuyContactSelectVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyBuyContactSelectVC: UIViewController {
    
    var contacts: [ContactModel] = []
    var senderVC: String!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyBuyContactSelectCell.self)
        }
    }
    
    @IBOutlet weak var addButton: RoundRectButton!
    @IBOutlet weak var addButtonBg: GradientView!    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactAddBack(_:)), name: NSNotification.Name(Notifications.CONTACT_ADD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactsBack(_:)), name: NSNotification.Name(Notifications.CONTACTS_BACK), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "选择收货地址"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        navBar.rightButton.isHidden = false
        navBar.rightButton.addTarget(self, action: #selector(selectNavRight), for: .touchUpInside)
        navBar.rightButton.setTitle("管理", for: .normal)
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        addButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        addButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }

    @IBAction func selectAdd(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactAddVC.nameOfClass) as! MyBuyContactAddVC
        vc.isAdd = true
        vc.senderVC = MyBuyContactSelectVC.nameOfClass
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func selectNavRight() {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactManageVC.nameOfClass) as! MyBuyContactManageVC
        vc.contacts = self.contacts
        vc.senderVC = MyBuyContactSelectVC.nameOfClass
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func receiveContactAddBack(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyContactSelectVC.nameOfClass {
            return
        }
        
        guard let contact = notification.userInfo?["contact"] as? ContactModel else {
            return
        }
        
        self.contacts.append(contact)
        self.tableView.reloadData()
    }
    
    @objc func receiveContactsBack(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyContactSelectVC.nameOfClass {
            return
        }
        
        guard let temp = notification.userInfo?["contacts"] as? [ContactModel] else { return }
        
        self.contacts = temp
        self.tableView.reloadData()
    }

}



extension MyBuyContactSelectVC: NavBarDelegate {
    func didSelectBack() {
        if senderVC != nil {
            let info: [String : Any] = [
                "senderVC" : senderVC,
                "contacts" : contacts
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.CONTACTS_BACK), object: nil, userInfo: info)
        }
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyBuyContactSelectVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyBuyContactSelectCell = tableView.ts_dequeueReusableCell(MyBuyContactSelectCell.self)
        cell.setCellContent(contacts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let info1: [String : Any] = [
            "contact" : self.contacts[indexPath.row]
        ]
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.CONTACT_SELECT), object: nil, userInfo: info1)
        
        if senderVC != nil {
            let info2: [String : Any] = [
                "senderVC" : senderVC,
                "contacts" : contacts
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.CONTACTS_BACK), object: nil, userInfo: info2)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}








