
import Foundation
import BSImagePicker
import Photos

extension UIViewController {
    
    public static var topVC: UIViewController? {
        var presentedVC = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController {
            presentedVC = pVC
        }
        
        if presentedVC == nil {
            print("Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
        }
        
        return presentedVC
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, hideTabbar: Bool) {
        viewController.hidesBottomBarWhenPushed = hideTabbar
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func pushAndHideTabbar(_ viewController: UIViewController) {
        self.pushViewController(viewController, animated: true, hideTabbar: true)
    }
    
    func presentViewController(_ viewController: UIViewController, completion:(() -> Void)?) {
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: completion)
    }
    
    
    func presentImagePickerController(maxNumberOfSelections: Int, select: ((_ asset: PHAsset) -> Void)?, deselect: ((_ asset: PHAsset) -> Void)?, cancel: (([PHAsset]) -> Void)?, finish: (([PHAsset]) -> Void)?, completion: (() -> Void)?) {
        
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = maxNumberOfSelections
        //vc.albumButton.tintColor = UIColor.white
        //vc.cancelButton.tintColor = UIColor.white
        //vc.doneButton.tintColor = UIColor.white
        vc.cancelButton.title = "取消"
        vc.doneButton.title = "完成"
        vc.title = "所有照片"
        
        self.bs_presentImagePickerController(vc, animated: true, select: select, deselect: deselect, cancel: cancel, finish: finish, completion: completion)
        
    }
    
    func presentAlert(_ title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
        //let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okAction)
        //alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert(_ title: String, message: String? = nil, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
            completion()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert(_ title: String, message: String? = nil, completionOK: @escaping () -> Void, completionCancel: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
            completionOK()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            completionCancel()
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentOKAlert(_ title: String, message: String? = nil, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default) { (action) in
            completion()
        }
        alert.addAction(okAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alert, animated: true, completion: nil)
    }
    
}
















