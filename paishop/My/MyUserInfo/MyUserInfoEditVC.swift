

import UIKit
import Photos
import MobileCoreServices
import Alamofire
import SwiftyJSON
import IGRPhotoTweaks
import SwiftyJSON
import DropDown


class MyUserInfoEditVC: UIViewController {
    
    var isFromPaiLogin = false
    var loginJson: JSON!
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: RoundImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var phoneField: UITextField! {
        didSet {
            phoneField.delegate = self
        }
    }
    @IBOutlet weak var paiAddressField: UITextView! {
        didSet {
            //addressTextView.placeholder = "请输入联系地址"
        }
    }
    @IBOutlet weak var discoveryTextView: UITextView! {
        didSet {
            //introductionTextView.placeholder = "详细介绍一下自己"
        }
    }
    @IBOutlet weak var disAddr: UITextField!
    @IBOutlet weak var paiAddressSecure: UITextField! {
        didSet {
            paiAddressSecure.delegate = self
        }
    }
    @IBOutlet weak var postButton: RoundRectButton!
    @IBOutlet weak var postButtonBg: GradientView!
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customPhoneView: UIView!
    @IBOutlet weak var customPhoneField: UITextField! {
        didSet {
            customPhoneField.delegate = self
        }
    }
    @IBOutlet weak var customVerifyCodeField: UITextField! {
        didSet {
            customVerifyCodeField.delegate = self
        }
    }
    @IBOutlet weak var verifyCodeButton: SecurityCodeButton!
    @IBOutlet weak var customConfirmButtonBg: GradientView!
    @IBOutlet weak var referInputTextField: UITextField!
    
    var avatarImage: UIImage!
    var genderDropDown: DropDown!
    var genderNames = ["   女   ", "   男   "]
    var selectedGenderIndex = 0 // 0->female, 1->male
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.setupTheme()
        self.setupUI()
        self.setupCustomView()
        self.setupGenderDropDown()
//        if (UserInstance.loginName?.isEmpty)! {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                self.showCustomPhoneView()
//            })
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "个人设置"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        postButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        postButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
        customConfirmButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        customConfirmButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func setupUI() {
        
        self.setupFields()
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        AuthAPI.shared.profileGet { (json, success) in
            if success {
                UserInstance.userLoginSuccess(json["profile"])
                if UserInstance.loginName!.isEmpty {
                    //UserInstance.userLoginSuccess(json)
                }
                self.setupFields()
                if (self.isFromPaiLogin) {
                    UserInstance.isLogin = false
                }
            } else {
                // try again...
                AuthAPI.shared.profileGet(completion: { (json, success1) in
                    if success1 {
                        UserInstance.userLoginSuccess(json["profile"])
                        if UserInstance.loginName!.isEmpty {
                            //UserInstance.userLoginSuccess(json)
                        }
                        self.setupFields()
                        if (self.isFromPaiLogin) {
                            UserInstance.isLogin = false
                        }
                    }
                })
            }
        }
        
        if (UserInstance.loginName?.isEmpty)! {
            phoneField.isEnabled = true
        }
        
    }
    
    private func setupCustomView() {
        self.view.addSubview(customPhoneView)
        customPhoneView.translatesAutoresizingMaskIntoConstraints = false
        customPhoneView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(270)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
    }
    
    private func setupGenderDropDown() {
        genderDropDown = DropDown()
        genderDropDown.anchorView = genderLabel
        genderDropDown.dataSource = genderNames
        genderDropDown.selectionAction =  { [unowned self] (index: Int, item: String) in
            //print("Selected item: \(item) at index: \(index)")
            self.selectedGenderIndex = index
            self.genderLabel.text = item
            self.genderDropDown.hide()
        }
    }
    
