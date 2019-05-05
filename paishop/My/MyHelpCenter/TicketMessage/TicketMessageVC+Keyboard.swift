
import Foundation

extension TicketMessageVC {
    func keyboardControl() {
        /**
         Keyboard notifications
         */
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardWillShowNotification.rawValue), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardDidShowNotification.rawValue), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardWillHideNotification.rawValue), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name(rawValue: UIResponder.keyboardDidHideNotification.rawValue), object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        //self.tableView.scrollToBottomAnimated(true)
        self.keyboardControl(notification, isShowing: true)
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            _ = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardControl(notification, isShowing: false)
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        
    }
    
    func keyboardControl(_ notification: Notification, isShowing: Bool) {
        /*
         If it is expression keyboard or keyboard sharing, go their own delegate keyboard handling incident.
         Because: When click to evoke a custom keyboard, the input bar of the operation bar needs resignFirstResponder, at this time will send a notification to the keyboard.
         Notification needs to reset the position of the actionbar frame calculation, calculated in the delegate callback. So here to intercept.
         The delegate has already been processed in the Button's click method.
         */
        
        /*
         处理 Default, Text 的键盘属性
         */
        var userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value
        
        let convertedFrame = self.view.convert(keyboardRect!, from: nil)
        var heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
        let options = UIView.AnimationOptions(rawValue: UInt(curve!) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        self.tableView.stopScrolling()
        if Utils.isIphoneX() && !isShowing {
            heightOffset += 34
        }
        self.actionBarPaddingBottomConstraint?.update(offset:-heightOffset)
        
        UIView.animate(
            withDuration: duration!,
            delay: 0,
            options: options,
            animations: {
                self.view.layoutIfNeeded()
                if isShowing {
                    //self.tableView.scrollToBottom(animated: false)
                    self.tableView.scrollBottomToLastRow()
                }
        },
            completion: { bool in
                
        })
    }
    
    func appropriateKeyboardHeight(_ notification: Notification) -> CGFloat {
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var keyboardHeight: CGFloat = 0.0
        if notification.name == UIResponder.keyboardWillShowNotification {
            keyboardHeight = min(endFrame.width, endFrame.height)
        }
        
        if notification.name == Notification.Name("") {
            keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            keyboardHeight -= self.tabBarController!.tabBar.frame.height
        }
        return keyboardHeight
    }
    
    func appropriateKeyboardHeight()-> CGFloat {
        var height = self.view.bounds.size.height
        height -= self.keyboardHeightConstraint!.constant
        
        guard height > 0 else {
            return 0
        }
        return height
    }
    
    fileprivate func hideCustomKeyboard() {
        let heightOffset: CGFloat = 0
        self.tableView.stopScrolling()
        if Utils.isIphoneX() {
            self.actionBarPaddingBottomConstraint?.update(offset: -34)
        } else {
            self.actionBarPaddingBottomConstraint?.update(offset: -heightOffset)
        }
        
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIView.AnimationOptions(),
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: { bool in
        })
    }
    
    func hideAllKeyboard() {
        self.hideCustomKeyboard()
        self.ticketActionBarView.resignKeyboard()
    }
}
