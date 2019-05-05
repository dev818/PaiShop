
import UIKit
import MobileCoreServices
import Photos

class QrCodeBuyModalVC: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var firstStepLabel: UILabel!
    @IBOutlet weak var secondStepLabel: UILabel!
    @IBOutlet weak var thirdStepLabel: UILabel!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var payImageView: UIImageView!
    @IBOutlet weak var payView: UIStackView!
    @IBOutlet weak var payConfrimButton: UIButton!
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var payConfirmButtonBg: GradientView!
    
    
    var product: ProductDetailModel!
    var paymentType: Int!
    var currencyRate: Double!
    var count: Int!
    
    var items: String = ""
    var userName: String = ""
    var address: String = ""
    var phoneNumber: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupTheme()
        
        let payViewTap = UITapGestureRecognizer(target: self, action: #selector(selectPayView))
        payView.isUserInteractionEnabled = true
        payView.addGestureRecognizer(payViewTap)
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        cameraImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        payConfirmButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        payConfirmButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    private func setupUI() {
        let totalPrice = Double(product.price!)! * Double(count)
        var totalPriceString = ""
        if paymentType == 1 {
            totalPriceString = String.init(format: "%.2f", totalPrice / currencyRate) + "π"
        } else {
            totalPriceString = "¥" + String(totalPrice)
        }
        priceLabel.text = totalPriceString
        
        let stepAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.color(fromHexString: "#FF3E03"),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        ]
        let contentAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
        ]
        let priceAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.color(fromHexString: "#FF3E03"),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
        ]
        
        var stepString = NSMutableAttributedString(string: "第一步: ", attributes: stepAttributes)
        var contentString1 = NSMutableAttributedString(string: "打开Discovery账号, 扫描以下商家派付二维码支付(请务必输入正确的派数: ", attributes: contentAttributes)
        let priceString = NSMutableAttributedString(string: totalPriceString, attributes: priceAttributes)
        let contentString2 = NSMutableAttributedString(string: "):", attributes: contentAttributes)
        let firstStepString = NSMutableAttributedString()
        firstStepString.append(stepString)
        firstStepString.append(contentString1)
        firstStepString.append(priceString)
        firstStepString.append(contentString2)
        firstStepLabel.attributedText = firstStepString
        
        stepString = NSMutableAttributedString(string: "第二步: ", attributes: stepAttributes)
        contentString1 = NSMutableAttributedString(string: "请上传交易截图:", attributes: contentAttributes)
        let secondStepString = NSMutableAttributedString()
        secondStepString.append(stepString)
        secondStepString.append(contentString1)
        secondStepLabel.attributedText = secondStepString
        
        stepString = NSMutableAttributedString(string: "第三步: ", attributes: stepAttributes)
        contentString1 = NSMutableAttributedString(string: "请点我已派付:", attributes: contentAttributes)
        let thirdStepString = NSMutableAttributedString()
        thirdStepString.append(stepString)
        thirdStepString.append(contentString1)
        thirdStepLabel.attributedText = thirdStepString
        
        let resizedUrl = Utils.getResizedImageUrlString(product.qrimage!, width: "800")
        qrcodeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.default_image.image)
    }

    
    
    @IBAction func selectClose(_ sender: UIButton) {
        self.dismiss(animated: true) { }
    }
    
    @IBAction func selectPayConfirm(_ sender: UIButton) {
        if payImageView.image == nil {
            ProgressHUD.showErrorWithStatus("请上传转账截图")
            return
        }
        
        ProgressHUD.showWithStatus()
        payConfrimButton.isEnabled = false
        self.postPayImage()
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
        let objectKey = Constants.QR_PAYMENT + "/\(UserInstance.storeId!)" + "/\(product.id!)/" + "\(timestamp)" + sufix
        let payImageName = Constants.ALIYUN_URL_PREFIX + objectKey
        AliyunUtil.shared.putImage(payImage, objectKey: objectKey) { (result) in
            DispatchQueue.main.async {
                if result {
                    self.processOrder(payImageName)
                } else {
                    ProgressHUD.dismiss()
                    self.payConfrimButton.isEnabled = true
                    ProgressHUD.showErrorWithStatus("转账截图上传错误")
                }
            }
        }
    }
    
    private func processOrder(_ payImageUrl: String) {
        let parameters: [String : Any] = [
            "items" : self.items,
            "user_name" : self.userName,
            "address" : self.address,
            "phone_number" : self.phoneNumber,
            "currency" : 0, // qrcode pay type
            "image" : payImageUrl,
        ]
        
        MyAPI.shared.orderCreate(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            self.payConfrimButton.isEnabled = true
            print("Order Create...")
            print(json)
            if success {
                ProgressHUD.showSuccessWithStatus("成功购买!")
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.QR_PAY_SUCCESS), object: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                let errors = json["errors"].dictionaryValue
                if let error = errors.values.first {
                    if let firstError =  error.arrayObject?.first as? String {
                        ProgressHUD.showErrorWithStatus(firstError)
                    } else {
                        ProgressHUD.showErrorWithStatus("失败购买.")
                    }
                } else {
                    ProgressHUD.showErrorWithStatus("失败购买.")
                }
            }
        }
        
    }

}



extension QrCodeBuyModalVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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