    private func setupFields() {
        self.nameField.text = Utils.getNickName()
        self.phoneField.text = UserInstance.loginName
        self.disAddr.text = UserInstance.dis_addr  //Changing into Discovery value
        self.discoveryTextView.text = UserInstance.discovery // Changing into ADD value
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.avatarImageView.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.paiAddressField.text = UserInstance.paiAddress
        //        if UserInstance.mobileKey! > 0 {
        //            self.paiAddressSecure.text = String(UserInstance.mobileKey!)
        //        } else {
        //            self.paiAddressSecure.text = ""
        //        }
        self.paiAddressSecure.text = UserInstance.mobileKey!
        
        if UserInstance.gender {
            genderLabel.text = genderNames[1]
        } else {
            genderLabel.text = genderNames[0]
        }
        
        if UserInstance.referee_id != 0 {
            self.referInputTextField.text = String(describing: UserInstance.referee_id!)
            self.referInputTextField.isEnabled = false
        }
        
    }
    
    
    @IBAction func selectAvatar(_ sender: UIButton) {
        let sheet = UIAlertController(title: nil, message: "修改头像", preferredStyle: .actionSheet)
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
    
    @IBAction func selectGender(_ sender: UIButton) {
        genderDropDown.show()
    }
    
    @IBAction func selectComplete(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        
        if !self.validateFields() {
            return
        }
        
        self.postAvatarImage()
    }
    
    @IBAction func selectCustomConfirm(_ sender: UIButton) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        if !validateCustomPhoneFields() {
            return
        }
        
        let phoneNumber = customPhoneField.text!
        let verification = customVerifyCodeField.text!
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "verify_code": verification
        ]
        
