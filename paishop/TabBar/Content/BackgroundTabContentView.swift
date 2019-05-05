
import UIKit

class BackgroundTabContentView: BasicTabContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = UIColor(colorWithHexValue: 0x2e2e2e)
        highlightTextColor = UIColor(colorWithHexValue: 0xf9fb12)
        iconColor = UIColor(colorWithHexValue: 0x2e2e2e)
        highlightIconColor = UIColor.init(colorWithHexValue: 0xf9fb12)
        backdropColor = UIColor(colorWithHexValue: 0xffffff)
        highlightBackdropColor = UIColor(colorWithHexValue: 0x299aea)
    }
    
    public convenience init(specialWithAutoImplies implies: Bool) {
        self.init(frame: CGRect.zero)
        textColor = .white
        highlightTextColor = .white
        iconColor = .white
        highlightIconColor = .white
        backdropColor = UIColor.init(red: 17/255.0, green: 86/255.0, blue: 136/255.0, alpha: 1.0)
        highlightBackdropColor = UIColor.init(red: 22/255.0, green: 24/255.0, blue: 25/255.0, alpha: 1.0)
        if implies {
            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(BackgroundTabContentView.playImpliesAnimation(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc internal func playImpliesAnimation(_ sender: AnyObject?) {
        if self.selected == true || self.highlighted == true {
            return
        }
        let view = self.imageView
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.15, 0.8, 1.15]
        impliesAnimation.duration = 0.3
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        impliesAnimation.isRemovedOnCompletion = true
        view.layer.add(impliesAnimation, forKey: nil)
    }

}
