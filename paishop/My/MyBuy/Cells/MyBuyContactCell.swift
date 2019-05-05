
import UIKit


class MyBuyContactCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
        }
    }
    @IBOutlet weak var phoneLabel: UILabel! {
        didSet {
            phoneLabel.text = ""
        }
    }
    @IBOutlet weak var addressLabel: UILabel! {
        didSet {
            addressLabel.text = ""
        }
    }
    
    var parentVC: MyBuyVC!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setCellContent(_ vc: MyBuyVC) {
        self.parentVC = vc
        if vc.defaultContact != nil {
            nameLabel.text = vc.defaultContact.name
            phoneLabel.text = vc.defaultContact.phoneNumber
            addressLabel.text = vc.defaultContact.address
        }
        
    }
    
    @IBAction func selectAddressView(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBuyContactSelectVC.nameOfClass) as! MyBuyContactSelectVC
        vc.contacts = self.parentVC.contacts
        vc.senderVC = MyBuyVC.nameOfClass
        self.parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



/*
class MyBuyContactCell: UITableViewCell {
    
    @IBOutlet weak var addressSelectFrame: UIView!
    @IBOutlet weak var addressTextView: UITextView! {
        didSet {
            addressTextView.placeholder = "请输入您的详细地址"
        }
    }
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField! {
        didSet {
            phoneField.delegate = self
        }
    }
    
    var parentVC: MyBuyVC!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let addressSelectTap = UITapGestureRecognizer(target: self, action: #selector(selectAddress))
        addressSelectFrame.isUserInteractionEnabled = true
        addressSelectFrame.addGestureRecognizer(addressSelectTap)
        
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        nameField.textColor = MainColors.themeEndColors[selectedTheme]
        phoneField.textColor = MainColors.themeEndColors[selectedTheme]
        addressTextView.textColor = MainColors.themeEndColors[selectedTheme]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(vc: MyBuyVC) {
        self.parentVC = vc
        
        self.nameField.text = parentVC.name
        self.phoneField.text = parentVC.phoneNumber
        self.addressTextView.text = parentVC.address
    }
    
    @objc func selectAddress() {
        parentVC.view.endEditing(true)
        Utils.applyTouchEffect(addressSelectFrame)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreAddressVC.nameOfClass) as! MyStoreAddressVC
        vc.senderVC = MyBuyVC.nameOfClass
        
        if !parentVC.lat.isEmpty && !parentVC.lon.isEmpty {
            vc.storeLocation = CLLocationCoordinate2D(latitude: Double(parentVC.lat)!, longitude: Double(parentVC.lon)!)
        }        
        parentVC.pushAndHideTabbar(vc)
    }
    
}

extension MyBuyContactCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if textField == phoneField {
            return newLength <= 11
        }
        return true
    }
}

*/










