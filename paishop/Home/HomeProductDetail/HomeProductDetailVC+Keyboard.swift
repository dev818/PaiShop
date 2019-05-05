

import UIKit


extension HomeProductDetailVC {
    
    func keyboardControl() {
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardWillShowNotification.rawValue), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardWillHideNotification.rawValue), object: nil)
        
    }
    
    func setupCommentSendButton() {
        commentSendButton.rx.tap.subscribe(onNext: { () in
            self.sendComment()
        }).disposed(by: self.disposeBag)
        
        commentTextView.rx.text.asObservable().subscribe(onNext: { (string) in
            guard let str = string else { return }
            if str.count >= 1 {
                self.commentSendButton.isEnabled = true
                self.commentSendImageView.setTintColor(UIColor.init(colorWithHexValue: 0x979797, alpha: 1.0))
            } else {
                self.commentSendButton.isEnabled = false
                self.commentSendImageView.setTintColor(UIColor.init(colorWithHexValue: 0x979797, alpha: 0.15))
            }
        }).disposed(by: self.disposeBag)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboradControl(notification, isShowing: true)
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboradControl(notification, isShowing: false)
    }
    
    private func keyboradControl(_ notification: Notification, isShowing: Bool) {
        var userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
        
        let convertedFrame = self.view.convert(keyboardRect!, from: nil)
        let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
        let options = UIView.AnimationOptions(rawValue: UInt(curve!) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        if isShowing {
            if Utils.isIphoneX() {
                self.commentFrameBottomConstraint.constant = heightOffset - 56 - 34
            } else {
                self.commentFrameBottomConstraint.constant = heightOffset - 56
            }
            
        } else {
            self.commentFrameBottomConstraint.constant = heightOffset
        }
        
        UIView.animate(
            withDuration: duration!,
            delay: 0,
            options: options,
            animations: {
                self.view.layoutIfNeeded()
                if isShowing {
                }
        },
            completion: { bool in
                
        })
        
    }
    
    
}







