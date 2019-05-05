

import UIKit

class MyThemeSettingVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkImage1: UIImageView! {
        didSet {
            checkImage1.isHidden = true
        }
    }
    @IBOutlet weak var checkImage2: UIImageView! {
        didSet {
            checkImage2.isHidden = true
        }
    }
    @IBOutlet weak var checkImage3: UIImageView! {
        didSet {
            checkImage3.isHidden = true
        }
    }
    @IBOutlet weak var checkImage4: UIImageView! {
        didSet {
            checkImage4.isHidden = true
        }
    }
    
    
    var selectedTheme = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        handleSelectTheme()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "主题换肤"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }


    @IBAction func selectCurrent(_ sender: UIButton) {
        handleSelectTheme()
        UserDefaultsUtil.shared.setSelectedTheme(selectedTheme)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.popViewController(animated: true)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.CHANGE_THEME), object: nil, userInfo: nil)
    }
    
    @IBAction func selectDefault(_ sender: UIButton) {
        selectedTheme = 0
        handleSelectTheme()
        UserDefaultsUtil.shared.setSelectedTheme(selectedTheme)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.popViewController(animated: true)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.CHANGE_THEME), object: nil, userInfo: nil)
    }
    
    @IBAction func selectTheme1(_ sender: UIButton) {
        selectedTheme = 0
        handleSelectTheme()
    }
    
    @IBAction func selectTheme2(_ sender: UIButton) {
        selectedTheme = 1
        handleSelectTheme()
    }
    
    @IBAction func selectTheme3(_ sender: UIButton) {
        selectedTheme = 2
        handleSelectTheme()
    }
    
    @IBAction func selectTheme4(_ sender: UIButton) {
        selectedTheme = 3
        handleSelectTheme()
    }
    
    
    private func handleSelectTheme() {
        checkImage1.isHidden = true
        checkImage2.isHidden = true
        checkImage3.isHidden = true
        checkImage4.isHidden = true
        switch selectedTheme {
        case 0:
            checkImage1.isHidden = false
        case 1:
            checkImage2.isHidden = false
        case 2:
            checkImage3.isHidden = false
        case 3:
            checkImage4.isHidden = false
        default:
            checkImage1.isHidden = false
        }
    }
    
    
}

extension MyThemeSettingVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
