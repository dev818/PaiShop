
import UIKit

class MyWalletVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var paiLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!    
    
    var serverPaiAddress: String = ""
    var serverPaiPhone: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        self.loadProfile()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "我的钱包"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.serverPaiAddress != nil {
            self.serverPaiAddress = appDelegate.serverPaiAddress
        } else {
            self.serverPaiAddress = UserDefaultsUtil.shared.getServerPaiAddress()
        }
        if appDelegate.serverPaiPhone != nil {
            self.serverPaiPhone = appDelegate.serverPaiPhone
        } else {
            self.serverPaiPhone = UserDefaultsUtil.shared.getServerPaiPhone()
        }
        
        
        self.setupHeaderFields()
    }
    
    private func setupHeaderFields() {
        self.paiLabel.text = UserInstance.paiBalance!
        self.pointLabel.text = UserInstance.point!
    }
    
    @IBAction func selectRecharge(_ sender: UIButton) {
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletChooseVC.nameOfClass) as! MyWalletChooseVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectWithdraw(_ sender: UIButton) {
        if UserInstance.paiAddress!.isEmpty {
            self.presentAlert("没有π账号", message: "你没有π账号. \n 请添加你的π账号详细信息.")
            return
        }
//        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletWithdrawVC.nameOfClass) as! MyWalletWithdrawVC
//        vc.serverPaiAddress = self.serverPaiAddress
//        vc.serverPaiPhone = self.serverPaiPhone
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyWalletPointConverterVC.nameOfClass) as! MyWalletPointConverterVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectTransactionPass(_ sender: UIButton) {
        if UserInstance.guardPayment {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassChangeVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func selectPiReturn(_ sender: UIButton) {        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyBillingListVC.nameOfClass) as! MyBillingListVC
        vc.currency = 1
        vc.type = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadProfile() {
        ProgressHUD.showWithStatus()
        AuthAPI.shared.profileGet(completion: { (json, success) in
            if success {
                ProgressHUD.dismiss()
                UserInstance.userLoginSuccess(json["profile"])
                print("Profile Get...")
                print(json)
                DispatchQueue.main.async {
                    self.setupUI()
                }
            } else {
                // try again...
                AuthAPI.shared.profileGet(completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        UserInstance.userLoginSuccess(json["profile"])
                    }
                    DispatchQueue.main.async {
                        self.setupUI()
                    }
                })
                
            }
        })
    }
    

}



extension MyWalletVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}