        sender.isEnabled = false
        ProgressHUD.showWithStatus()
        MyAPI.shared.phoneNumberUpdate(params: parameters) { (json, success) in
            if success {
                sender.isEnabled = true
                ProgressHUD.dismiss()
                self.phoneField.text = phoneNumber
                self.phoneField.isEnabled = false
                self.hideCustomPhoneView()
            } else {
                //try again...
                MyAPI.shared.phoneNumberUpdate(params: parameters, completion: { (json, success1) in
                    sender.isEnabled = true
                    ProgressHUD.dismiss()
                    if success1 {
                        self.phoneField.text = phoneNumber
                        self.phoneField.isEnabled = false
                        self.hideCustomPhoneView()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ProgressHUD.dismiss()
            self.hideCustomPhoneView()
            //disable phone field...
        }
    }
    
    @IBAction func selectCustomClose(_ sender: Any) {
        self.hideCustomPhoneView()
    }
    
    @IBAction func selectSendVerifyCode(_ sender: Any) {
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        self.view.endEditing(true)
        let phoneNumber = customPhoneField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return
        }
        
        verifyCodeButton.withFormat("验证码", phone: phoneNumber, time: 60)
        verifyCodeButton.startTime()
        
        let parameters: Parameters = [
            "phone_number": phoneNumber,
            "reset_password": 2
        ]
        verifyCodeButton.isEnabled = false
        ProgressHUD.showWithStatus()
        AuthAPI.shared.sendVerifyCode(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.verifyCodeButton.isEnabled = true
                //self.sendCodeButton.stopTime()
                ProgressHUD.showSuccessWithStatus("获取验证码成功.")
            } else {
                //try again...
                AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        ProgressHUD.showSuccessWithStatus("获取验证码成功.")
                    } else {
                        self.verifyCodeButton.stopTime()
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("获取验证码失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("获取验证码失败.")
                        }
                    }
                })
            }
        }
        
    }
    
    
    func postAvatarImage() {
        var avatarImageName = ""
        if self.avatarImage != nil {
            //let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
            let sufix = ".jpg"
            let objectKey = Constants.PROFILE_IMAGE + "/\(UserInstance.userId!)/" + "avatar" + sufix
            avatarImageName = Constants.ALIYUN_URL_PREFIX + objectKey
            AliyunUtil.shared.putImage(avatarImage, objectKey: objectKey) { (result) in
                if !result {
                    avatarImageName = UserInstance.avatar!
                }
                self.postUserProfile(avatarImageName: avatarImageName)
            }
        } else {
            avatarImageName = UserInstance.avatar!
            self.postUserProfile(avatarImageName: avatarImageName)
        }
    }
    
    func postUserProfile(avatarImageName: String) {
        DispatchQueue.main.async {
            let id = UserInstance.id
            let name = self.nameField.text!
            let phoneNumber = self.phoneField.text!
            let address = UserInstance.address
            let introduction = UserInstance.introduction
            let paiAddress = self.paiAddressField.text!
            let mobileKey = self.paiAddressSecure.text!
            let referee_id = Int(self.referInputTextField.text!)
            var gender = "1"
            if self.selectedGenderIndex == 0 {
                gender = "0"
            }
            
            var parameters: Parameters = [
                "id": id ?? 0,
                "name": name,
                "phone_number": phoneNumber,
                "gender": gender,
                "address": address ?? "",
                "referee_id": referee_id ?? 0
            ] //"introduction": introduction ?? "",
            if !(introduction == "") {
                parameters["introduction"] = introduction
            }
            if !paiAddress.isEmpty {
                parameters["pai_address"] = paiAddress
                parameters["pai_phone"] = mobileKey
            }
            if avatarImageName != "" {
                parameters["profile_image"] = avatarImageName
            }            
   
            self.postButton.isEnabled = false
            ProgressHUD.showWithStatus()
            AuthAPI.shared.profileSet(params: parameters, completion: { (json, success) in
                if success {
                    self.postButton.isEnabled = true
                    ProgressHUD.dismiss()
                    UserInstance.avatar = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
                    UserInstance.nickname = name
                    ProgressHUD.showSuccessWithStatus("成功.")
                    
                    if (self.isFromPaiLogin) {
                        self.processPaiLogin()
                    }
                    // refer input disable!
                    if self.referInputTextField.text! != "" {
                        self.referInputTextField.isEnabled = false
                    }
                    self.profileUpdate()
                } else {
                    //try again
                    AuthAPI.shared.profileSet(params: parameters, completion: { (json1, success1) in
                        self.postButton.isEnabled = true
                        ProgressHUD.dismiss()
                        if success1 {
                            UserInstance.avatar = json1["image"].stringValue
                            UserInstance.nickname = name
                            ProgressHUD.showSuccessWithStatus("成功.")
                            
                            if (self.isFromPaiLogin) {
                                self.processPaiLogin()
                            }
                            self.profileUpdate()
                        } else {
                            let errors = json1["errors"].dictionaryValue
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
            })
            
        }
    }
    
    private func processPaiLogin() {
        UserInstance.userLoginSuccess(loginJson)
        NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGIN_APPLICATION), object: nil)
        
    }
    
    private func profileUpdate() {
        AuthAPI.shared.profileGet(completion: { (json, success) in
            if success {
                UserInstance.userLoginSuccess(json["profile"])
                if UserInstance.loginName!.isEmpty {
                    //UserInstance.userLoginSuccess(json)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    ProgressHUD.dismiss()
                    if (self.isFromPaiLogin) {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
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
                            if (self.isFromPaiLogin) {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            ProgressHUD.dismiss()
                            if (self.isFromPaiLogin) {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                })
                
            }
        })
    }
    
    private func selectLibrary() {
        self.presentImagePickerController(
            maxNumberOfSelections: 1,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
        }, finish: {[weak self] (assets: [PHAsset]) -> Void in
            print("Finish: \(assets[0])")
            if let image = assets[0].getUIImage() {
                DispatchQueue.main.async {
                    self?.goToImageCropVC(image)
                }
            }
            }, completion: { () -> Void in
                print("completion")
        })
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
    
    private func validateFields() -> Bool {
        //let name = nameField.text!
        let phoneNumber = phoneField.text!
        //let address = addressTextView.text!
        let paiAddress = paiAddressField.text!
        let mobileKey = paiAddressSecure.text!
        /*if self.avatarImage == nil {
         ProgressHUD.showErrorWithStatus("请添加头像.")
         return false
         } else if name.isEmpty {
         ProgressHUD.showErrorWithStatus("请输入用户名.")
         return false
         } else*/
        if phoneNumber.count < 6 {
            ProgressHUD.showErrorWithStatus("您应该输入手机号码.")
            return false
        }
        
//        if address.count < 6 {
//            ProgressHUD.showErrorWithStatus("请输入有效的地址.")
//            return false
//        }
        
        if !paiAddress.isEmpty && mobileKey.isEmpty{
            ProgressHUD.showErrorWithStatus("您应该输入手机后四位与π用户名.")
            return false
        }
        if !paiAddress.isEmpty && !mobileKey.isEmpty && mobileKey.count < 4 {
            ProgressHUD.showErrorWithStatus("请输入有效手机后四位.")
            return false
        }
        return true
    }
    
    private func goToImageCropVC(_ image: UIImage) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ImageCropVC.nameOfClass) as! ImageCropVC
        vc.image = image
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func hideCustomPhoneView() {
        self.view.endEditing(true)
        customPhoneView.snp.updateConstraints { (make) in
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
    
    private func showCustomPhoneView() {
        self.view.endEditing(true)
        self.customPhoneField.text = UserInstance.loginName
        self.customVerifyCodeField.text = ""
        
        self.customPhoneView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.view.centerY)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
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
    
    private func validateCustomPhoneFields() -> Bool {
        let phoneNumber = customPhoneField.text!
        let verification = customVerifyCodeField.text!
        if phoneNumber.count < 11 {
            ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
            return false
        } else if verification.isEmpty {
            ProgressHUD.showErrorWithStatus("请输入验证码.")
            return false
        }
        return true
    }
    
}


extension MyUserInfoEditVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                self.goToImageCropVC(image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension MyUserInfoEditVC: IGRPhotoTweakViewControllerDelegate {
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.avatarImage = croppedImage
        self.avatarImageView.image = self.avatarImage
        controller.navigationController?.popViewController(animated: true)
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    
}


extension MyUserInfoEditVC: NavBarDelegate {
    func didSelectBack() {
        if isFromPaiLogin {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension MyUserInfoEditVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        if textField == paiAddressSecure {
            return newLength <= 4
        } else if textField == phoneField {
            return newLength <= 11
        } else if textField == customPhoneField {
            return newLength <= 11
        } else if textField == customVerifyCodeField {
            return newLength <= 6
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneField {
            //open phone verification custom view
            //self.showCustomPhoneView()
        }
    }
    
    
}


/*
 class MyUserInfoEditVC: UIViewController {
 //self.sendLoginSuccessNotification()
 var isFromPaiLogin = false
 var loginJson: JSON!
 
 @IBOutlet weak var navBar: NavBar!
 @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
 @IBOutlet weak var avatarImageView: RoundImageView! {
 didSet {
 avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
 avatarImageView.layer.borderWidth = 2
 }
 }
 @IBOutlet weak var nameField: UITextField!
 @IBOutlet weak var maleCheckBox: BEMCheckBox!
 @IBOutlet weak var femaleCheckBox: BEMCheckBox!
 @IBOutlet weak var phoneField: UITextField! {
 didSet {
 phoneField.delegate = self
 }
 }
 @IBOutlet weak var addressTextView: UITextView! {
 didSet {
 addressTextView.placeholder = "请输入联系地址"
 }
 }
 @IBOutlet weak var introductionTextView: UITextView! {
 didSet {
 introductionTextView.placeholder = "详细介绍一下自己"
 }
 }
 
 @IBOutlet weak var paiAddressField: UITextField!
 @IBOutlet weak var paiAddressSecure: UITextField! {
 didSet {
 paiAddressSecure.delegate = self
 }
 }
 
 
 @IBOutlet weak var darkView: UIView! {
 didSet {
 darkView.isHidden = true
 }
 }
 @IBOutlet var customPhoneView: UIView!
 @IBOutlet weak var customPhoneField: UITextField! {
 didSet {
 customPhoneField.delegate = self
 }
 }
 @IBOutlet weak var customVerifyCodeField: UITextField! {
 didSet {
 customVerifyCodeField.delegate = self
 }
 }
 @IBOutlet weak var verifyCodeButton: SecurityCodeButton!
 @IBOutlet weak var postButton: UIButton!
 
 var avatarImage: UIImage!
 var checkBoxGroup: BEMCheckBoxGroup!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 self.setupNavBar()
 self.setupUI()
 self.setupCustomView()
 if (UserInstance.loginName?.isEmpty)! {
 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
 self.showCustomPhoneView()
 })
 }
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 }
 
 private func setupNavBar() {
 navBar.lblTitle.text = "编辑资料"
 navBar.delegate = self
 if Utils.isIphoneX() {
 navBarHeightConstraint.constant = 88
 }
 }
 
 private func setupUI() {
 checkBoxGroup = BEMCheckBoxGroup(checkBoxes: [maleCheckBox, femaleCheckBox])
 checkBoxGroup.mustHaveSelection = true
 
 self.setupFields()
 
 if !NetworkUtil.isReachable() {
 ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
 return
 }
 AuthAPI.shared.profileGet { (json, success) in
 if success {
 UserInstance.userLoginSuccess(json["profile"])
 if UserInstance.loginName!.isEmpty {
 //UserInstance.userLoginSuccess(json)
 }
 self.setupFields()
 if (self.isFromPaiLogin) {
 UserInstance.isLogin = false
 }
 } else {
 // try again...
 AuthAPI.shared.profileGet(completion: { (json, success1) in
 if success1 {
 UserInstance.userLoginSuccess(json["profile"])
 if UserInstance.loginName!.isEmpty {
 //UserInstance.userLoginSuccess(json)
 }
 self.setupFields()
 if (self.isFromPaiLogin) {
 UserInstance.isLogin = false
 }
 }
 })
 }
 }
 
 if (UserInstance.loginName?.isEmpty)! {
 phoneField.isEnabled = true
 }
 
 }
 
 private func setupCustomView() {
 self.view.addSubview(customPhoneView)
 customPhoneView.translatesAutoresizingMaskIntoConstraints = false
 customPhoneView.snp.makeConstraints { (make) in
 make.centerX.equalTo(self.view.centerX)
 make.height.equalTo(270)
 make.width.equalTo(280)
 if Utils.isIpad() {
 make.centerY.equalTo(self.view.centerY).offset(2000)
 } else {
 make.centerY.equalTo(self.view.centerY).offset(1000)
 }
 }
 }
 
 private func setupFields() {
 self.nameField.text = Utils.getNickName()
 self.phoneField.text = UserInstance.loginName
 self.addressTextView.text = UserInstance.address
 self.introductionTextView.text = UserInstance.introduction
 self.avatarImageView.setImageWithURLStringNoCache(UserInstance.avatar, placeholderImage: ImageAsset.icon_avatar.image)
 self.paiAddressField.text = UserInstance.paiAddress
 if UserInstance.mobileKey! > 0 {
 self.paiAddressSecure.text = String(UserInstance.mobileKey!)
 } else {
 self.paiAddressSecure.text = ""
 }
 
 if UserInstance.gender {
 self.checkBoxGroup.selectedCheckBox = self.maleCheckBox
 } else {
 self.checkBoxGroup.selectedCheckBox = self.femaleCheckBox
 }
 }
 
 @IBAction func selectAvatar(_ sender: UIButton) {
 let sheet = UIAlertController(title: nil, message: "修改头像", preferredStyle: .actionSheet)
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
 
 func postAvatarImage() {
 var avatarImageName = ""
 if self.avatarImage != nil {
 //let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
 let sufix = ".jpg"
 let objectKey = Constants.PROFILE_IMAGE + "/\(UserInstance.userId!)/" + "avatar" + sufix
 avatarImageName = Constants.ALIYUN_URL_PREFIX + objectKey
 AliyunUtil.shared.putImage(avatarImage, objectKey: objectKey) { (result) in
 if !result {
 avatarImageName = UserInstance.avatar!
 }
 self.postUserProfile(avatarImageName: avatarImageName)
 }
 } else {
 avatarImageName = UserInstance.avatar!
 self.postUserProfile(avatarImageName: avatarImageName)
 }
 }
 
 func postUserProfile(avatarImageName: String) {
 DispatchQueue.main.async {
 let name = self.nameField.text!
 let phoneNumber = self.phoneField.text!
 let address = self.addressTextView.text!
 let introduction = self.introductionTextView.text!
 let paiAddress = self.paiAddressField.text!
 let mobileKey = self.paiAddressSecure.text!
 var gender = "1"
 if self.femaleCheckBox.on {
 gender = "0"
 }
 
 var parameters: Parameters = [
 "name": name,
 "phone_number": phoneNumber,
 "gender": gender,
 "address":address
 ]
 if !introduction.isEmpty {
 parameters["introduction"] = introduction
 }
 if !paiAddress.isEmpty {
 parameters["pai_address"] = paiAddress
 parameters["pai_phone"] = mobileKey
 }
 if avatarImageName != "" {
 parameters["profile_image"] = avatarImageName
 }
 
 self.postButton.isEnabled = false
 ProgressHUD.showWithStatus()
 AuthAPI.shared.profileSet(params: parameters, completion: { (json, success) in
 if success {
 self.postButton.isEnabled = true
 ProgressHUD.dismiss()
 UserInstance.avatar = json["image"].stringValue//API.IMAGE_URL + json["image"].stringValue
 UserInstance.nickname = name
 ProgressHUD.showSuccessWithStatus("成功.")
 
 if (self.isFromPaiLogin) {
 self.processPaiLogin()
 }
 self.profileUpdate()
 } else {
 //try again
 AuthAPI.shared.profileSet(params: parameters, completion: { (json1, success1) in
 self.postButton.isEnabled = true
 ProgressHUD.dismiss()
 if success1 {
 UserInstance.avatar = json1["image"].stringValue
 UserInstance.nickname = name
 ProgressHUD.showSuccessWithStatus("成功.")
 
 if (self.isFromPaiLogin) {
 self.processPaiLogin()
 }
 self.profileUpdate()
 } else {
 let errors = json1["errors"].dictionaryValue
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
 })
 
 }
 }
 
 @IBAction func selectComplete(_ sender: UIButton) {
 if !NetworkUtil.isReachable() {
 ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
 return
 }
 
 if !self.validateFields() {
 return
 }
 
 self.postAvatarImage()
 }
 
 private func processPaiLogin() {
 UserInstance.userLoginSuccess(loginJson)
 NotificationCenter.default.post(name: NSNotification.Name(Notifications.LOGIN_APPLICATION), object: nil)
 
 }
 
 
 private func profileUpdate() {
 AuthAPI.shared.profileGet(completion: { (json, success) in
 if success {
 UserInstance.userLoginSuccess(json["profile"])
 if UserInstance.loginName!.isEmpty {
 //UserInstance.userLoginSuccess(json)
 }
 DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
 ProgressHUD.dismiss()
 if (self.isFromPaiLogin) {
 self.dismiss(animated: true, completion: nil)
 } else {
 self.navigationController?.popViewController(animated: true)
 }
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
 if (self.isFromPaiLogin) {
 self.dismiss(animated: true, completion: nil)
 } else {
 self.navigationController?.popViewController(animated: true)
 }
 })
 } else {
 DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
 ProgressHUD.dismiss()
 if (self.isFromPaiLogin) {
 self.dismiss(animated: true, completion: nil)
 } else {
 self.navigationController?.popViewController(animated: true)
 }
 })
 }
 })
 
 }
 })
 }
 
 /*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
 
 
 private func selectLibrary() {
 self.presentImagePickerController(
 maxNumberOfSelections: 1,
 select: { (asset: PHAsset) -> Void in
 print("Selected: \(asset)")
 }, deselect: { (asset: PHAsset) -> Void in
 print("Deselected: \(asset)")
 }, cancel: { (assets: [PHAsset]) -> Void in
 print("Cancel: \(assets)")
 }, finish: {[weak self] (assets: [PHAsset]) -> Void in
 print("Finish: \(assets[0])")
 if let image = assets[0].getUIImage() {
 DispatchQueue.main.async {
 self?.goToImageCropVC(image)
 }
 }
 }, completion: { () -> Void in
 print("completion")
 })
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
 
 private func validateFields() -> Bool {
 //let name = nameField.text!
 let phoneNumber = phoneField.text!
 let address = addressTextView.text!
 let paiAddress = paiAddressField.text!
 let mobileKey = paiAddressSecure.text!
 /*if self.avatarImage == nil {
 ProgressHUD.showErrorWithStatus("请添加头像.")
 return false
 } else if name.isEmpty {
 ProgressHUD.showErrorWithStatus("请输入用户名.")
 return false
 } else*/
 if phoneNumber.count < 6 {
 ProgressHUD.showErrorWithStatus("您应该输入手机号码.")
 return false
 }
 
 if address.count < 6 {
 ProgressHUD.showErrorWithStatus("请输入有效的地址.")
 return false
 }
 
 if !paiAddress.isEmpty && mobileKey.isEmpty{
 ProgressHUD.showErrorWithStatus("您应该输入手机后四位与π用户名.")
 return false
 }
 if !paiAddress.isEmpty && !mobileKey.isEmpty && mobileKey.count < 4 {
 ProgressHUD.showErrorWithStatus("请输入有效手机后四位.")
 return false
 }
 return true
 }
 
 private func goToImageCropVC(_ image: UIImage) {
 let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ImageCropVC.nameOfClass) as! ImageCropVC
 vc.image = image
 vc.delegate = self
 self.navigationController?.pushViewController(vc, animated: true)
 }
 
 @IBAction func selectCustomClose(_ sender: Any) {
 self.hideCustomPhoneView()
 }
 
 @IBAction func selectSendVerifyCode(_ sender: Any) {
 if !NetworkUtil.isReachable() {
 ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
 return
 }
 self.view.endEditing(true)
 let phoneNumber = customPhoneField.text!
 if phoneNumber.count < 11 {
 ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
 return
 }
 
 verifyCodeButton.withFormat("验证码", phone: phoneNumber, time: 60)
 verifyCodeButton.startTime()
 
 let parameters: Parameters = [
 "phone_number": phoneNumber,
 "reset_password": 2
 ]
 verifyCodeButton.isEnabled = false
 ProgressHUD.showWithStatus()
 AuthAPI.shared.sendVerifyCode(params: parameters) { (json, success) in
 if success {
 ProgressHUD.dismiss()
 self.verifyCodeButton.isEnabled = true
 //self.sendCodeButton.stopTime()
 ProgressHUD.showSuccessWithStatus("获取验证码成功.")
 } else {
 //try again...
 AuthAPI.shared.sendVerifyCode(params: parameters, completion: { (json, success1) in
 ProgressHUD.dismiss()
 if success1 {
 ProgressHUD.showSuccessWithStatus("获取验证码成功.")
 } else {
 self.verifyCodeButton.stopTime()
 let errors = json["errors"].dictionaryValue
 if let error = errors.values.first {
 if let firstError =  error.arrayObject?.first as? String {
 ProgressHUD.showErrorWithStatus(firstError)
 } else {
 ProgressHUD.showErrorWithStatus("获取验证码失败.")
 }
 } else {
 ProgressHUD.showErrorWithStatus("获取验证码失败.")
 }
 }
 })
 }
 }
 
 }
 
 @IBAction func selectCustomConfirm(_ sender: UIButton) {
 if !NetworkUtil.isReachable() {
 ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
 return
 }
 self.view.endEditing(true)
 if !validateCustomPhoneFields() {
 return
 }
 
 let phoneNumber = customPhoneField.text!
 let verification = customVerifyCodeField.text!
 let parameters: Parameters = [
 "phone_number": phoneNumber,
 "verify_code": verification
 ]
 sender.isEnabled = false
 ProgressHUD.showWithStatus()
 MyAPI.shared.phoneNumberUpdate(params: parameters) { (json, success) in
 if success {
 sender.isEnabled = true
 ProgressHUD.dismiss()
 self.phoneField.text = phoneNumber
 self.phoneField.isEnabled = false
 self.hideCustomPhoneView()
 } else {
 //try again...
 MyAPI.shared.phoneNumberUpdate(params: parameters, completion: { (json, success1) in
 sender.isEnabled = true
 ProgressHUD.dismiss()
 if success1 {
 self.phoneField.text = phoneNumber
 self.phoneField.isEnabled = false
 self.hideCustomPhoneView()
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
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
 ProgressHUD.dismiss()
 self.hideCustomPhoneView()
 //disable phone field...
 }
 
 }
 
 private func hideCustomPhoneView() {
 self.view.endEditing(true)
 customPhoneView.snp.updateConstraints { (make) in
 if Utils.isIpad() {
 make.centerY.equalTo(self.view.centerY).offset(2000)
 } else {
 make.centerY.equalTo(self.view.centerY).offset(1000)
 }
 }
 UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
 self.view.layoutIfNeeded()
 })
 self.showDarkView(false)
 }
 
 private func showCustomPhoneView() {
 self.view.endEditing(true)
 self.customPhoneField.text = UserInstance.loginName
 self.customVerifyCodeField.text = ""
 
 self.customPhoneView.snp.updateConstraints { (make) in
 make.centerY.equalTo(self.view.centerY)
 }
 UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
 self.view.layoutIfNeeded()
 })
 self.showDarkView(true)
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
 
 private func validateCustomPhoneFields() -> Bool {
 let phoneNumber = customPhoneField.text!
 let verification = customVerifyCodeField.text!
 if phoneNumber.count < 11 {
 ProgressHUD.showErrorWithStatus("请输入有效的手机号码.")
 return false
 } else if verification.isEmpty {
 ProgressHUD.showErrorWithStatus("请输入验证码.")
 return false
 }
 return true
 }
 
 }
 
 
 
 extension MyUserInfoEditVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
 guard let mediaType = info[UIImagePickerControllerMediaType] as? NSString else { return }
 if mediaType.isEqual(to: kUTTypeImage as String) {
 guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
 if picker.sourceType == .camera {
 self.goToImageCropVC(image)
 }
 }
 picker.dismiss(animated: true, completion: nil)
 }
 
 func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
 picker.dismiss(animated: true, completion: nil)
 }
 }
 
 
 extension MyUserInfoEditVC: IGRPhotoTweakViewControllerDelegate {
 func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
 self.avatarImage = croppedImage
 self.avatarImageView.image = self.avatarImage
 controller.navigationController?.popViewController(animated: true)
 }
 
 func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
 controller.navigationController?.popViewController(animated: true)
 }
 
 
 }
 
 
 extension MyUserInfoEditVC: NavBarDelegate {
 func didSelectBack() {
 if isFromPaiLogin {
 self.dismiss(animated: true, completion: nil)
 } else {
 self.navigationController?.popViewController(animated: true)
 }
 }
 }
 
 
 extension MyUserInfoEditVC: UITextFieldDelegate {
 func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
 guard let text = textField.text else { return true }
 let newLength = text.count + string.count - range.length
 
 if textField == paiAddressSecure {
 return newLength <= 4
 } else if textField == phoneField {
 return newLength <= 11
 } else if textField == customPhoneField {
 return newLength <= 11
 } else if textField == customVerifyCodeField {
 return newLength <= 6
 }
 return true
 }
 
 func textFieldDidBeginEditing(_ textField: UITextField) {
 if textField == phoneField {
 //open phone verification custom view
 self.showCustomPhoneView()
 }
 }
 
 
 }
 */




























