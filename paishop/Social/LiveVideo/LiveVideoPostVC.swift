
import UIKit
import MobileCoreServices
import Photos

class LiveVideoPostVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextView! {
        didSet {
            titleLabel.placeholder = "请输入直播标题"
        }
    }
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoImageFrame: UIStackView!
    @IBOutlet weak var postButton: UIButton!
        
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var postButtonBg: GradientView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let videoImageFrameTap = UITapGestureRecognizer(target: self, action: #selector(selectVideoImageFrame))
        videoImageFrame.isUserInteractionEnabled = true
        videoImageFrame.addGestureRecognizer(videoImageFrameTap)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(selectView))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(viewTap)
        
        self.setupTheme()
    }

    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        cameraImageView.setTintColor(MainColors.themeEndColors[selectedTheme])
        postButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        postButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    @IBAction func selectClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPost(_ sender: UIButton) {
        self.view.endEditing(true)
        if !self.validatePostData() {
            return
        }
        
        // handle post...
        postButton.isEnabled = false
        ProgressHUD.showWithStatus()
        self.postVideoImage()
        
    }
    
    @objc func selectView() {
        self.view.endEditing(true)
    }
    
    @objc func selectVideoImageFrame() {
        self.view.endEditing(true)
        Utils.applyTouchEffect(videoImageFrame)
        
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
                        self?.videoImageView.image = image
                    }
                }
            }
            
        }, completion: { () -> Void in
                print("completion")
        })
    }
    
    private func validatePostData() -> Bool {
        let pushText = titleLabel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if pushText.count < 2 {
            ProgressHUD.showErrorWithStatus("请输入有效的直播标题.")
            return false
        }
        if videoImageView.image == nil {
            ProgressHUD.showWarningWithStatus("请上传直播图像.")
            return false
        }
        
        return true
    }
    
    private func postVideoImage() {
        let videoImage = videoImageView.image!
        let width = Int(videoImage.size.width)
        let height = Int(videoImage.size.height)
        let sufix = "_\(width)x\(height).jpg"
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
        let objectKey = Constants.LIVE_VIDEO + "/\(UserInstance.storeId!)/" +  "\(timestamp)" + sufix
        let videoImageName = Constants.ALIYUN_URL_PREFIX + objectKey
        AliyunUtil.shared.putImage(videoImage, objectKey: objectKey) { (result) in
            DispatchQueue.main.async {
                if result {
                    self.getPushUrl(videoImageName)
                } else {
                    ProgressHUD.dismiss()
                    self.postButton.isEnabled = true
                    ProgressHUD.showErrorWithStatus("直播图像上传错误")
                }
            }
        }
        
    }
    
    private func getPushUrl(_ videoImageUrl: String) {
        let pushText = titleLabel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let parameters: [String: Any] = [
            "uuid" : UserInstance.userId!,
            "type" : false,//true,
            "title" : pushText,
            "image" : videoImageUrl,
            "store" : UserInstance.storeId!
        ]
        SocialAPI.shared.pushUrl(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                self.postButton.isEnabled = true
                print("Push Url.........")
                print(json)
                let pushUrl = json["push_url"].stringValue
                let liveVideo = LiveVideoModel.init(json["video"])
                
                if liveVideo.forbidden! {
                    self.presentOKAlert("您的直播已被管理员禁止!\n请联系管理员.") {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPushVC.nameOfClass) as! LiveVideoPushVC
                    vc.pushUrl = pushUrl
                    vc.videoModel = liveVideo
                    vc.videoImage = self.videoImageView.image
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                // try again...
                SocialAPI.shared.pushUrl(params: parameters, completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    self.postButton.isEnabled = true
                    if success1 {
                        let pushUrl = json1["push_url"].stringValue
                        let liveVideo = LiveVideoModel.init(json1["video"])                        
                        
                        if liveVideo.forbidden! {
                            self.presentOKAlert("您的直播已被管理员禁止!\n请联系管理员.") {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: LiveVideoPushVC.nameOfClass) as! LiveVideoPushVC
                            vc.pushUrl = pushUrl
                            vc.videoModel = liveVideo
                            vc.videoImage = self.videoImageView.image
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        print("Push Url.....")
                        print(json1)
                        ProgressHUD.showErrorWithStatus("无法获得实时视频推送网址!")
                    }
                })
            }
        }
    }
    

}



extension LiveVideoPostVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                self.videoImageView.image = image
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}















