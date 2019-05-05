
import Foundation


extension TicketMessageVC {
    
    func setupActionBarButtonInteraction() {
        let sendButton = self.ticketActionBarView.sendButton
        let sendImageView = self.ticketActionBarView.sendImageView
        let textView = self.ticketActionBarView.inputTextView
        
        
        sendButton?.rx.tap.subscribe(onNext: { () in
            self.TicketSendText()
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
                sendImageView?.setTintColor(UIColor.init(colorWithHexValue: 0x979797, alpha: 1.0))
            } else {
                //sendButton?.imageView?.setTintColor(UIColor.init(colorWithHexValue: 0x299ae9, alpha: 0.3))
                sendImageView?.setTintColor(UIColor.init(colorWithHexValue: 0x979797, alpha: 0.15))
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    func controlExpandableInputView(showExpandable: Bool) {
        let textView = self.ticketActionBarView.inputTextView
        let currentTextHeight = self.ticketActionBarView.inputTextViewCurrentHeight
        UIView.animate(withDuration: 0.3) {
            let textHeight = showExpandable ? currentTextHeight : kChatActionBarOriginalHeight
            self.ticketActionBarView.snp.updateConstraints({ (make) in
                make.height.equalTo(textHeight)
            })
            self.view.layoutIfNeeded()
            self.tableView.scrollBottomToLastRow()
            textView?.contentOffset = CGPoint.zero
        }
    }
}
