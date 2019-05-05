
import UIKit
import SnapKit
import RxSwift
import SDWebImage

let kChatImageMaxWidth: CGFloat = 125 //最大的图片宽度
let kChatImageMinWidth: CGFloat = 50 //最小的图片宽度
let kChatImageMaxHeight: CGFloat = 150 //最大的图片高度
let kChatImageMinHeight: CGFloat = 50 //最小的图片高度

class ChatImageCell: ChatBaseCell {

    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer()
        self.chatImageView.isUserInteractionEnabled = true
        self.chatImageView.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { (tapGesture) in
            guard let delegate = self.delegate else { return }
            delegate.cellDidTapedImageView(self)
        }).disposed(by: self.disposeBag)
        
        chatImageView.layer.cornerRadius = 4
        chatImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setCellContent(_ model: ChatMessageModel) {
        super.setCellContent(model)
        
        if let imageModel = model.imageModel {
            if let imageUrl = imageModel.imageUrl {
                /*self.chatImageView.setImageWithURLString(imageUrl, placeholderImage: ImageAsset.default_image.image)*/
                self.chatImageView.sd_setShowActivityIndicatorView(true)
                self.chatImageView.sd_setIndicatorStyle(.gray)
                let resizedUrlString = Utils.getResizedImageUrlString(imageUrl, width: "400")
                self.chatImageView.sd_setImage(with: URL(string: resizedUrlString), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cacheType, imageUrl) in
                    //finished loading...
                })
            } else if let image = imageModel.image {
                self.chatImageView.image = image
            }
        }
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = self.model else { return }
        guard let imageModel = model.imageModel else { return }
        
        var imageOriginalWidth = kChatImageMinWidth
        var imageOriginalHeight = kChatImageMinHeight
        
        if imageModel.imageWidth != nil {
            imageOriginalWidth = imageModel.imageWidth!
        }
        if imageModel.imageHeight != nil {
            imageOriginalHeight = imageModel.imageHeight!
        }
        
        let originalSize = CGSize(width: imageOriginalWidth, height: imageOriginalHeight)
        self.chatImageView.size = self.getThumbImageSize(originalSize)
        
        if model.fromMe {
            self.chatImageView.left = UIScreen.ts_width - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMaginLeft - self.chatImageView.width
        } else {
            self.chatImageView.left = kChatBubbleLeft
        }
        
        self.chatImageView.top = self.avatarImageView.top
        
        /*let stretchInsets = UIEdgeInsetsMake(30, 28, 23, 28)
        let stretchImage = model.fromMe ? ImageAsset.social_SenderImageNodeMask.image : ImageAsset.social_ReceiverImageNodeMask.image
        let bubbleMaskImage = stretchImage.resizableImage(withCapInsets: stretchInsets, resizingMode: .stretch)
        
        let layer = CALayer()
        layer.contents = bubbleMaskImage.cgImage
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(bubbleMaskImage)
        layer.frame = CGRect(x: 0, y: 0, width: self.chatImageView.width, height: self.chatImageView.height)
        /*if model.fromMe {
            layer.backgroundColor = UIColor(colorWithHexValue: 0xfff717).cgColor
        } else {
            layer.backgroundColor = UIColor(colorWithHexValue: 0x299ae9).cgColor
        }*/
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1
        self.chatImageView.layer.mask = layer
        self.chatImageView.layer.masksToBounds = true
        
        let stretchConverImage = model.fromMe ? ImageAsset.social_SenderImageNodeBorder.image : ImageAsset.social_ReceiverImageNodeBorder.image
        let bubbleConverImage = stretchConverImage.resizableImage(withCapInsets: stretchInsets, resizingMode: .stretch)
        self.coverImageView.image = bubbleConverImage
        if model.fromMe {
            self.coverImageView.setTintColor(UIColor(colorWithHexValue: 0xfff717))
        } else {
            self.coverImageView.setTintColor(UIColor(colorWithHexValue: 0x299ae9))
        }*/
        self.coverImageView.frame = CGRect(
            x: self.chatImageView.left - 1,
            y: self.chatImageView.top,
            width: self.chatImageView.width + 2,
            height: self.chatImageView.height + 2
        )
    }
    
    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        
        guard let imageModel = model.imageModel else {
            return 0
        }
        
        var height = kChatAvatarMarginTop + kChatBubblePaddingBottom
        
        let imageOriginalWidth = imageModel.imageWidth!
        let imageOriginalHeight = imageModel.imageHeight!
        
        /**
         *  1）如果图片的高度 >= 图片的宽度 , 高度就是最大的高度，宽度等比
         *  2）如果图片的高度 < 图片的宽度 , 以宽度来做等比，算出高度
         */
        if imageOriginalHeight >= imageOriginalWidth {
            height += kChatImageMaxHeight
        } else {
            let scaleHeight = imageOriginalHeight * kChatImageMaxWidth / imageOriginalWidth
            height += (scaleHeight > kChatImageMinHeight) ? scaleHeight : kChatImageMinHeight
        }
        height += 12  // 图片距离底部的距离 12
        
        model.cellHeight = height
        return model.cellHeight
    }
    
    func getThumbImageSize(_ originalSize: CGSize) -> CGSize {
        
        let imageRealHeight = originalSize.height
        let imageRealWidth = originalSize.width
        
        var resizeThumbWidth: CGFloat
        var resizeThumbHeight: CGFloat
        
        if imageRealHeight >= imageRealWidth {
            let scaleWidth = imageRealWidth * kChatImageMaxHeight / imageRealHeight
            resizeThumbWidth = (scaleWidth > kChatImageMinWidth) ? scaleWidth : kChatImageMinWidth
            resizeThumbHeight = kChatImageMaxHeight
        } else {
            let scaleHeight = imageRealHeight * kChatImageMaxWidth / imageRealWidth
            resizeThumbHeight = (scaleHeight > kChatImageMinHeight) ? scaleHeight : kChatImageMinHeight
            resizeThumbWidth = kChatImageMaxWidth
        }
        
        return CGSize(width: resizeThumbWidth, height: resizeThumbHeight)
    }
    
    func CGRectCenterRectForResizableImage(_ image: UIImage) -> CGRect {
        return CGRect(
            x: image.capInsets.left / image.size.width,
            y: image.capInsets.top / image.size.height,
            width: (image.size.width - image.capInsets.right - image.capInsets.left) / image.size.width,
            height: (image.size.height - image.capInsets.bottom - image.capInsets.top) / image.size.height
        )
    }
    
}










