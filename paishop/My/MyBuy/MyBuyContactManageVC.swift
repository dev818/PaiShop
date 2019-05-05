//
//  MyBuyAddressManageVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyBuyContactManageVC: UIViewController {
    
    var contacts: [ContactModel] = []
    var senderVC: String!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyBuyContactManageCell.self)
        }
    }

    @IBOutlet weak var addButton: RoundRectButton!
    @IBOutlet weak var addButtonBg: GradientView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        
        if senderVC == nil {
            loadContactList()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactAddBack(_:)), name: NSNotification.Name(Notifications.CONTACT_ADD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveContactEditBack(_:)), name: NSNotification.Name(Notifications.CONTACT_EDIT), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "管理地址"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        addButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        addButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    @IBAction func selectAdd(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactAddVC.nameOfClass) as! MyBuyContactAddVC
        vc.isAdd = true
        vc.senderVC = MyBuyContactManageVC.nameOfClass
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func receiveContactAddBack(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyContactManageVC.nameOfClass {
            return
        }
        
        guard let contact = notification.userInfo?["contact"] as? ContactModel else {
            return
        }
        
        self.contacts.append(contact)
        self.tableView.reloadData()
    }
    
    @objc func receiveContactEditBack(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyContactManageVC.nameOfClass {
            return
        }
        
        guard let contact = notification.userInfo?["contact"] as? ContactModel else { return }
        
        guard let index = notification.userInfo?["index"] as? Int else { return }
        
        for i in 0..<self.contacts.count {
            if i == index {
                self.contacts[i] = contact
            }
        }
        self.tableView.reloadData()
    }
    
    private func loadContactList() {
        ProgressHUD.showWithStatus()
        MyAPI.shared.contactList { (json, success) in
            if success {
                ProgressHUD.dismiss()
                print("Contact List...", json)
                self.contacts = ContactModel.getContactsFromJson(json["contacts"])
                self.tableView.reloadData()
            } else {
                // try again...
                MyAPI.shared.contactList(completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        self.contacts = ContactModel.getContactsFromJson(json1["contacts"])
                        self.tableView.reloadData()
                    } else {
                        self.addButton.isEnabled = false
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("失败.")
                        }
                    }
                })
            }
        }
    }

}


extension MyBuyContactManageVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyBuyContactManageCell = tableView.ts_dequeueReusableCell(MyBuyContactManageCell.self)
        cell.setCellContent(self, index: indexPath.row)
        return cell
    }
    
    
    
}


extension MyBuyContactManageVC: NavBarDelegate {
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






