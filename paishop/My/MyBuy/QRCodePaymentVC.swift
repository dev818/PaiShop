//
//  QRCodePaymentVC.swift
//  paishop
//
//  Created by Topdeveloper on 11/28/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class QRCodePaymentVC: UIViewController {

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var txtBalance: UITextField!
    @IBOutlet weak var btnPay: RoundRectButton!
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var viewDark: UIView!
    @IBOutlet var checkMarkList: [UIImageView]!
    
    @IBOutlet var customPayView: UIView!
    @IBOutlet var confirmPayView: UIView!
    @IBOutlet weak var payMethodImgOfConfirmView: UIImageView!
    let payImages: [UIImage] = [
        ImageAsset.payment_pai.image,
        //ImageAsset.payment_point.image,
        //ImageAsset.payment_weixin.image,
        ImageAsset.payment_ali.image,
        ]
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var ratePaiVSYeanLbl: UILabel!
    
    var strSubURL: Substring!
    
    var userId = 0
    var paymentType = 1 // Pai: 1, Point:2, Weixin: 1, Alipay: 2
    var currencyRate: Double = 6.58
    var totalPrice: Double = 0.00
    var oldSelectedMethod = 0 // 0: pai, 1: point, 2: weixin, 3: alipay
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentSuccess(_:)), name: NSNotification.Name(Notifications.ALIPAY_SUCCESS), object: nil)
        
        self.loadInformation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "付款"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func initUI() {
        
        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor(colorWithHexValue: 0xB830C6).cgColor
        outerView.layer.shadowOpacity = 0.5
        outerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        outerView.layer.shadowRadius = 10
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
        
        imgUser.layer.cornerRadius = 10
        imgUser.clipsToBounds = true
        
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        viewContainer.layer.shadowOpacity = 0.5
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.currencyRate != nil {
            self.currencyRate = appDelegate.currencyRate
        } else {
            self.currencyRate = UserDefaultsUtil.shared.getCurrencyRate()
        }
        let rateString = "1π=" + String.init(format:"%.2f", self.currencyRate) + "人民币"
        self.ratePaiVSYeanLbl.text = rateString
        
        let viewDarkTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        viewDark.isUserInteractionEnabled = true
        viewDark.addGestureRecognizer(viewDarkTap)
        
        self.view.addSubview(customPayView)
        customPayView.translatesAutoresizingMaskIntoConstraints = false
        customPayView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(270)
            make.bottom.equalTo(self.view.bottom).offset(270)
        }
        
        self.view.addSubview(confirmPayView)
        confirmPayView.translatesAutoresizingMaskIntoConstraints = false
        confirmPayView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(315)
            make.bottom.equalTo(self.view.bottom).offset(315)
        }
    }
    
    func loadInformation() {
        ProgressHUD.showWithStatus()
        MyAPI.shared.getQRCodeInformation(strUrl: String(strSubURL)) { (json, success) in
            ProgressHUD.dismiss()
            if success {
                if let status = json["success"] as? Bool, let storeName = json["stores_name"] as? String,
                    let userId = json["user_id"] as? Int, let userName = json["user_name"] as? String {
                    if status {
                        self.navBar.lblTitle.text = storeName
                        self.lblUsername.text = userName
                        self.userId = userId
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func selectDarkView() {
        self.hideCustomPayView()
        self.hideConfirmPayView()
        self.showDarkView(false)
    }
    
    private func showDarkView(_ state: Bool) {
        if state {
            self.viewDark.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.viewDark.alpha = 0.8
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.viewDark.alpha = 0
            }, completion: { (finished) in
                self.viewDark.isHidden = true
            })
        }
    }
    
    func showCheckMark(selectedMethod: Int) {
        checkMarkList[oldSelectedMethod].isHidden = true
        checkMarkList[selectedMethod].isHidden = false
        oldSelectedMethod = selectedMethod
    }
    
    @IBAction func btnPayClicked(_ sender: Any) {
        if !txtBalance.text!.isEmpty, let cost = Double(txtBalance.text!) {
            self.totalPrice = cost
            self.showCustomPayView()
        }
    }
    
    @IBAction func hidePayMethodView(_ sender: Any) {
        self.hideCustomPayView()
        self.showDarkView(false)
    }
    
    @IBAction func selectPaiPay(_ sender: UIButton) {
        showCheckMark(selectedMethod: 0)
        self.paymentType = 1
    }
    
//    @IBAction func selectPointPay(_ sender: UIButton) {
//        showCheckMark(selectedMethod: 1)
//        self.paymentType = 2
//    }
    
    @IBAction func selectAliPay(_ sender: UIButton) {
        showCheckMark(selectedMethod: 1)
        self.paymentType = 3
    }
    
    private func showCustomPayView() {
        self.customPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func hideCustomPayView() {
        self.customPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(315)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func goBackCustomPayView(_ sender: UIButton) {
        self.hideConfirmPayView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showCustomPayView()
        }
    }
    
    @IBAction func goConfirmPayView(_ sender: Any) {
        if oldSelectedMethod == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentAlert("暂未开放!")
            }
        } else {
            self.hideCustomPayView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showConfirmPayView()
            }
        }
    }
    
    @IBAction func clickConfirmBtn(_ sender: Any) {
        
        self.hideConfirmPayView()
        self.showDarkView(false)
        
        let params: [String : Any] = [
            "amount": self.totalPrice,
            "user_id": self.userId,
            "type": self.paymentType
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.createQRCodePay(params: params) { (json, success) in
            print(json)
            ProgressHUD.dismiss()
            if success {
                if let status = json["state"] as? Int {
                    if status == 200 {
                        
                        if (self.paymentType == 3) {
                            let orderString = json["result"] as! String
                            self.AliplayFunc(orderString: orderString)
                        } else {
                            ProgressHUD.showSuccessWithStatus("成功购买!")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                ProgressHUD.dismiss()
                            })
                        }
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showConfirmPayView() {
        self.setupConfirmView()
        self.confirmPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        //self.showDarkView(true)
    }
    
    func setupConfirmView() {
        self.payMethodImgOfConfirmView.image = self.payImages[oldSelectedMethod]
        if oldSelectedMethod == 0 {
            let paiTotal = self.totalPrice / self.currencyRate
            self.finalPriceLabel.text = String.init(format: "%.2f", paiTotal) + "π"
        } else if oldSelectedMethod == 1 {
            self.finalPriceLabel.text = "¥" + String.init(format: "%.2f", self.totalPrice)
        }
    }
    
    private func hideConfirmPayView() {
        self.confirmPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(315)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func AliplayFunc(orderString: String) {
        levelPayment = false
        let appScheme = "paishop"
        
        TRADE_NO = ""
        OUT_TRADE_NO = ""
        TRADE_NUMBER = ""
        SELLER_ID = ""
        
        VCArray = self.navigationController?.viewControllers as NSArray?
        
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { resultDic in
            print(resultDic as Any)
            
            let result = (resultDic! as NSDictionary)
            let returnCode: String = result["resultStatus"] as! String
            //var returnMsg: String = result["memo"] as! String
            //var subResultMsg:String = ""
            switch  returnCode{
            case "6001":
                break
            case "8000":
                ProgressHUD.showErrorWithStatus("支付失败，请您重新支付！")
                break
            case "4000":
                ProgressHUD.showErrorWithStatus("支付失败，请您重新支付！")
                break
            case "9000":
                //支付返回信息：外系统订单号、内部系统订单号等信息
                //JSON.init(parseJSON: (result["result"] as! String))["alipay_trade_app_pay_response"]["sub_msg"].stringValue
                ProgressHUD.showSuccessWithStatus("支付成功")
                break
            default:
                break
            }
            
        })
    }
    
    @objc func paymentSuccess(_ notification: Notification) {
        if !(AlipayPaid) { return }
        AlipayPaid = false
        print("Alipay Success!")
        //ProgressHUD.showSuccessWithStatus("支付成功")
        
        let parameters: [String : Any] = [
            "trade_no" : OUT_TRADE_NO,
            "tradeNumber_id" : TRADE_NUMBER,
            "sellerId" : SELLER_ID,
        ]
        print(parameters)
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentQRSuccess(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            if success {
                ProgressHUD.showSuccessWithStatus("支付已完成!")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    ProgressHUD.dismiss()
                    let tab: [String : Any] = ["tab" : 4]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.MOVE_TAB_BAR), object: nil, userInfo: tab)
                    
                    self.navigationController?.popViewController(animated: true)
                })
                
            } else {
                print("failure >>>> json:\n", json)
            }
        }
    }
    
}

extension QRCodePaymentVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
