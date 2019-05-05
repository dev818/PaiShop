
import UIKit
import Photos
import MobileCoreServices

class MyWalletRechargeVC: UIViewController {
    
    var serverPaiAddress: String = ""
    var serverPaiPhone: String = ""
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rechargeBackView: UIView!
    @IBOutlet weak var serverPaiAddressLabel: UILabel!
    @IBOutlet weak var serverMobileKeyLabel: UILabel!
    @IBOutlet weak var amountField: UITextField! {
        didSet {
            //amountField.text = ""
        }
    }
    @IBOutlet weak var rechargePaiButton: UIButton! {
        didSet {
            rechargePaiButton.tag = 201
        }
    }
    @IBOutlet weak var rechargeCNYButton: UIButton! {
        didSet {
            rechargeCNYButton.tag = 202
        }
    }
    @IBOutlet var rechargeAmountButtons: [UIButton]! // tag 101 - 106
    @IBOutlet weak var confirmRechargeButton: RoundRectButton!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customTransactionView: UIView!
    @IBOutlet weak var transactionField: UITextField!
    @IBOutlet weak var payImageView: UIImageView!
    @IBOutlet weak var payView: UIStackView!
    
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var confirmRechargeButtonBg: GradientView!
    @IBOutlet weak var confirmTransactionButtonBg: GradientView!
    @IBOutlet weak var rechargeTypeLabel: UILabel!
    @IBOutlet weak var rechargeAmountLabel: UILabel!
    @IBOutlet weak var rechargeQrcodeLabel: UILabel!
    
    
    
    var isSelectedPai = true
    var selectedAmountIndex = 2 // index - 1, 2, 3, 4, 5, 6
    var selectedTheme = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupCustomView()
        self.setupTheme()
        
        self.serverPaiAddressLabel.text = serverPaiAddress
        self.serverMobileKeyLabel.text = serverPaiPhone
        
