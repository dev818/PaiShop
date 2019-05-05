

import UIKit

class TicketActionBarView: UIView {

    var inputTextViewCurrentHeight: CGFloat = kChatActionBarOriginalHeight
    
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            inputTextView.font = UIFont.systemFont(ofSize: 16)
            /*inputTextView.layer.borderColor = UIColor(colorWithHexValue: 0xdadada).cgColor
             inputTextView.layer.borderWidth = 1
             inputTextView.layer.cornerRadius = 4.0*/
            inputTextView.scrollsToTop = false
            inputTextView.textContainerInset = UIEdgeInsets(top: 7, left: 5, bottom: 5, right: 5)
            inputTextView.layer.backgroundColor = UIColor(colorWithHexValue: 0xf8fefb).cgColor
            inputTextView.returnKeyType = .send
            inputTextView.enablesReturnKeyAutomatically = true
            inputTextView.layoutManager.allowsNonContiguousLayout = false
            inputTextView.placeholder = "请写，，，，，"
        }
    }
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendImageView: UIImageView! {
        didSet {
            sendImageView.setTintColor(UIColor.init(colorWithHexValue: 0x979797, alpha: 0.15))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initContent()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.initContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initContent() {
        let topBorder = UIView()
        let bottomBorder = UIView()
        topBorder.backgroundColor = UIColor(colorWithHexValue: 0xc2c3c7)
        bottomBorder.backgroundColor = UIColor(colorWithHexValue: 0xc2c3c7)
        self.addSubview(topBorder)
        self.addSubview(bottomBorder)
        
        topBorder.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        
        bottomBorder.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        
        let inputBottomBorder = UIView()
        inputBottomBorder.backgroundColor = UIColor(colorWithHexValue: 0xcac8c8)
        self.addSubview(inputBottomBorder)
        inputBottomBorder.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self.inputTextView)
            make.height.equalTo(1)
        }
        
        //sendButton?.imageView?.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9, alpha: 0.3))
    }
    
    
    override func awakeFromNib() {
        initContent()
    }
    
    
    func resignKeyboard() {
        self.inputTextView.resignFirstResponder()
    }

}
