
import UIKit

class MyWalletRechargeDetailVC: UIViewController {

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var realAmountLabel: UILabel!
    @IBOutlet weak var paymentAddressLabel: UILabel!
    @IBOutlet weak var paymentPhoneLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    
    @IBOutlet weak var transactionImageFrame: UIView!
    @IBOutlet weak var transactionImageView: UIImageView!
    
    
    var paymentDetail: PaymentListModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.setupNavBar()
        self.setupUI()
        
        
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "钱包提"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupUI() {
        self.amountLabel.text = paymentDetail.paymentAmount
        var fee = Double(paymentDetail.fee!)
        if fee == nil {
            fee = 0.00
        }
        self.feeLabel.text = paymentDetail.fee! + "π"
        if paymentDetail.currency! == 2 {
            self.feeLabel.text = "¥" + paymentDetail.fee!
        }
        if (paymentDetail.fee?.isEmpty)! {
            self.feeLabel.text = "0π"
            if paymentDetail.currency! == 2 {
                self.feeLabel.text = "¥0"
            }
            fee = 0.00
        }
        let realAmount = Double(paymentDetail.amount!)! - fee!
        realAmountLabel.text = String(realAmount) + "π"
        if paymentDetail.currency! == 2 {
            realAmountLabel.text = "¥" + String(realAmount)
        }
        paymentAddressLabel.text = paymentDetail.paymentAddress
        paymentPhoneLabel.text = paymentDetail.paymentPhone
        contactPhoneLabel.text = paymentDetail.contactPhone
        
        if(paymentDetail.paymentImage! == "") {
            transactionImageFrame.isHidden = true
            transactionImageFrame.snp.makeConstraints { (make) in
                make.height.equalTo(0)
            }
        } else {
            transactionImageFrame.isHidden = false
            print("payment image..........", paymentDetail.paymentImage!)
            let resizedUrl = Utils.getResizedImageUrlString(paymentDetail.paymentImage!, width: "800")
            transactionImageView.setImageWithURLString(resizedUrl)
        }
    }

}

extension MyWalletRechargeDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
