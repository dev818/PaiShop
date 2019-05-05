//
//  MyRecmBuyLevelVC.swift
//  paishop
//
//  Created by Admin on 8/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyRecmBuyLevelVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var individualDescriptionView: UIView! {
        didSet { individualDescriptionView.isHidden = true}
    }
    
    @IBOutlet weak var userProfileImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userPhoneNumberLbl: UILabel!
    @IBOutlet weak var userLevelImg: UIImageView!
    @IBOutlet weak var userLevelNameLbl: UILabel!
    
    @IBOutlet var descriptionViewList: [UIView]!
    @IBOutlet weak var indiviDescViewTitle: UILabel!
    @IBOutlet weak var indiviDescViewContent: UILabel!
    @IBOutlet var smallLevelImage: [UIImageView]!
    @IBOutlet var largeLevelImage: [UIImageView]!
    @IBOutlet var levelNameLabel: [UILabel]!
    
    // sentences
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSentence1: UILabel!
    @IBOutlet weak var lblSentence2: UILabel!
    @IBOutlet weak var lblSentence3: UILabel!
    @IBOutlet weak var lblSentence4: UILabel!
    @IBOutlet weak var lblSentence5: UILabel!
    @IBOutlet weak var lblSentence6: UILabel!
    @IBOutlet weak var lblSentence7: UILabel!
    @IBOutlet weak var lblSentence8: UILabel!
    
    // select level PopView
    @IBOutlet weak var darkView: UIView!
    @IBOutlet var showLevelPopView: UIView!
    @IBOutlet weak var userLevelPopImg: UIImageView!
    @IBOutlet weak var userLevelNamePopLbl: UILabel!
    @IBOutlet weak var userNamePopLbl: UILabel!
    @IBOutlet var largeLevelPopImage: [UIImageView]!
    @IBOutlet var smallLevelPopImage: [UIImageView]!
    @IBOutlet weak var levelPricePopLbl: UILabel!
    
    // select paymethod pop
    @IBOutlet var customPayView: UIView!
    @IBOutlet var checkMarkList: [UIImageView]!
    
    //confirm pop
    @IBOutlet var confirmPayView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var payTypeImage: UIImageView!
    let payImages: [UIImage] = [
        ImageAsset.payment_pai.image,
        ImageAsset.payment_weixin.image,
        ImageAsset.payment_ali.image,
        ]
    
    //transaction pop
    @IBOutlet var customTransactionView: UIView!
    @IBOutlet weak var transactionField: UITextField!
    @IBOutlet weak var buyButton: UIButton!
    
    
    var realLevel_fee = 0
    var myLevel_fee = 0
    var register_fee = 0
    var selectedPayType = 0
    var currencyRate: Double = 6.58
    var restitutionRate: Double = 200.00
    var oldSelectedLevel = UserInstance.level_id!
    var descTitleList: [String] = ["加入方式：", "推荐奖金：", "消费奖金：", "推荐商家：",
                                   "额外收益：", "晋升方式： ", "有效期：", "店铺管理费："]
    var descContentList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupUI()
        getMyLevelFee()
        self.initMainView()
        
        // default level1 btn tapped        
        self.firstLoadDescs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(createOrderLevel(_:)), name: NSNotification.Name(Notifications.LEVEL_ALIPAY_SUCCESS), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupCustomViews()
    }
    
    @objc func createOrderLevel(_ notification: Notification) {
        print("Alipay Success!")
        //ProgressHUD.showSuccessWithStatus("支付成功")
        
        let parameters: Parameters = [
            "level": oldSelectedLevel + 1,
            "currency" : 2
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.setByCurrency(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            print(json)
            if success {
                ProgressHUD.showSuccessWithStatus("升级成功")
                self.profileUpdate()
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "会员身份升级"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.currencyRate != nil {
            self.currencyRate = appDelegate.currencyRate
        } else {
            self.currencyRate = UserDefaultsUtil.shared.getCurrencyRate()
        }
        if appDelegate.restitutionRate != nil {
            self.restitutionRate = appDelegate.restitutionRate
        } else {
            self.restitutionRate = UserDefaultsUtil.shared.getRestitutionRate()
        }
        
        let rateString = "1π=" + String.init(format:"%.2f", self.currencyRate) + "人民币"
        self.rateLabel.text = rateString
        
        let darkViewTap = UITapGestureRecognizer(target: self, action: #selector(selectDarkView))
        darkView.isUserInteractionEnabled = true
        darkView.addGestureRecognizer(darkViewTap)
        
        // Personal Info //h.g.n.
        self.userNameLbl.text = Utils.getNickName()
        self.userPhoneNumberLbl.text = UserInstance.loginName!
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.userProfileImg.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.userLevelImg.image = levelImages[UserInstance.level_id!]
        if UserInstance.level_id! > 0 {
            self.userLevelNameLbl.text = levelNames[UserInstance.level_id!]
        } else {
            self.userLevelNameLbl.text = ""
        }
    }
    
    func initMainView() {
        lblDescription.text = ""
        lblSentence1.text = ""
        lblSentence2.text = ""
        lblSentence3.text = ""
        lblSentence4.text = ""
        lblSentence5.text = ""
        lblSentence6.text = ""
        lblSentence7.text = ""
        lblSentence8.text = ""
        
    }
    
    @objc func selectDarkView() {
        self.hideSelectedLevelPopView()
        self.hideCustomPayView()
        self.hideConfirmPayView()
        self.hideCustomTransactionView()
        self.showDarkView(false)
    }
    
    private func showDarkView(_ state: Bool) {
        if state {
            self.darkView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.8
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { (finished) in
                self.darkView.isHidden = true
            })
        }
    }
    
    private func setupCustomViews() {
        self.view.addSubview(customTransactionView)
        customTransactionView.translatesAutoresizingMaskIntoConstraints = false
        customTransactionView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(196)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        
        self.view.addSubview(showLevelPopView)
        showLevelPopView.translatesAutoresizingMaskIntoConstraints = false
        showLevelPopView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(266)
            make.bottom.equalTo(self.view.bottom).offset(266)
        }
        self.view.addSubview(customPayView)
        customPayView.translatesAutoresizingMaskIntoConstraints = false
        customPayView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(215)
            make.bottom.equalTo(self.view.bottom).offset(215)
        }
        
        self.view.addSubview(confirmPayView)
        confirmPayView.translatesAutoresizingMaskIntoConstraints = false
        confirmPayView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.width)
            make.height.equalTo(315)
            make.bottom.equalTo(self.view.bottom).offset(315)
        }
    }
    
    func changeSelectedLevelImgFont(oldSelectedLevel: Int, selectedLevel: Int) {
        
        individualDescriptionView.isHidden = true
        for i in 0..<9 {
            descriptionViewList[i].isHidden = false
        }
        
        if oldSelectedLevel != -1 {
            largeLevelImage[oldSelectedLevel].isHidden = true
            smallLevelImage[oldSelectedLevel].isHidden = false
            largeLevelPopImage[oldSelectedLevel].isHidden = true
            smallLevelPopImage[oldSelectedLevel].isHidden = false
            levelNameLabel[oldSelectedLevel].textColor = UIColor.darkGray
            levelNameLabel[oldSelectedLevel].font = levelNameLabel[oldSelectedLevel].font.withSize(11)
        }
        largeLevelImage[selectedLevel].isHidden = false
        smallLevelImage[selectedLevel].isHidden = true
        largeLevelPopImage[selectedLevel].isHidden = false
        smallLevelPopImage[selectedLevel].isHidden = true
        levelNameLabel[selectedLevel].textColor = UIColor.red
        levelNameLabel[selectedLevel].font = levelNameLabel[selectedLevel].font.withSize(14)
        self.oldSelectedLevel = selectedLevel
    }
    
    func firstLoadDescs() {
        var index = UserInstance.level_id!
        if index == 5 {
            index -= 1
            self.buyButton.isEnabled = false
        }
        self.requestGetBuyLevelInfo(index: index + 1)
        changeSelectedLevelImgFont(oldSelectedLevel: oldSelectedLevel, selectedLevel: index)
    }
    
    @IBAction func level1BtnTapped(_ sender: UIButton) {
        //if UserInstance.level_id! >= 1 { return }
        self.requestGetBuyLevelInfo(index: 1)
        changeSelectedLevelImgFont(oldSelectedLevel: oldSelectedLevel, selectedLevel: 0)
    }
    
    @IBAction func level2BtnTapped(_ sender: UIButton) {
        //if UserInstance.level_id! >= 2 { return }
        self.requestGetBuyLevelInfo(index: 2)
        changeSelectedLevelImgFont(oldSelectedLevel: oldSelectedLevel, selectedLevel: 1)
    }
    
    @IBAction func level3BtnTapped(_ sender: UIButton) {
        //if UserInstance.level_id! >= 3 { return }
        self.requestGetBuyLevelInfo(index: 3)
        changeSelectedLevelImgFont(oldSelectedLevel: oldSelectedLevel, selectedLevel: 2)
    }
    
    @IBAction func level4BtnTapped(_ sender: UIButton) {
        //if UserInstance.level_id! >= 4 { return }
        self.requestGetBuyLevelInfo(index: 4)
        changeSelectedLevelImgFont(oldSelectedLevel: oldSelectedLevel, selectedLevel: 3)
    }
    
    @IBAction func level5BtnTapped(_ sender: UIButton) {
        //if UserInstance.level_id! >= 5 { return }
        self.requestGetBuyLevelInfo(index: 5)
        changeSelectedLevelImgFont(oldSelectedLevel: oldSelectedLevel, selectedLevel: 4)
    }
    
    @IBAction func circleBtn1Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[0]
        indiviDescViewContent.text = self.descContentList[0]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn2Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[1]
        indiviDescViewContent.text = self.descContentList[1]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn3Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[2]
        indiviDescViewContent.text = self.descContentList[2]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn4Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[3]
        indiviDescViewContent.text = self.descContentList[3]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn5Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[4]
        indiviDescViewContent.text = self.descContentList[4]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn6Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[5]
        indiviDescViewContent.text = self.descContentList[5]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn7Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[6]
        indiviDescViewContent.text = self.descContentList[6]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func circleBtn8Tapped(_ sender: UIButton) {
        individualDescriptionView.isHidden = false
        indiviDescViewTitle.text = self.descTitleList[7]
        indiviDescViewContent.text = self.descContentList[7]
        for i in 0..<9 {
            descriptionViewList[i].isHidden = true
        }
    }
    
    @IBAction func buyLevelBtnTapped(_ sender: UIButton) {
        self.realLevel_fee = self.register_fee - self.myLevel_fee
        if (realLevel_fee > 0) {
            self.showSelectedLevelPopView()
        } else {
            ProgressHUD.showSuccessWithStatus("不能降级!")
        }
    }
    
    func setupPopViewUI() {
        self.userNamePopLbl.text = UserInstance.nickname!
        self.userLevelNamePopLbl.text = levelNames[oldSelectedLevel] + "会员"
        self.userLevelPopImg.image = levelImages[UserInstance.level_id!]
        self.levelPricePopLbl.text = String.init(self.realLevel_fee) + "￥"
    }
    
    private func showSelectedLevelPopView() {
        if (oldSelectedLevel == -1) {
            ProgressHUD.showSuccessWithStatus("select Level")
            return
        }
        self.setupPopViewUI()
        self.showLevelPopView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
    }
    
    private func hideSelectedLevelPopView() {
        self.showLevelPopView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(266)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func goPayMethodPopView(_ sender: UIButton) {
        self.hideSelectedLevelPopView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showCustomPayView()
        }
    }
    
    private func showCustomPayView() {
        self.customPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func hideCustomPayView() {
        self.customPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(315)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func selectPai(_ sender: UIButton) {
        showCheckMark(payType: 0)
    }
    
    @IBAction func selectWeiXin(_ sender: UIButton) {
        showCheckMark(payType: 1)
    }
    
    @IBAction func selectAliPay(_ sender: UIButton) {
        showCheckMark(payType: 2)
    }
    
    func showCheckMark(payType: Int) {
        checkMarkList[selectedPayType].isHidden = true
        checkMarkList[payType].isHidden = false
        selectedPayType = payType
    }
    
    @IBAction func goConfirmView(_ sender: Any) {
        if selectedPayType == 0 || selectedPayType == 2 {
            self.setPriceLabel()
            self.hideCustomPayView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showConfirmPayView()
            }
        } else if selectedPayType == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentAlert("暂未开放!")
            }
        }
    }
    
    func setPriceLabel() {
        let levelPrice = Double.init(self.realLevel_fee)
        let paiTotal = levelPrice / currencyRate
        if selectedPayType == 0 {
            self.priceLabel.text = String.init(format: "%.2f", paiTotal) + "π"
        } else {
            self.priceLabel.text = "￥" + String.init(format: "%.2f", levelPrice)
        }
        
        self.payTypeImage.image = self.payImages[selectedPayType]
    }
    
    private func showConfirmPayView() {
        self.confirmPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func hideConfirmPayView() {
        self.confirmPayView.snp.updateConstraints { (make) in
            make.bottom.equalTo(self.view).offset(315)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func goBackCustomView(_ sender: UIButton) {
        self.hideConfirmPayView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showCustomPayView()
        }
    }
    
    @IBAction func goTransactionView(_ sender: UIButton) {
        self.hideConfirmPayView()
        if selectedPayType == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentTransaction()
            }
        } else if selectedPayType == 2 {
            self.aliGetOrder()
        }
    }
    
    func aliGetOrder() {
        let parameters: Parameters = [
            "level": oldSelectedLevel + 1,
            "id": UserInstance.id!,
            "type": 3
        ]
        
        print(parameters)
        
        self.buyButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.purchaseLevel(params: parameters) { (json, success) in
            self.buyButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                if json["state"] as! Int == 200 {
                    print(">>>> json:\n", json)
                    let orderString = json["result"] as! String
                    print(orderString)
                    self.showDarkView(false)
                    self.AliplayFunc(orderString: orderString)
                } else if json["state"] as! Int == 201 {
                    let message = json["message"] as! String
                    ProgressHUD.showSuccessWithStatus(message)
                }
            } else {
                print("failure >>>> json:\n", json)
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
    }
    
    func AliplayFunc(orderString: String) {
        levelPayment = true
        let appScheme = "paishop"
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
                //self.createOrderProduct()
                break
            default:
                break
            }
            
        })
    }
    
    private func presentTransaction() {
        if UserInstance.paiAddress!.isEmpty {
            self.presentAlert("没有π账号", message: "你没有π账号. \n 请添加你的π账号详细信息.")
            return
        }
        self.presentTransactionPass()
    }
    
    func presentTransactionPass() {
        if UserInstance.guardPayment {
            self.transactionField.text = ""
            self.customTransactionView.snp.updateConstraints { (make) in
                make.centerY.equalTo(self.view.centerY)
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func closeCutomTransaction(_ sender: UIButton) {
        self.hideCustomTransactionView()
    }
    
    private func hideCustomTransactionView() {
        self.transactionField.resignFirstResponder()
        customTransactionView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    @IBAction func confirmTransaction(_ sender: UIButton) {
        let transactionPass = transactionField.text!
        if transactionPass.count < 4 {
            ProgressHUD.showErrorWithStatus("请输入有效的交易密码.")
            return
        }
        
        self.view.endEditing(true)
        let parameters: [String : Any] = [
            "payment_password" : transactionPass
        ]
        //sender.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentPasswordVerify(params: parameters) { (json, success) in
            if success {
                sender.isEnabled = true
                ProgressHUD.dismiss()
                print("Payment Password Verify...")
                print(json)
                self.hideCustomTransactionView()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.implementOrder()
                })
            } else {
                // try again...
                MyAPI.shared.paymentPasswordVerify(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.hideCustomTransactionView()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            self.implementOrder()
                        })
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
                })
                
                
            }
        }
        
    }
    
    // Buy Level .. h.g.n
    func implementOrder() {
        
        let parameters: [String : Any] = [
            "level": self.oldSelectedLevel + 1,
            "id": UserInstance.id!,
            "type": self.selectedPayType + 1
        ]
        
        print(parameters)
        
        self.buyButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.purchaseLevel(params: parameters) { (json, success) in
            self.buyButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                if json["state"] as! Int == 200 {
                    ProgressHUD.showSuccessWithStatus("升级成功")
                    self.profileUpdate()
                } else if json["state"] as! Int == 201 {
                    let message = json["message"] as! String
                    ProgressHUD.showSuccessWithStatus(message)
                }
            } else {
                ProgressHUD.showErrorWithStatus("失败.")
            }
        }
    }
    
    // h.g.n.
    private func profileUpdate() {
        AuthAPI.shared.profileGet(completion: { (json, success) in
            if success {
                UserInstance.userLoginSuccess(json["profile"])
                if UserInstance.loginName!.isEmpty {
                    //UserInstance.userLoginSuccess(json)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    ProgressHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                // try again...
                AuthAPI.shared.profileGet(completion: { (json, success1) in
                    if success1 {
                        UserInstance.userLoginSuccess(json["profile"])
                        if UserInstance.loginName!.isEmpty {
                            //UserInstance.userLoginSuccess(json)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            ProgressHUD.dismiss()
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            ProgressHUD.dismiss()
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                })
            }
        })
    }
    
    // MARK: - Request
    func requestGetBuyLevelInfo(index: NSInteger) {
        let parameters: Parameters = [
            "level": index
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.getBuyLevelInfo(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> json:\n", json)
                if json["setting"] != nil && (json["setting"] as! NSArray).count > 0 {
                    
                    let setting = (json["setting"] as! NSArray)[0] as! NSDictionary
                    
                    var strDescription = String()
                    var strSent1 = String()
                    var strSent2 = String()
                    var strSent3 = String()
                    var strSent4 = String()
                    var strSent5 = String()
                    var strSent6 = String()
                    var strSent7 = String()
                    var strSent8 = String()
                    
                    if setting["register_fee"] is NSNull || setting["register_fee"] == nil {
                        self.register_fee = 0
                    } else {
                        self.register_fee = setting["register_fee"] as! Int
                    }
                    
                    if setting["description"] is NSNull || setting["description"] == nil {
                        strDescription = ""
                    } else {
                        strDescription = setting["description"] as! String
                    }
                    
                    if setting["register_txt"] is NSNull || setting["register_txt"] == nil {
                        strSent1 = ""
                    } else {
                        strSent1 = setting["register_txt"] as! String
                    }
                    
                    if setting["invite_level_txt"] is NSNull || setting["invite_level_txt"] == nil {
                        strSent2 = ""
                    } else {
                        strSent2 = setting["invite_level_txt"] as! String
                    }
                    
                    if setting["invite_order_txt"] is NSNull || setting["invite_order_txt"] == nil {
                        strSent3 = ""
                    } else {
                        strSent3 = setting["invite_order_txt"] as! String
                    }
                    
                    if setting["invite_store_txt"] is NSNull || setting["invite_store_txt"] == nil {
                        strSent4 = ""
                    } else {
                        strSent4 = setting["invite_store_txt"] as! String
                    }
                    
                    if setting["five_txt"] is NSNull || setting["five_txt"] == nil {
                        strSent5 = ""
                    } else {
                        strSent5 = setting["five_txt"] as! String
                    }
                    
                    if setting["six_txt"] is NSNull || setting["six_txt"] == nil {
                        strSent6 = ""
                    } else {
                        strSent6 = setting["six_txt"] as! String
                    }
                    
                    if setting["seven_txt"] is NSNull || setting["seven_txt"] == nil {
                        strSent7 = ""
                    } else {
                        strSent7 = setting["seven_txt"] as! String
                    }
                    
                    if setting["eight_txt"] is NSNull || setting["eight_txt"] == nil {
                        strSent8 = ""
                    } else {
                        strSent8 = setting["eight_txt"] as! String
                    }
                    
                    // set array
                    self.descContentList.removeAll()
                    
                    self.descContentList.append(strSent1)
                    self.descContentList.append(strSent2)
                    self.descContentList.append(strSent3)
                    self.descContentList.append(strSent4)
                    self.descContentList.append(strSent5)
                    self.descContentList.append(strSent6)
                    self.descContentList.append(strSent7)
                    self.descContentList.append(strSent8)
                    
                    // set values
                    self.lblDescription.text = strDescription
                    self.lblSentence1.text = self.descContentList[0]
                    self.lblSentence2.text = self.descContentList[1]
                    self.lblSentence3.text = self.descContentList[2]
                    self.lblSentence4.text = self.descContentList[3]
                    self.lblSentence5.text = self.descContentList[4]
                    self.lblSentence6.text = self.descContentList[5]
                    self.lblSentence7.text = self.descContentList[6]
                    self.lblSentence8.text = self.descContentList[7]
                    
                }
            }
            
        }
        
    }
    
    // Getting my level fee
    func getMyLevelFee() {
        
        let parameters: Parameters = [
            "level": UserInstance.level_id ?? 0
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.getBuyLevelInfo(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> json:\n", json)
                if json["setting"] != nil && (json["setting"] as! NSArray).count > 0 {
                    
                    let setting = (json["setting"] as! NSArray)[0] as! NSDictionary
                    
                    if setting["register_fee"] is NSNull || setting["register_fee"] == nil {
                        self.myLevel_fee = 0
                    } else {
                        self.myLevel_fee = setting["register_fee"] as! Int
                        print(self.myLevel_fee)
                    }
                }
            }
        }
    }
    
    
}

extension MyRecmBuyLevelVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

