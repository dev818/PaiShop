
import UIKit
import ESTabBarController_swift

class BasicTabContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        
        textColor = UIColor(colorWithHexValue: 0x2e2e2e)
        highlightTextColor = MainColors.themeEndColors[selectedTheme] //UIColor(colorWithHexValue: 0x299aea)
        iconColor = UIColor(colorWithHexValue: 0x2e2e2e)
        highlightIconColor = MainColors.themeEndColors[selectedTheme] //UIColor(colorWithHexValue: 0x299aea)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
