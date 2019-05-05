
import UIKit
import SVProgressHUD

class ProgressHUD: NSObject {
    
    class func initHUD() {
        SVProgressHUD.setBackgroundColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 14))
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
    }
    
    class func showSuccessWithStatus(_ string: String) {
        self.ProgressHUDShow(.success, status: string)
    }
    
    class func showErrorWithObject(_ error: NSError) {
        self.ProgressHUDShow(.errorObject, status: nil, error: error)
    }
    
    //失败，String
    class func showErrorWithStatus(_ string: String) {
        self.ProgressHUDShow(.errorString, status: string)
    }
    
    //转菊花
    class func showWithStatus(_ string: String? = nil) {
        self.ProgressHUDShow(.loading, status: string)
    }
    
    //警告
    class func showWarningWithStatus(_ string: String) {
        self.ProgressHUDShow(.info, status: string)
    }
    
    class func dismiss() {
        SVProgressHUD.dismiss()
    }
    
    class func ProgressHUDShow(_ type: HUDType, status: String? = nil, error: NSError? = nil) {
        switch type {
        case .success:
            SVProgressHUD.showSuccess(withStatus: status)
        case .errorObject:
            guard let newError = error else {
                SVProgressHUD.showError(withStatus: "Error:出错拉")
                return
            }
            
            if newError.localizedFailureReason == nil {
                SVProgressHUD.showError(withStatus: "Error:出错拉")
            } else {
                SVProgressHUD.showError(withStatus: error!.localizedFailureReason)
            }
        case .errorString:
            SVProgressHUD.showError(withStatus: status)
        case .info:
            SVProgressHUD.showInfo(withStatus: status)
        case .loading:
            SVProgressHUD.show(withStatus: status)
        }
    }
    
    
    
    enum HUDType: Int {
        case success, errorObject, errorString, info, loading
    }

}
