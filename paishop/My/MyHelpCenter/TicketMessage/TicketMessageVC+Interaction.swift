
import Foundation

extension TicketMessageVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //点击发送文字，包含表情
            self.TicketSendText()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let contentHeight = textView.contentSize.height
        guard contentHeight < kChatActionBarTextViewMaxHeight else {
            return
        }
        
        self.ticketActionBarView.inputTextViewCurrentHeight = contentHeight + 17
        self.controlExpandableInputView(showExpandable: true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //设置键盘类型，响应 UIKeyboardWillShowNotification 事件
        //self.chatActionBarView.inputTextViewCallKeyboard()
        
        //使 UITextView 滚动到末尾的区域
        UIView.setAnimationsEnabled(false)
        let range = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(range)
        UIView.setAnimationsEnabled(true)
        return true
    }
}
