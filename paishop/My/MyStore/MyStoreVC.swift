

import UIKit

class MyStoreVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var degreeButtonLabel: RoundRectButton!
    @IBOutlet weak var paiButtonLabel: RoundButton!
    @IBOutlet weak var pointButtonLabel: RoundButton!
    
    @IBOutlet weak var productManageView: UIView!
    @IBOutlet weak var productPostView: UIView!
    @IBOutlet weak var ordersView: UIView!
    @IBOutlet weak var storeSettleView: UIView!
    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var upgradeView: UIView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView! {
        didSet {
            imageView3.setTintColor(UIColor.init(colorWithHexValue: 0x9edf45))
        }
    }
    @IBOutlet weak var imageView4: UIImageView! {
        didSet {
            imageView4.setTintColor(UIColor.init(colorWithHexValue: 0xee7a76))
        }
    }
    @IBOutlet weak var imageView5: UIImageView! {
        didSet {
            imageView5.setTintColor(UIColor.init(colorWithHexValue: 0x9a8bf7))
        }
    }
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var withdrawButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserInstance.hasStore() {
            storeLabel.text = "店铺修改"
        } else {
            storeLabel.text = "新店入驻"
        }
        self.setupUI()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "店铺管理"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }

        
    private func setupUI() {
        self.withdrawButton.layer.cornerRadius = 10
        
        self.nameLabel.text = Utils.getNickName()
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        
        let degreeId = UserInstance.degreeId!
        if degreeId  > 0 {
            var degreeNames: [String] = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.degreeNameArray.count > 0 {
                degreeNames = appDelegate.degreeNameArray
            } else {
                degreeNames = UserDefaultsUtil.shared.getDegreeNameArray()
            }
            if degreeNames.count >= degreeId {
                self.degreeButtonLabel.setTitle(degreeNames[degreeId - 1], for: .normal)
            }
        } else {
            self.degreeButtonLabel.setTitle("免费版", for: .normal)
        }
        paiButtonLabel.setTitle("￥" + UserInstance.rmbBalance!, for: .normal)
        //paiButtonLabel.setTitle("￥" + UserInstance.paiBalance!, for: .normal)
        //pointButtonLabel.setTitle("π积分 : " + UserInstance.point!, for: .normal)
        
    }
    
    @IBAction func selectAvatar(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProductManage(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreProductManageVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectProductPost(_ sender: UIButton) {
        if UserInstance.hasVerifiedStore() {
//            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreProductPostVC.nameOfClass)
//            self.navigationController?.pushViewController(vc, animated: true)
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreProductPostVC1.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.presentAlert("你必须先入驻新店.")
        }
    }
    
    @IBAction func selectOrders(_ sender: Any) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreOrderVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectStoreSettle(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreStorePostVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectVideo(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyVideoPlayVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectUpgrade(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoUpgradeVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func withdrawBtnTapped(_ sender: Any) {
        print("%%%%% tapped %%%%%%")
        if (UserInstance.alipayAddress == "") {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreStorePostVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
            vc.index = 6
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func testTapped(_ sender: Any) {
        print("%%%%% tapped %%%%%%")
        if (UserInstance.alipayAddress == "") {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyStoreStorePostVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmWebViewController.nameOfClass) as! MyRecmWebViewController
            vc.index = 6
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

}




extension MyStoreVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}



















