

import Foundation


extension ChatVC {
    
    func chatSendText() {
        dispatch_async_safely_to_main_queue({[weak self] in
            guard let strongSelf = self else { return }
            guard let textView = strongSelf.chatActionBarView.inputTextView else {return }
            guard textView.text.ts_length < 1000 else {
                ProgressHUD.showWarningWithStatus("超出字数限制")
                return
            }
            
            let text = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.count == 0 {
                ProgressHUD.showWarningWithStatus("不能发送空白消息")
                return
            }
            
            let string = strongSelf.chatActionBarView.inputTextView.text
            strongSelf.sendTextMessage(string!)
            /*let model = ChatMessageModel.init(text: string!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if (strongSelf.itemDataSource.isEmpty) {
                let timeModel = ChatMessageModel.init(updatedAt: dateString)
                strongSelf.itemDataSource.append(timeModel)
                let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
                strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
            } else {
                let lastMessage = strongSelf.itemDataSource.last!
                if model.isLateForTwoMinutes(lastMessage) {
                    let timeModel = ChatMessageModel.init(updatedAt: dateString)
                    strongSelf.itemDataSource.append(timeModel)
                    let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
                    strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
                }
            }
            
            
            strongSelf.itemDataSource.append(model)
            let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
            strongSelf.tableView.insertRowsAtBottom([insertIndexPath])*/
            textView.text = "" //发送完毕后清空
            
            strongSelf.textViewDidChange(strongSelf.chatActionBarView.inputTextView)
        })
    }
    
    
    func sendTextMessage(_ text: String) {
        let parameters: [String : Any] = [
            "id" : self.chatListModel.id,
            "message" : text,
            "type" : MessageContentType.Text.rawValue
        ]
        SocialAPI.shared.chatMessageSend(params: parameters) { (json, success) in
            if success {
                print("Chat Message Send....")
                print(json)
                self.loadSentMsg = true
                self.loadChatMessages(loadFirst: true)
            } else {
                
            }
        }
    }
    
    func chatSendImage(_ image: UIImage) {
        dispatch_async_safely_to_main_queue({[weak self] in
            //guard let strongSelf = self else { return }
            
            self?.postChatImage(image)
            
            /*let imageModel = ChatImageModel.init(image)
            let model = ChatMessageModel.init(imageModel: imageModel)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = dateFormatter.string(from: Date())
            if (strongSelf.itemDataSource.isEmpty) {
                let timeModel = ChatMessageModel.init(updatedAt: dateString)
                strongSelf.itemDataSource.append(timeModel)
                let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
                strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
            } else {
                let lastMessage = strongSelf.itemDataSource.last!
                if model.isLateForTwoMinutes(lastMessage) {
                    let timeModel = ChatMessageModel.init(updatedAt: dateString)
                    strongSelf.itemDataSource.append(timeModel)
                    let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
                    strongSelf.tableView.insertRowsAtBottom([insertIndexPath])
                }
            }
            
            strongSelf.itemDataSource.append(model)
            let insertIndexPath = IndexPath(row: strongSelf.itemDataSource.count - 1, section: 0)
            strongSelf.tableView.insertRowsAtBottom([insertIndexPath])*/
        })
    }
    
    func postChatImage(_ image: UIImage) {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let sufix = "_\(width)x\(height).jpg"
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000000)
        let objectKey = Constants.CHAT_IMAGE + "/\(self.chatListModel.id!)/" + "\(timestamp)" + sufix
        let imageName = Constants.ALIYUN_URL_PREFIX + objectKey
        AliyunUtil.shared.putImage(image, objectKey: objectKey) { (result) in
            if result {
                DispatchQueue.main.async {
                    self.sendImageMessage(imageName, width: width, height: height)
                }
            }
        }
    }
    
    func sendImageMessage(_ imageName: String, width: Int, height: Int) {
        
        /*let width = image.size.width
        let height = image.size.height
        
        let size = "[\(width), \(height)]"
        
        let parameters: [String : Any] = [
            "id" : String(self.chatListModel.id),
            "type" : String(MessageContentType.Image.rawValue),
            "size" : size
        ]
        SocialAPI.shared.chatMessageSendFile(image: image, params: parameters) { (json, success) in
            if success {
                print("Chat Send Message File...")
                print(json)
            } else {
                
            }
        }*/
        
        let size = "[\(width), \(height)]"
        let parameters: [String : Any] = [
            "id" : String(self.chatListModel.id),
            "type" : MessageContentType.Image.rawValue,
            "size" : size,
            "message" : imageName,
        ]
        SocialAPI.shared.chatMessageSend(params: parameters) { (json, success) in
            if success {
                print("Chat Message Send....")
                print(json)
            } else {
                print("Chat Message Send Error........")
                print(json)
            }
        }
    }
    
    
}



















