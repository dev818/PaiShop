

import UIKit

class ChatUserProfileVC: UIViewController {
    
    var userInfo: UserModel!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: RoundImageView! {
        didSet {
            avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
            avatarImageView.layer.borderWidth = 2
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var introductionView: UIView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupUI()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = userInfo.name
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupUI() {
        let resizedUrl = Utils.getResizedImageUrlString(userInfo.image!, width: "200")
        avatarImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        nameLabel.text = userInfo.name
        phoneLabel.text = userInfo.phoneNumber
        addressLabel.text = userInfo.address
        introductionLabel.text = userInfo.introduction
        
        if userInfo.address!.isEmpty {
            addressView.isHidden = true
            addressView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
        }
        if userInfo.introduction!.isEmpty {
            introductionView.isHidden = true
            introductionView.snp.updateConstraints({ (make) in
                make.height.equalTo(0)
            })
        }
        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(selectPhone))
        phoneLabel.isUserInteractionEnabled = true
        phoneLabel.addGestureRecognizer(phoneTap)
    }
    
    @objc func selectPhone() {
        Utils.applyTouchEffect(phoneLabel)
        
        let phoneString = userInfo.phoneNumber
        if let phoneStr = phoneString, !phoneStr.isEmpty {
            if let phoneCallURL:URL = URL(string: "tel://\(phoneStr)") {
                print("call phone=\(phoneStr)")
                let application:UIApplication = UIApplication.shared
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }


}



extension ChatUserProfileVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}




















