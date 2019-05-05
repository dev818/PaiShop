

import UIKit
import YYText

// When the message is on the left, the distance of the text from the left of the screen
let kChatTextLeft: CGFloat = 72

// The message is on the right, 70: the distance of the text from the left of the screen, and 82: the distance of the text from the right of the screen
let kChatTextMaxWidth: CGFloat = UIScreen.ts_width - kChatTextLeft - 82

// The top of the text differs from the top of the bubble by 12 pixels
let kChatTextMarginTop: CGFloat = 12

// The bottom of the text differs from the bottom of the bubble by 11 pixels
let kChatTextMarginBottom: CGFloat = 11

// The left side of the text differs from the left side of the bubble by 17, including the head cutting department
let kChatTextMarginLeft: CGFloat = 17

// Bubble more than the width of the text value
let kChatBubbleWidthBuffer: CGFloat = kChatTextMarginLeft*2

// Transparent height at the bottom of the bubble
let kChatBubbleBottomTransparentHeight: CGFloat = 11

// Top of text + Bottom of text
let kChatBubbleHeightBuffer: CGFloat = kChatTextMarginTop + kChatTextMarginBottom

// Bubble minimum height 54, to prevent deformation of the drawing picture
let kChatBubbleImageViewHeight: CGFloat = 54

// Bubble minimum width of 50, to prevent deformation of the picture stretching
let kChatBubbleImageViewWidth: CGFloat = 50

// The top of the bubble has a transparent portion of about 3 pixels and needs to be flush with the picture
let kChatBubblePaddingTop: CGFloat = 3

// Bubble and avatar gap value: 5
let kChatBubbleMaginLeft: CGFloat = 5

// Bubble from the bottom of the dividing line gap value: 8
let kChatBubblePaddingBottom: CGFloat = 8
// The distance of the bubble from the left of the screen
let kChatBubbleLeft: CGFloat = kChatAvatarMarginLeft + kChatAvatarWidth + kChatBubbleMaginLeft

private let kChatTextFont: UIFont = UIFont.systemFont(ofSize: 16)



class ChatTextCell: ChatBaseCell {
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var contentLabel: YYLabel! {
        didSet {
            contentLabel.font = kChatTextFont
            contentLabel.numberOfLines = 0
            contentLabel.backgroundColor = UIColor.clear
            contentLabel.textVerticalAlignment = YYTextVerticalAlignment.top
            contentLabel.displaysAsynchronously = false
            contentLabel.ignoreCommonProperties = true
            contentLabel.highlightTapAction = ({[weak self] containerView, text, range, rect in
                self!.didTapRichLabelText(self!.contentLabel, textRange: range)
            })            
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setCellContent(_ model: ChatMessageModel) {
        super.setCellContent(model)
        if let richTextLinePositionModifier = model.richTextLinePositionModifier {
            self.contentLabel.linePositionModifier = richTextLinePositionModifier
        }
        
        if let richTextLayout = model.richTextLayout {
            self.contentLabel.textLayout = richTextLayout
        }
        
        if let richTextAttributedString = model.richTextAttributedString {
            self.contentLabel.attributedText = richTextAttributedString
        }
        
        // Stretch the image area
        let stretchImage = model.fromMe ? ImageAsset.social_SenderTextNodeBkg.image : ImageAsset.social_ReceiverTextNodeBkg.image
        let bubbleImage = stretchImage.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
        self.bubbleImageView.image = bubbleImage
        if model.fromMe {
            self.bubbleImageView.setTintColor(UIColor(colorWithHexValue: 0xfff717))
            
        } else {
            self.bubbleImageView.setTintColor(UIColor(colorWithHexValue: 0x299ae9))
        }
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let model = self.model else { return }
        
        self.contentLabel.size = model.richTextLayout!.textBoundingSize
        
        if model.fromMe {
            // value = width of the screen - margin of the avatar 10 - width of the avatar - gap value of the bubble from the avatar - (width of the text - 2 times the left-right distance between the text and the bubble or the smallest distance between the bubbles)
            self.bubbleImageView.left = UIScreen.ts_width - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMaginLeft - max(self.contentLabel.width + kChatBubbleWidthBuffer, kChatBubbleImageViewWidth)
        } else {
            // Distance from the left side of the screen
            self.bubbleImageView.left = kChatBubbleLeft
        }
        
        // Set the bubble width
        self.bubbleImageView.width = max(self.contentLabel.width + kChatBubbleWidthBuffer, kChatBubbleImageViewWidth)
        // Set the height of the bubble
        self.bubbleImageView.height = max(self.contentLabel.height + kChatBubbleHeightBuffer + kChatBubbleBottomTransparentHeight, kChatBubbleImageViewHeight)
        // value = Bottom of the avatar - Bubble transparency interval value
        self.bubbleImageView.top = self.nicknameLabel.bottom - kChatBubblePaddingTop
        // value = bubble top + difference between text and bubbles
        self.contentLabel.top = self.bubbleImageView.top + kChatTextMarginTop
        // value = left side of the bubble + the difference between the text and the bubble
        self.contentLabel.left = self.bubbleImageView.left + kChatTextMarginLeft
    }
    
    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        // Parse rich text
        var textColor = UIColor.white
        if model.fromMe {
            textColor = UIColor.black
        }
        let attributedString = ChatTextParser.passTextWithColor(model.message!, font: kChatTextFont, color: textColor)! //ChatTextParser.parseText(model.messageContent!, font: kChatTextFont)!
        model.richTextAttributedString = attributedString
        
        // Initialize the layout layout object
        let modifier = MyYYTextLinePositionModifier(font: kChatTextFont)
        model.richTextLinePositionModifier = modifier
        
        // Initialize YYTextContainer
        let textContainer: YYTextContainer = YYTextContainer()
        textContainer.size = CGSize(width: kChatTextMaxWidth, height: CGFloat.greatestFiniteMagnitude)
        textContainer.linePositionModifier = modifier
        textContainer.maximumNumberOfRows = 0
        
        // Set up layout
        let textLayout = YYTextLayout(container: textContainer, text: attributedString)
        model.richTextLayout = textLayout
        
        // Calculate the height
        var height: CGFloat = kChatAvatarMarginTop + kChatBubblePaddingBottom
        let stringHeight = modifier.heightForLineCount(Int(textLayout!.rowCount))
        
        height += max(stringHeight + kChatBubbleHeightBuffer + kChatBubbleBottomTransparentHeight, kChatBubbleImageViewHeight)
        model.cellHeight = height
        return model.cellHeight
    }

    
    fileprivate func didTapRichLabelText(_ label: YYLabel, textRange: NSRange) {
        // Parse userinfo text
        let attributedString = label.textLayout!.text
        if textRange.location >= attributedString.length {
            return
        }
        guard let hightlight: YYTextHighlight = attributedString.yy_attribute(YYTextHighlightAttributeName, at: UInt(textRange.location)) as? YYTextHighlight else {
            return
        }
        guard let info = hightlight.userInfo, info.count > 0 else {
            return
        }
        
        guard let delegate = self.delegate else {
            return
        }
        
        if let phone: String = info[kChatTextKeyPhone] as? String {
            delegate.cellDidTapedPhone(self, phoneString: phone)
        }
        
        if let URL: String = info[kChatTextKeyURL] as? String {
            delegate.cellDidTapedLink(self, linkString: URL)
        }
        
        if let deepLink: String = info[kChatTextKeyDeepLink] as? String {
            delegate.cellDidTapedDeepLink(self, deepLinkString: deepLink)
        }
    }
    
}



















