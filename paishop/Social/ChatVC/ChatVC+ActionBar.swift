

import UIKit
import Photos
import MobileCoreServices

extension ChatVC {
    
    func setupActionBarButtonInteraction() {
        let shareButton = self.chatActionBarView.shareButton
        let sendButton = self.chatActionBarView.sendButton
        let sendImageView = self.chatActionBarView.sendImageView
        let textView = self.chatActionBarView.inputTextView
        
        shareButton?.rx.tap.subscribe(onNext: { () in
            self.presentImagePicker()
        }).disposed(by: self.disposeBag)
        
        sendButton?.rx.tap.subscribe(onNext: { () in
            self.chatSendText()
        }).disposed(by: self.disposeBag)
        
        let tap = UITapGestureRecognizer()
        textView?.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { (tapGesture) in
            textView?.inputView = nil
            textView?.becomeFirstResponder()
            textView?.reloadInputViews()
        }).disposed(by: self.disposeBag)
        
        textView?.rx.text.asObservable().subscribe(onNext: { (string) in
            guard let string = string else { return }
            if string.count >= 1 {
                //sendButton?.imageView?.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9))
                sendImageView?.setTintColor(UIColor.init(colorWithHexValue: 0x9797979, alpha: 1.0))
            } else {
                //sendButton?.imageView?.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9, alpha: 0.3))
                sendImageView?.setTintColor(UIColor.init(colorWithHexValue: 0x9797979, alpha: 0.15))
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    func controlExpandableInputView(showExpandable: Bool) {
        let textView = self.chatActionBarView.inputTextView
        let currentTextHeight = self.chatActionBarView.inputTextViewCurrentHeight
        UIView.animate(withDuration: 0.3) {
            let textHeight = showExpandable ? currentTextHeight : kChatActionBarOriginalHeight
            self.chatActionBarView.snp.updateConstraints({ (make) in
                make.height.equalTo(textHeight)
            })
            self.view.layoutIfNeeded()
            self.tableView.scrollBottomToLastRow()
            textView?.contentOffset = CGPoint.zero
        }
    }
    
    func presentImagePicker() { //发送图像
        let sheet = UIAlertController(title: nil, message: "添加照片", preferredStyle: .actionSheet)
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
                    //send image chat...
                    self?.chatSendImage(image)
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
    
}


extension ChatVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString else { return }
        if mediaType.isEqual(to: kUTTypeImage as String) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            if picker.sourceType == .camera {
                //send image chat...
                self.chatSendImage(image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}








