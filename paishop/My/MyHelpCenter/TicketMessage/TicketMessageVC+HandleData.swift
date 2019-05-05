

import Foundation

extension TicketMessageVC {
    
    func TicketSendText() {
        dispatch_async_safely_to_main_queue({[weak self] in
            guard let strongSelf = self else { return }
            guard let textView = strongSelf.ticketActionBarView.inputTextView else {return }
            guard textView.text.ts_length < 1000 else {
                ProgressHUD.showWarningWithStatus("超出字数限制")
                return
            }
            
            let text = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count == 0 {
                ProgressHUD.showWarningWithStatus("不能发送空白消息")
                return
            }
            
            let string = strongSelf.ticketActionBarView.inputTextView.text
            strongSelf.sendTextMessage(string!)
            let model = TicketMessageModel.init(text: string!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if (strongSelf.itemDataSource.isEmpty) {
                let timeModel = TicketMessageModel.init(updatedAt: dateString)
                strongSelf.itemDataSource.append(timeModel)
                let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
                strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
            } else {
                let lastMessage = strongSelf.itemDataSource.last!
                if model.isLateForFiveMinutes(lastMessage) {
                    let timeModel = TicketMessageModel.init(updatedAt: dateString)
                    strongSelf.itemDataSource.append(timeModel)
                    let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
                    strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
                }
            }
            
            
            strongSelf.itemDataSource.append(model)
            let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
            strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
            textView.text = "" //发送完毕后清空
            
            strongSelf.textViewDidChange(strongSelf.ticketActionBarView.inputTextView)
        })
    }
    
    
    func sendTextMessage(_ text: String) {
        let parameters: [String : Any] = [
            "id" : ticketListModel.id,
            "message" : text,
            "type" : 1
        ]
        MyAPI.shared.ticketMessageSend(params: parameters) { (json, success) in
            if success {
                print("Ticket Message Send...")
                print(json)
            } else {
                
            }
        }
    }
    
}






