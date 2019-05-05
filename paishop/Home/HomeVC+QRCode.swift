

import Foundation
import AVFoundation
import QRCodeReader
import swiftScan

extension HomeVC {
    
    func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            let alert: UIAlertController
            
            switch error.code {
            case -11852:
                alert = UIAlertController(title: "Error", message: "此应用程序未被授权使用后视摄像头。", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { (_) in
                    DispatchQueue.main.async {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            //UIApplication.shared.openURL(settingsURL)
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            default:
                alert = UIAlertController(title: "错误", message: "当前设备不支持读卡器", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确认", style: .cancel, handler: nil))
            }
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(alert, animated: true, completion: nil)
            
            return false
        }
    }
    
    
    func openSwiftScanVC() {
        SwiftScanPermissions.authorizeCameraWith { (granted) in
            if granted {
                //设置扫码区域参数
                var style = LBXScanViewStyle()
                style.centerUpOffset = 60;
                style.xScanRetangleOffset = 30;
                if UIScreen.main.bounds.size.height <= 480
                {
                    //3.5inch 显示的扫码缩小
                    style.centerUpOffset = 40;
                    style.xScanRetangleOffset = 20;
                }
                style.color_NotRecoginitonArea = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)
                style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner;
                style.photoframeLineW = 2.0;
                style.photoframeAngleW = 16;
                style.photoframeAngleH = 16;
                style.isNeedShowRetangle = false;
                style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid;
                style.animationImage = UIImage(named: "qrcode_scan_full_net.png")
                
                let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: SwiftScanVC.nameOfClass) as! SwiftScanVC
                vc.scanStyle = style
                vc.scanResultDelegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                SwiftScanPermissions.jumpToSystemPrivacySetting()
            }
        }
    }
    
    
}

extension HomeVC: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true, completion: {
                let alert = UIAlertController(
                    title: "QRCodeReader",
                    message: String (format:"%@ (of type %@)", result.value, result.metadataType),
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: (self.view.bounds.midX), y: (self.view.bounds.midY), width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                //self?.present(alert, animated: true, completion: nil)
                
                if let url = URL.init(string: result.value) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}



extension HomeVC: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        print("Scan Result...", scanResult)
        
        guard let strScanned = scanResult.strScanned else { return }
        if let url = URL.init(string: strScanned) {
            if let range = strScanned.range(of: "/qrcode/scan/") {
                
                if !UserInstance.isLogin {
                    goToLoginVC()
                } else {
                    let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: QRCodePaymentVC.nameOfClass) as! QRCodePaymentVC
                    vc.strSubURL = strScanned.suffix(from: range.lowerBound)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

















