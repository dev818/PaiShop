
import UIKit
import SKPhotoBrowser


extension ChatVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //点击发送文字，包含表情
            self.chatSendText()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let contentHeight = textView.contentSize.height
        guard contentHeight < kChatActionBarTextViewMaxHeight else {
            return
        }
        
        self.chatActionBarView.inputTextViewCurrentHeight = contentHeight + 17
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



extension ChatVC: ChatCellDelegate {
    
    
    func cellDidTapedAvatarImage(_ cell: ChatBaseCell) {
        //ProgressHUD.showSuccessWithStatus("Tap Avatar")
        guard let model = cell.model else { return }
        if !model.fromMe {
            guard let userId = model.user?.id else { return }
            let parameters: [String: Any] = [
                "id" : userId
            ]
            SocialAPI.shared.userInfo(params: parameters, completion: { (json, success) in
                if success {
                    print("User Info...")
                    print(json)
                    
                    let storesJson = json["stores"].arrayValue
                    if storesJson.count > 0 {
                        let storeId = storesJson[0]["id"].int64Value
                        
                        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
                        vc.storeId = storeId
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let userInfo = UserModel.init(json)
                        
                        let vc = UIStoryboard(name: "Social", bundle: nil).instantiateViewController(withIdentifier: ChatUserProfileVC.nameOfClass) as! ChatUserProfileVC
                        vc.userInfo = userInfo
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            })
        }
    }
    
    func cellDidTapedImageView(_ cell: ChatBaseCell) {
        //ProgressHUD.showSuccessWithStatus("Tap Image")
        guard let model = cell.model else { return }
        guard let imageModel = model.imageModel else { return }
        if let imageUrl = imageModel.imageUrl {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImageURL(imageUrl, holder: nil)
            images.append(photo)
            let browser = SKPhotoBrowser(photos: images, initialPageIndex: 0)
            self.present(browser, animated: true) { }
        } else if let image = imageModel.image {
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(image)
            images.append(photo)
            let browser = SKPhotoBrowser(photos: images, initialPageIndex: 0)
            self.present(browser, animated: true) { }
        }
    }
    
    func cellDidTapedLink(_ cell: ChatBaseCell, linkString: String) {
        
    }
    
    func cellDidTapedPhone(_ cell: ChatBaseCell, phoneString: String) {
        //ProgressHUD.showSuccessWithStatus("Tap Phone")
    }
    
    func cellDidTaped(_ cell: ChatBaseCell) {
        
    }
    
    func cellDidTapedDeepLink(_ cell: ChatBaseCell, deepLinkString: String) {
        var isProduct = true
        var resultIndex: String!
        /*var indexStartOfText = deepLinkString.index(deepLinkString.startIndex, offsetBy: 29)
        
        let parseString = deepLinkString.lowercased()
        if (parseString.range(of: "store") != nil) {
            indexStartOfText = deepLinkString.index(deepLinkString.startIndex, offsetBy: 27)
            isProduct = false
        }
        
        let resultIndex = deepLinkString[indexStartOfText...]
        //ProgressHUD.showSuccessWithStatus("Tap Deep Link:" + resultIndex)*/
        
        let productIndex  = getQueryStringParameter(url: deepLinkString, param: "product")
        let storeIndex = getQueryStringParameter(url: deepLinkString, param: "store")
        
        if let index = productIndex {
            resultIndex = index
            isProduct = true
        } else if let index = storeIndex {
            resultIndex = index
            isProduct = false
        }
        if resultIndex == nil {
            return
        }
        
        if isProduct {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeProductDetailVC.nameOfClass) as! HomeProductDetailVC
            vc.itemId = Int64(resultIndex)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
            vc.storeId = Int64(resultIndex)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
}

