        let payViewTap = UITapGestureRecognizer(target: self, action: #selector(selectPayView))
        payView.isUserInteractionEnabled = true
        payView.addGestureRecognizer(payViewTap)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "转派"
        navBar.setDefaultNav()
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        copyButton.imageView?.setTintColor(MainColors.themeEndColors[selectedTheme])
//        rechargeTypeLabel.textColor = MainColors.themeEndColors[selectedTheme]
//        rechargeAmountLabel.textColor = MainColors.themeEndColors[selectedTheme]
//        rechargeQrcodeLabel.textColor = MainColors.themeEndColors[selectedTheme]
        rechargePaiButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
//        confirmRechargeButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
//        confirmRechargeButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        confirmTransactionButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        confirmTransactionButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        for rechargeAmountButton in rechargeAmountButtons {
            if rechargeAmountButton.tag == 102 {
                rechargeAmountButton.backgroundColor = MainColors.themeEndColors[selectedTheme]
            }
        }
        //cameraImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
    }
    
    private func setupCustomView() {
        
        rechargeBackView.dropShadow()
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
    }
    
    @IBAction func selectCopy(_ sender: UIButton) {
        let board = UIPasteboard.general
        board.string = self.serverPaiAddress
        ProgressHUD.showSuccessWithStatus("成功复制π账号")
    }
    
    

    @IBAction func selectPai(_ sender: UIButton) {
        self.isSelectedPai = true
        self.amountField.text = "100"
        
        rechargeCNYButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
        rechargeCNYButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        
        rechargePaiButton.setTitleColor(UIColor.white, for: .normal)
        rechargePaiButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        for rechargeAmountButton in rechargeAmountButtons {
            switch rechargeAmountButton.tag {
            case 101:
                rechargeAmountButton.setTitle("50π", for: .normal)
            case 102:
                rechargeAmountButton.setTitle("100π", for: .normal)
            case 103:
                rechargeAmountButton.setTitle("150π", for: .normal)
            case 104:
                rechargeAmountButton.setTitle("200π", for: .normal)
            case 105:
                rechargeAmountButton.setTitle("250π", for: .normal)
            case 106:
                rechargeAmountButton.setTitle("300π", for: .normal)
            default:
                break
            }
        }
        
        self.resetAmountButtons()
    }
    
    @IBAction func selectCNY(_ sender: UIButton) {
        self.isSelectedPai = false
        self.amountField.text = "200"
        
        rechargePaiButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
        rechargePaiButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        
        rechargeCNYButton.setTitleColor(UIColor.white, for: .normal)
        rechargeCNYButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        for rechargeAmountButton in rechargeAmountButtons {
            switch rechargeAmountButton.tag {
            case 101:
                rechargeAmountButton.setTitle("100元", for: .normal)
            case 102:
                rechargeAmountButton.setTitle("200元", for: .normal)
            case 103:
                rechargeAmountButton.setTitle("300元", for: .normal)
            case 104:
                rechargeAmountButton.setTitle("400元", for: .normal)
            case 105:
                rechargeAmountButton.setTitle("500元", for: .normal)
            case 106:
                rechargeAmountButton.setTitle("600元", for: .normal)
            default:
                break
            }
        }
        self.resetAmountButtons()
    }
    
    @IBAction func selectAmount(_ sender: UIButton) {
        for rechargeAmountButton in rechargeAmountButtons {
            rechargeAmountButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
            rechargeAmountButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
        }
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
        
        switch sender.tag {
        case 101:
            selectedAmountIndex = 1
            if isSelectedPai {
                amountField.text = "50"
            } else {
                amountField.text = "100"
            }
        case 102:
            selectedAmountIndex = 2
            if isSelectedPai {
                amountField.text = "100"
            } else {
                amountField.text = "200"
            }
        case 103:
            selectedAmountIndex = 3
            if isSelectedPai {
                amountField.text = "150"
            } else {
                amountField.text = "300"
            }
        case 104:
            selectedAmountIndex = 4
            if isSelectedPai {
                amountField.text = "200"
            } else {
                amountField.text = "400"
            }
        case 105:
            selectedAmountIndex = 5
            if isSelectedPai {
                amountField.text = "250"
            } else {
                amountField.text = "500"
            }
        case 106:
            selectedAmountIndex = 6
            if isSelectedPai {
                amountField.text = "300"
            } else {
                amountField.text = "600"
            }
        default:
            break
        }
    }
    
    @IBAction func confirmRecharge(_ sender: UIButton) {
        let amount = amountField.text!
        if amount.isEmpty {
            ProgressHUD.showWarningWithStatus("请输入充值余额.")
            return
        }
        if amount == "0" {
            ProgressHUD.showWarningWithStatus("请输入充值余额.")
            return
        }
        
        if UserInstance.guardPayment {
            self.transactionField.text = ""
            self.customTransactionView.snp.updateConstraints { (make) in
                make.centerY.equalTo(self.view.centerY)
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            self.showDarkView(true)
        } else {
            if UserDefaultsUtil.shared.getIsCheckPaymentPassword() {
                self.implementRecharge()
            } else {
                UserDefaultsUtil.shared.setIsCheckPaymentPassword(true)
                self.presentAlert("交易密码设置", message: "你没有设置交易密码.\n 我们建议您设置交易密码.\n 你想立即设置交易密码吗？", completionOK: {
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: TransactionPassInputVC.nameOfClass)
                    self.navigationController?.pushViewController(vc, animated: true)
                }, completionCancel: {
                    //implement recharge...
                    self.implementRecharge()
                })
            }
        }
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
        sender.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentPasswordVerify(params: parameters) { (json, success) in
            if success {
                sender.isEnabled = true
                ProgressHUD.dismiss()
                print("Payment Password Verify...")
                print(json)
                self.hideCustomTransactionView()
                //implement recharge...
                self.implementRecharge()
            } else {
                // try again...
                MyAPI.shared.paymentPasswordVerify(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.hideCustomTransactionView()
                        self.implementRecharge()
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
    
    @IBAction func closeCustomTransaction(_ sender: UIButton) {
        self.hideCustomTransactionView()
    }
    
    
    private func implementRecharge() {
        let amount = Double(amountField.text!)
        if amount == nil {
            ProgressHUD.showWarningWithStatus("请输入有效的充值余额.")
            return
        }
        
        if payImageView.image == nil {
            ProgressHUD.showErrorWithStatus("请上传转账截图")
            return
        }
        
        ProgressHUD.showWithStatus()
        confirmRechargeButton.isEnabled = false
        self.postPayImage()
        
        
        /*let currency = isSelectedPai ? 1 : 2 // 1 - pai, 2 - CNY
        let type = true // recharge
        
        let parameters: [String : Any] = [
            "amount" : amount!,
            "currency" : currency,
            "type" : type
        ]
        confirmRechargeButton.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.paymentCreate(params: parameters) { (json, success) in
            self.confirmRechargeButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                print("Payment Create...")
                print(json)
                ProgressHUD.showSuccessWithStatus("请稍后正在确认...\n关注提示信息!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
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
        }*/
    }
    
    
    private func resetAmountButtons() {
        selectedAmountIndex = 2
        for rechargeAmountButton in rechargeAmountButtons {
            if rechargeAmountButton.tag == 102 {
                rechargeAmountButton.setTitleColor(UIColor.white, for: .normal)
                rechargeAmountButton.ts_setBackgroundColor(MainColors.themeEndColors[selectedTheme], forState: .normal)
            } else {
                rechargeAmountButton.setTitleColor(UIColor(colorWithHexValue: 0x6f6f6f), for: .normal)
                rechargeAmountButton.ts_setBackgroundColor(UIColor(colorWithHexValue: 0xe5e5e5), forState: .normal)
            }
        }
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
    
    
    @objc func selectPayView() {
        Utils.applyTouchEffect(payView)
        
        let sheet = UIAlertController(title: nil, message: "直播图像", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectCamera()
        })
        let photoAction = UIAlertAction(title: "相册", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectLibrary()
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func selectCamera() {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
                if !granted {
                    self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
                } else {
                    let imagePicker =  UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
        } else if authStatus == .restricted || authStatus == .denied {
            self.presentAlert("无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限" )
        } else if authStatus == .authorized {
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func selectLibrary() {
        let maxNumber = 1
        self.presentImagePickerController(
            maxNumberOfSelections: maxNumber,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
        }, finish: {[weak self] (assets: [PHAsset]) -> Void in
            print("Finish: \(assets[0])")
            for asset in assets {
                if let image = asset.getUIImage() {
                    DispatchQueue.main.async {
                        self?.payImageView.image = image
                    }
                }
            }
            
            }, completion: { () -> Void in
                print("completion")
        })
    }
    
    private func postPayImage() {
        let payImage = payImageView.image!
        let width = Int(payImage.size.width)
        let height = Int(payImage.size.height)
        let sufix = "_\(width)x\(height).jpg"
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
        let objectKey = Constants.PROFILE_IMAGE + "/\(UserInstance.userId!)/payment/" + "\(timestamp)" + sufix
        let payImageName = Constants.ALIYUN_URL_PREFIX + objectKey
        AliyunUtil.shared.putImage(payImage, objectKey: objectKey) { (result) in
            DispatchQueue.main.async {
                if result {
                    self.processRecharge(payImageName)
                } else {
                    ProgressHUD.dismiss()
                    self.confirmRechargeButton.isEnabled = true
                    ProgressHUD.showErrorWithStatus("转账截图上传错误")
                }
            }
        }
    }
    
    private func processRecharge(_ payImageUrl: String) {
        
        let amount = Double(amountField.text!)
        let currency = isSelectedPai ? 1 : 2 // 1 - pai, 2 - CNY
        let type = true // recharge
        
        let parameters: [String : Any] = [
            "amount" : amount!,
            "currency" : currency,
            "type" : type,
            "image" : payImageUrl,
        ]
        MyAPI.shared.paymentCreate(params: parameters) { (json, success) in
            self.confirmRechargeButton.isEnabled = true
            ProgressHUD.dismiss()
            if success {
                print("Payment Create...")
                print(json)
                ProgressHUD.showSuccessWithStatus("请稍后正在确认...\n关注提示信息!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
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
        }
    }
    
    
    
}


extension MyWalletRechargeVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyWalletRechargeVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                self.payImageView.image = image
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}












