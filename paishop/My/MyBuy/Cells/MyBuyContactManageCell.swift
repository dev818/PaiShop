//
//  MyBuyContactManageCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyBuyContactManageCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var defaultAddressImageView: UIImageView!

    
    var parentVC: MyBuyContactManageVC!
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: MyBuyContactManageVC, index: Int) {
        self.parentVC = vc
        self.index = index
        let contact = self.parentVC.contacts[index]
        
        nameLabel.text = contact.name
        phoneLabel.text = contact.phoneNumber
        addressLabel.text = contact.address
        if contact.main {
            defaultAddressImageView.image = UIImage(named: "ic_my_check_select")
        } else {
            defaultAddressImageView.image = UIImage(named: "ic_my_check_deselect")
        }
    }
    
    @IBAction func selectEdit(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactAddVC.nameOfClass) as! MyBuyContactAddVC
        vc.isAdd = false
        vc.senderVC = MyBuyContactManageVC.nameOfClass
        vc.index = self.index
        vc.contact = parentVC.contacts[index]
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectDelete(_ sender: UIButton) {
        let contactId = parentVC.contacts[index].id!
        
        let parameters: [String : Any] = [
            "id" : contactId
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.contactDelete(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            if success {
                self.parentVC.contacts.remove(at: self.index)
                self.parentVC.tableView.reloadData()
            } else {
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
        }
        
    }
    
    
}






