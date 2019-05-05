
import Foundation
import UIKit

class RoundRectButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //let radius: CGFloat = 5.0
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}


class RoundButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
    
    
}


protocol SecurityCodeButtonDelegate: class {
    func toSetTextField() 
}

class SecurityCodeButton: UIButton {
    
    weak var delegate: SecurityCodeButtonDelegate?
    
    var _time: Int?
    var _phone: String?
    var _format: String?
    var timer: Timer?
    
    func withFormat(_ format: String, phone: String, time: Int) {
        _time = time
        _phone = phone
        _format = format
    }
    
    func securityCode() -> Bool {
        let regex = "^(0|86|17951)?(13[0-9]|15[0-9]|17[0-9]|18[0-9]|14[0-9])[0-9]{8}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let isMatch = predicate.evaluate(with: _phone)
        return isMatch
    }
    
    func startTime() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshTime), userInfo: nil, repeats: true)
    }
    
    @objc func refreshTime() {
        _time = _time! - 1
        if _time == 0 {
            stopTime()
        } else {
            self.setTitle(String.init(format: "%dS", _time!), for: .normal)
        }
    }
    
    func stopTime() {
        timer?.invalidate()
        self.isEnabled = true
        self.setTitle(_format, for: .normal)
        delegate?.toSetTextField()
    }
    
}



class RoundRectView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //let radius: CGFloat = 5.0
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}

class RoundView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}





class GradientView: UIView {
    @IBInspectable var startColor: UIColor = .blue {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endColor: UIColor = .green {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowY: CGFloat = -3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowBlur: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var startPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
        layer.shadowRadius = shadowBlur
        layer.shadowOpacity = 1
    }
}





class RoundImageView: UIImageView {
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet { setNeedsLayout() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

class RoundRectImageView: UIImageView {
    @IBInspectable var cornerRadius: CGFloat = 4 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet { setNeedsLayout() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
}




class LRSearchBar: UISearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.heightAnchor.constraint(equalToConstant: 40).isActive = true
        //self.showsCancelButton = false
        self.placeholder = "搜索"
        self.backgroundColor = .clear
        let topView: UIView = self.subviews[0] as UIView
        var searchField:UITextField!
        for subView in topView.subviews {
            if let field = subView as? UITextField {
                field.backgroundColor = UIColor.lightGray
                //searchField.heightAnchor.constraint(equalToConstant: 30).isActive = true
                field.layer.cornerRadius = field.frame.height / 2
                field.layer.masksToBounds = true
                field.textColor = UIColor.black
                field.autocapitalizationType = .none
                let textFieldPlaceHolder : UILabel = (field.value(forKey: "placeholderLabel") as! UILabel)
                textFieldPlaceHolder.textColor = UIColor.darkGray
                textFieldPlaceHolder.text = "搜索"
                searchField = field
                break
            }
        }
        
        for view1 in self.subviews {
            for view2 in view1.subviews {
                if view2 is UIButton {
                    let cancelButton = view2 as! UIButton
                    cancelButton.setTitleColor(.white, for: .normal)
                    cancelButton.setTitle("取消", for: .normal)
                    cancelButton.isEnabled = true
                    cancelButton.isUserInteractionEnabled = true
                }
            }
        }
        
        if ((searchField) != nil) {
            let leftview = searchField.leftView as! UIImageView
            let magnifyimage = leftview.image
            
            let tintimg = magnifyimage?.withRenderingMode(.alwaysTemplate)
            leftview.image = tintimg
            leftview.tintColor = UIColor.darkGray
            searchField.leftView = leftview
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}




class CopyableLabel: UILabel {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu)))
    }
    
    @objc func showMenu(sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}



class TopCornerView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
        clipsToBounds = true
    }
    
    
}











