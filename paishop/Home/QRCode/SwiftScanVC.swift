

import UIKit
import swiftScan


class SwiftScanVC: LBXScanViewController {
    
    @IBOutlet weak var backView: RoundView!
    @IBOutlet weak var backImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backImageView.setTintColor(UIColor.white)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(selectBack))
        backImageView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.backView.layer.zPosition = 1
            self.view.bringSubviewToFront(self.backView)
        }
    }
    
    @objc func selectBack() {
        Utils.applyTouchEffect(backView)
        self.navigationController?.popViewController(animated: true)
    }

    

}
