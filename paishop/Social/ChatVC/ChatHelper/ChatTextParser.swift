
import UIKit
import YYText

public let kChatTextKeyPhone = "phone"
public let kChatTextKeyURL = "URL"
public let kChatTextKeyDeepLink = "DeepLink"


class ChatTextParser: NSObject {

    class func parseText(_ text: String, font: UIFont) -> NSMutableAttributedString? {
        if text.count == 0 {
            return nil
        }
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributedText.yy_font = font
        attributedText.yy_color = UIColor.black
        
        // Match phone
        self.enumeratePhoneParser(attributedText)
        // Match URL
        self.enumerateURLParser(attributedText)
        
        return attributedText
    }
    
    class func passTextWithColor(_ text: String, font: UIFont, color: UIColor) -> NSMutableAttributedString? {
        if text.count == 0 {
            return nil
        }
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributedText.yy_font = font
        attributedText.yy_color = color
        
        // Match phone
        self.enumeratePhoneParser(attributedText)
        //Match DeepLink
        self.enumerateDeepLinkParser(attributedText)
        // Match URL
        self.enumerateURLParser(attributedText)        
        
        return attributedText
    }
    
    /**
     Match Phone
     
     - parameter attributedText: Rich Text
     */
    fileprivate class func enumeratePhoneParser(_ attributedText: NSMutableAttributedString) {
        let phonesResults = ChatTextParserHelper.regexPhoneNumber.matches(
            in: attributedText.string,
            options: [.reportProgress],
            range: attributedText.yy_rangeOfAll()
        )
        for phone: NSTextCheckingResult in phonesResults {
            if phone.range.location == NSNotFound && phone.range.length <= 1 {
                continue
            }
            
            let highlightBorder = ChatTextParserHelper.highlightBorder
            if (attributedText.yy_attribute(YYTextHighlightAttributeName, at: UInt(phone.range.location)) == nil) {
                attributedText.yy_setColor(UIColor.init(ts_hexString: "#1F79FD"), range: phone.range)
                let highlight = YYTextHighlight()
                highlight.setBackgroundBorder(highlightBorder)
                
                let stringRange = attributedText.string.range(from:phone.range)!
                highlight.userInfo = [kChatTextKeyPhone : String(attributedText.string[stringRange])] //highlight.userInfo = [kChatTextKeyPhone : attributedText.string.substring(with: stringRange)]
                
                attributedText.yy_setTextHighlight(highlight, range: phone.range)
            }
        }
    }
    
    /**
     Match URL
     
     - parameter attributedText: Rich Text
     */
    fileprivate class func enumerateURLParser(_ attributedText: NSMutableAttributedString) {
        let URLsResults = ChatTextParserHelper.regexURLs.matches(
            in: attributedText.string,
            options: [.reportProgress],
            range: attributedText.yy_rangeOfAll()
        )
        for URL: NSTextCheckingResult in URLsResults {
            if URL.range.location == NSNotFound && URL.range.length <= 1 {
                continue
            }
            
            let highlightBorder = ChatTextParserHelper.highlightBorder
            if (attributedText.yy_attribute(YYTextHighlightAttributeName, at: UInt(URL.range.location)) == nil) {
                attributedText.yy_setColor(UIColor.init(ts_hexString: "#1F79FD"), range: URL.range)
                let highlight = YYTextHighlight()
                highlight.setBackgroundBorder(highlightBorder)
                
                let stringRange = attributedText.string.range(from:URL.range)!
                highlight.userInfo = [kChatTextKeyURL : String(attributedText.string[stringRange])] //highlight.userInfo = [kChatTextKeyURL : attributedText.string.substring(with: stringRange)]
                attributedText.yy_setTextHighlight(highlight, range: URL.range)
            }
        }
    }
    
    fileprivate class func enumerateDeepLinkParser(_ attributedText: NSMutableAttributedString) {
        let deepLinkResults = ChatTextParserHelper.regexDeepLink.matches(
            in: attributedText.string,
            options: [.reportProgress],
            range: attributedText.yy_rangeOfAll()
        )
        for deepLink: NSTextCheckingResult in deepLinkResults {
            if deepLink.range.location == NSNotFound && deepLink.range.length <= 1 {
                continue
            }
            
            let highlightBorder = ChatTextParserHelper.highlightBorder
            if (attributedText.yy_attribute(YYTextHighlightAttributeName, at: UInt(deepLink.range.location)) == nil) {
                attributedText.yy_setColor(UIColor.red, range: deepLink.range)
                let highlight = YYTextHighlight()
                highlight.setBackgroundBorder(highlightBorder)
                
                let stringRange = attributedText.string.range(from:deepLink.range)!
                highlight.userInfo = [kChatTextKeyDeepLink : String(attributedText.string[stringRange])]
                attributedText.yy_setTextHighlight(highlight, range: deepLink.range)
            }
            
        }
    }
    
    
}



class ChatTextParserHelper {
    /// 高亮的文字背景色
    class var highlightBorder: YYTextBorder {
        get {
            let highlightBorder = YYTextBorder()
            highlightBorder.insets = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
            highlightBorder.fillColor = UIColor.init(ts_hexString: "#D4D1D1")
            return highlightBorder
        }
    }
    
    /**
     正则：匹配 www.a.com 或者 http://www.a.com 的类型
     
     ref: http://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
     */
    class var regexURLs: NSRegularExpression {
        get {
            let regex: String = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|^[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*)*"
            let regularExpression = try! NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            return regularExpression
        }
    }
    
    /**
     正则：匹配 7-25 位的数字, 010-62104321, 0373-5957800, 010-62104321-230
     */
    class var regexPhoneNumber: NSRegularExpression {
        get {
            let regex = "([\\d]{7,25}(?!\\d))|((\\d{3,4})-(\\d{7,8}))|((\\d{3,4})-(\\d{7,8})-(\\d{1,4}))"
            let regularExpression = try! NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            return regularExpression
        }
    }
    
    class var regexDeepLink: NSRegularExpression {
        get {
            //let regex: String = "http://paikepaifu.(product|store).cn/[0-9]*"
            let regex: String = "http://paikepaifu.cn[-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*"
            let regularExpression = try! NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            return regularExpression
        }
    }
}


private extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view)!
        let to = range.upperBound.samePosition(in: utf16view)!
        return NSMakeRange(utf16view.distance(from: utf16view.startIndex, to: from), utf16view.distance(from: from, to: to))
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
















