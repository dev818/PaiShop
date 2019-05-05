

import Foundation

@objc protocol ChatCellDelegate: class {
    
    @objc optional func cellDidTaped(_ cell: ChatBaseCell)
    
    func cellDidTapedAvatarImage(_ cell: ChatBaseCell)
    
    func cellDidTapedImageView(_ cell: ChatBaseCell)
    
    func cellDidTapedLink(_ cell: ChatBaseCell, linkString: String)
    
    func cellDidTapedPhone(_ cell: ChatBaseCell, phoneString: String)
    
    func cellDidTapedDeepLink(_ cell: ChatBaseCell, deepLinkString: String)
    
}
