
import Foundation

extension TicketMessageVC {
    func setupSubviews(_ delegate: UITextViewDelegate) {
        self.setupActionBar(delegate)
        self.initTableView()
    }
    
    func setupActionBar(_ delegate: UITextViewDelegate) {
        self.ticketActionBarView = UIView.ts_viewFromNib(TicketActionBarView.self)
        self.ticketActionBarView.inputTextView.delegate = delegate
        self.view.addSubview(self.ticketActionBarView)
        self.ticketActionBarView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            
            if self?.ticketListModel.status == 0 { // finished
                make.height.equalTo(0)
            } else {
                make.height.equalTo(kChatActionBarOriginalHeight)
            }
            
            strongSelf.actionBarPaddingBottomConstraint = make.bottom.equalTo(strongSelf.view.snp.bottom ).constraint
            if Utils.isIphoneX() {
                strongSelf.actionBarPaddingBottomConstraint = make.bottom.equalTo(strongSelf.view.snp.bottom).offset(-34).constraint
            }
        }
        
        if self.ticketListModel.status == 0 {
            self.ticketActionBarView.isHidden = true
        } else {
            self.ticketActionBarView.isHidden = false
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
            
            if self.ticketListModel.status == 0 {
                if Utils.isIphoneX() {
                    make.bottom.equalTo(self.view.snp.bottom).offset(-34)
                } else {
                    make.bottom.equalTo(self.view.snp.bottom)
                }
            } else {
                make.bottom.equalTo(self.ticketActionBarView.snp.top)
            }           
            
        }
    }
}




