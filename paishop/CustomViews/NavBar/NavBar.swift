
import UIKit

protocol NavBarDelegate: class {
    func didSelectBack()
}

class NavBar: UIView {
    
    weak var delegate: NavBarDelegate?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var navBar: GradientView!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var borderLine: UIView!
    @IBOutlet weak var rightButton: UIButton! {
        didSet {
            rightButton.isHidden = true
        }
    }
    
    @IBOutlet weak var rightButtonImageView: UIImageView! {
        didSet {
            rightButtonImageView.isHidden = true
        }
    }
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        //for using CustomView in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //for using  CustomView in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NavBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if Utils.isIphoneX() {
            contentTopConstraint.constant = 44
        }
        
        setTheme()
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.delegate?.didSelectBack()
    }
    
    func setTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        navBar.startColor = MainColors.themeStartColors[selectedTheme]
        navBar.endColor = MainColors.themeEndColors[selectedTheme]
        imgBack.setTintColor(UIColor.white)
        lblTitle.textColor = UIColor.white
        rightButtonImageView.setTintColor(UIColor.white)
    }
    
    func setDefaultNav() {
        navBar.startColor = MainColors.defaultNavBar
        navBar.endColor = MainColors.defaultNavBar
        imgBack.setTintColor(UIColor.black)
        lblTitle.textColor = UIColor.black
    }
    
}






