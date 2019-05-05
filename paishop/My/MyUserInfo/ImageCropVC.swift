

import UIKit
import IGRPhotoTweaks

class ImageCropVC: IGRPhotoTweakViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        setCropAspectRect(aspect: "1:1")
        lockAspectRatio(true)
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "裁剪图像"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @IBAction func selectCancel(_ sender: Any) {
        dismissAction()
    }
    
    @IBAction func selectCrop(_ sender: Any) {
        cropAction()
    }
    
    override open func customCanvasHeaderHeigth() -> CGFloat {
        var heigth: CGFloat = 0.0
        
        if UIDevice.current.orientation.isLandscape {
            heigth = 40.0
        } else {
            heigth = 100.0
        }
        
        return heigth
    }
    
    

}



extension ImageCropVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}















