//
//  MyBillingVC.swift


import UIKit

class MyBillingVC: UIViewController {
    
    @IBOutlet weak var backImageView: UIImageView! {
        didSet {
            backImageView.setTintColor(UIColor.white)
        }
    }
    @IBOutlet weak var avatarImageView: RoundImageView! {
        didSet {
            avatarImageView.layer.borderColor = UIColor(colorWithHexValue: 0x2486cb).cgColor
            avatarImageView.layer.borderWidth = 4
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var paiLabel: UILabel!
    @IBOutlet weak var rmbLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var degreeImageview: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
    
    @IBOutlet weak var paiView: UIStackView!
    @IBOutlet weak var rmbView: UIStackView!
    @IBOutlet weak var pointView: UIStackView!
    @IBOutlet weak var degreeView: UIStackView!
    
    @IBOutlet weak var paiListView: UIView!
    @IBOutlet weak var yuanListView: UIView!
    @IBOutlet weak var pointListView: UIView!
    @IBOutlet weak var returnListView: UIView!
    
    @IBOutlet weak var piImageView: UIImageView! {
        didSet {
            piImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    @IBOutlet weak var yuanImageView: UIImageView! {
        didSet {
            yuanImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    @IBOutlet weak var pointImageView: UIImageView! {
        didSet {
            pointImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    @IBOutlet weak var returnImageView: UIImageView! {
        didSet {
            returnImageView.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupHeaderFields()
    }
    
    
    private func setupUI() {
        let paiListTap = UITapGestureRecognizer(target: self, action: #selector(selectPaiList))
        paiListView.isUserInteractionEnabled = true
        paiListView.addGestureRecognizer(paiListTap)
        
        let yuanListTap = UITapGestureRecognizer(target: self, action: #selector(selectYuanList))
        yuanListView.isUserInteractionEnabled = true
        yuanListView.addGestureRecognizer(yuanListTap)
        
        let pointListTap = UITapGestureRecognizer(target: self, action: #selector(selectPointList))
        pointListView.isUserInteractionEnabled = true
        pointListView.addGestureRecognizer(pointListTap)
        
        let returnListTap = UITapGestureRecognizer(target: self, action: #selector(selectReturnList))
        returnListView.isUserInteractionEnabled = true
        returnListView.addGestureRecognizer(returnListTap)
                
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(selectAvatar))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(avatarTap)
        
        let paiTap = UITapGestureRecognizer(target: self, action: #selector(selectPai))
        paiView.isUserInteractionEnabled = true
        paiView.addGestureRecognizer(paiTap)
        
        let rmbTap = UITapGestureRecognizer(target: self, action: #selector(selectRmb))
        rmbView.isUserInteractionEnabled = true
        rmbView.addGestureRecognizer(rmbTap)
        
        let pointTap = UITapGestureRecognizer(target: self, action: #selector(selectPoint))
        pointView.isUserInteractionEnabled = true
        pointView.addGestureRecognizer(pointTap)
        
        let degreeTap = UITapGestureRecognizer(target: self, action: #selector(selectDegree))
        degreeView.isUserInteractionEnabled = true
        degreeView.addGestureRecognizer(degreeTap)
        
        self.setupHeaderFields()
    }
    
    private func setupHeaderFields() {
        self.nameLabel.text = Utils.getNickName()
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "200")
        self.avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.paiLabel.text = "π : " + UserInstance.paiBalance!
        self.rmbLabel.text = "余额 : " + UserInstance.rmbBalance!
        self.pointLabel.text = "π积分 : " + UserInstance.point!
        
        self.degreeImageview.image = UIImage(named: "my_total.png")
        let degreeId = UserInstance.degreeId!
        if degreeId  > 0 {
            var degreeImages: [String] = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.degreeImageArray.count > 0 {
                degreeImages = appDelegate.degreeImageArray
            } else {
                degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
            }
            if degreeImages.count >= degreeId {
                self.degreeImageview.setImageWithURLString(degreeImages[degreeId - 1])
            }
            self.degreeLabel.text = UserInstance.degreePeriod
            self.degreeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        } else {
            self.degreeLabel.text = "  商家 : 免费版"
            self.degreeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBAction func selectBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func selectPaiList() {
        Utils.applyTouchEffect(paiListView)
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingListVC.nameOfClass) as! MyBillingListVC
        vc.currency = 1
        vc.type = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectYuanList() {
        Utils.applyTouchEffect(yuanListView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingListVC.nameOfClass) as! MyBillingListVC
        vc.currency = 2
        vc.type = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectPointList() {
        Utils.applyTouchEffect(pointListView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingListVC.nameOfClass) as! MyBillingListVC
        vc.currency = 3
        vc.type = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectReturnList() {
        Utils.applyTouchEffect(returnListView)
        self.performSegue(withIdentifier: MyBillingReturnListVC.nameOfClass, sender: self)
    }
    
    @objc func selectAvatar() {
        Utils.applyTouchEffect(avatarImageView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoEditVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func selectPai() {
        Utils.applyTouchEffect(paiView)
        goToWalletVC()
    }
    
    @objc func selectRmb() {
        Utils.applyTouchEffect(rmbView)
        goToWalletVC()
    }
    
    @objc func selectPoint() {
        Utils.applyTouchEffect(pointView)
        goToWalletVC()
    }
    
    @objc func selectDegree() {
        Utils.applyTouchEffect(degreeView)
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyUserInfoUpgradeVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToWalletVC() {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletVC.nameOfClass)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    

}










