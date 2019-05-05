
import UIKit

extension ChatVC {
    
    func setupSubviews(_ delegate: UITextViewDelegate) {
        self.setupActionBar(delegate)
        self.initTableView()
    }
    
    func setupActionBar(_ delegate: UITextViewDelegate) {
        self.chatActionBarView = UIView.ts_viewFromNib(ChatActionBarView.self)
        self.chatActionBarView.inputTextView.delegate = delegate
        self.view.addSubview(self.chatActionBarView)
        self.chatActionBarView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            make.height.equalTo(kChatActionBarOriginalHeight)
            
            strongSelf.actionBarPaddingBottomConstraint = make.bottom.equalTo(strongSelf.view.snp.bottom ).constraint
            if Utils.isIphoneX() {
                strongSelf.actionBarPaddingBottomConstraint = make.bottom.equalTo(strongSelf.view.snp.bottom).offset(-34).constraint
            }
        }
    }
    
    func initTableView() {
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { (tapGesture) in
            self.hideAllKeyboard()
        }).disposed(by: self.disposeBag)
        
        self.view.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.navBar.snp.bottom)
            make.bottom.equalTo(self.chatActionBarView.snp.top)
        }
    }
    
    
    
}
