//
//  MyBuyContactAddVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyBuyContactAddVC: UIViewController {
    
    var isModal = false
    var isAdd = true // true->add, false->edit
    var senderVC: String!
    var index: Int!
    var contact: ContactModel!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressTextView: UITextView! {
        didSet {
            addressTextView.placeholder = "请输入详细地址"
        }
    }
    @IBOutlet weak var defaultAddressSwitch: UISwitch!
    @IBOutlet weak var saveButton: RoundRectButton!
    @IBOutlet weak var saveButtonBg: GradientView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        
        if isAdd {
            saveButton.setTitle("添加", for: .normal)
        } else {
            nameField.text = contact.name
            phoneField.text = contact.phoneNumber
            addressTextView.text = contact.address
            defaultAddressSwitch.setOn(contact.main, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAddress(_:)), name: NSNotification.Name(Notifications.SELECT_ADDRESS), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "新增收货地址"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        defaultAddressSwitch.onTintColor = MainColors.themeEndColors[selectedTheme]
        saveButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        saveButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }

    @IBAction func selectAddress(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreAddressVC.nameOfClass) as! MyStoreAddressVC
        vc.senderVC = MyBuyContactAddVC.nameOfClass
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func defaultAddressChanged(_ sender: UISwitch) {
    }
    
    @IBAction func selectSave(_ sender: UIButton) {
        
        if !validateFields() {
            return
        }
        
        let name = nameField.text!
        let phone = phoneField.text!
        let address = addressTextView.text!
        let isDefault = defaultAddressSwitch.isOn
        
        var parameters: [String : Any] = [
            "name" : name,
            "phone_number" : phone,
            "address" : address,
            "main" : isDefault
        ]
        
        ProgressHUD.showWithStatus()
        saveButton.isEnabled = false
        
        if self.isAdd { // add new contact
            MyAPI.shared.contactAdd(params: parameters) { (json, success) in
                ProgressHUD.dismiss()
                self.saveButton.isEnabled = true
                if success {
                    print("Contact Add...", json)
                    self.contact = ContactModel.init(json["contact"])
                    if self.senderVC != nil {
                        let info: [String : Any] = [
                            "senderVC" : self.senderVC!,
                            "contact" : self.contact
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.CONTACT_ADD), object: nil, userInfo: info)
                        if self.isModal {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
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
        } else { // edit contact
            parameters["id"] = self.contact.id
            MyAPI.shared.contactUpdate(params: parameters) { (json, success) in
                ProgressHUD.dismiss()
                self.saveButton.isEnabled = true
                if success {
                    print("Contact Edit...", json)
                    self.contact = ContactModel.init(json["contact"])
                    if self.senderVC != nil {
                        let info: [String : Any] = [
                            "senderVC" : self.senderVC!,
                            "contact" : self.contact,
                            "index" : self.index
                        ]
                        NotificationCenter.default.post(name: NSNotification.Name(Notifications.CONTACT_EDIT), object: nil, userInfo: info)
                        self.navigationController?.popViewController(animated: true)
                    }
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
    
    
    @objc func receiveAddress(_ notification: Notification) {
        guard let senderVC = notification.userInfo?["senderVC"] as? String else { return }
        if senderVC != MyBuyContactAddVC.nameOfClass {
            return
        }
        if let addressInfo = notification.userInfo?["address"] as? BMKReverseGeoCodeResult {
            //self.lat = String(addressInfo.location.latitude)
            //self.lon = String(addressInfo.location.longitude)
            addressTextView.text = addressInfo.address
        }
    }
    
    private func validateFields() -> Bool {
        let name = nameField.text!
        let phone = phoneField.text!
        let address = addressTextView.text!
        
        if name.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入收货人名.")
            return false
        }
        if phone.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入联系电话.")
            return false
        }
        if address.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入详细地址.")
            return false
        }
        
        return true
    }
    
}



extension MyBuyContactAddVC: NavBarDelegate {
    func didSelectBack() {
        if senderVC != nil {
            let info: [String : Any] = [
                "senderVC" : self.senderVC!,
            ]
            NotificationCenter.default.post(name: NSNotification.Name(Notifications.CONTACT_ADD), object: nil, userInfo: info)
        }
        
        if isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}







