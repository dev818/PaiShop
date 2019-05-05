//
//  TicketTextCell.swift
//  paishop
//
//  Created by Mac on 2/6/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import YYText

private let kTicketTextFont: UIFont = UIFont.systemFont(ofSize: 16)

class TicketTextCell: TicketBaseCell {
    
    
    
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var contentLabel: YYLabel! {
        didSet {
            contentLabel.font = kTicketTextFont
            contentLabel.numberOfLines = 0
            contentLabel.backgroundColor = UIColor.clear
            contentLabel.textVerticalAlignment = YYTextVerticalAlignment.top
            contentLabel.displaysAsynchronously = false
            contentLabel.ignoreCommonProperties = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setCellContent(_ model: TicketMessageModel) {
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
    
    class func layoutHeight(_ model: TicketMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        // Parse rich text
        var textColor = UIColor.white
        if model.fromMe {
            textColor = UIColor.black
        }
        let attributedString = ChatTextParser.passTextWithColor(model.message!, font: kTicketTextFont, color: textColor)! //ChatTextParser.parseText(model.messageContent!, font: kChatTextFont)!
        model.richTextAttributedString = attributedString
        
        // Initialize the layout layout object
        let modifier = MyYYTextLinePositionModifier(font: kTicketTextFont)
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
    
}






