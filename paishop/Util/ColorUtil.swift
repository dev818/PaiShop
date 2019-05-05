
import Foundation
import UIKit


extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            
            alpha: alpha
        )
    }
    
    public static func color(fromHexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(colorInteger(fromHexString: fromHexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    private static func colorInteger(fromHexString: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: fromHexString)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}


public struct MainColors {
    
    static let pageSelected = UIColor(colorWithHexValue: 0xe21314) //Image slider page
    
    static let pageUnSelected = UIColor.white//UIColor(colorWithHexValue: 0xbbbbbb)
    
    static let buttonNormal = UIColor(colorWithHexValue: 0x666666) // Button Bar Menu
    
    static let defaultNavBar = UIColor(colorWithHexValue: 0xf9f9f9)
    
    static let defaultNavBarBorder = UIColor(colorWithHexValue: 0xb2b2b2)
    
    static let buttonBarBgColor = UIColor(colorWithHexValue: 0xffffff)
    
    static let buttonBarItemSelectedTitleColor = UIColor(colorWithHexValue: 0x299aea)
    
    
    static let themeStartColors = [
        UIColor(colorWithHexValue: 0xB830C6),
        UIColor(colorWithHexValue: 0x2ebf91),
        UIColor(colorWithHexValue: 0xf5af19),
        UIColor(colorWithHexValue: 0xff416c),
    ]
    
    static let themeEndColors = [
        UIColor(colorWithHexValue: 0xF52966),
        UIColor(colorWithHexValue: 0x8360c3),
        UIColor(colorWithHexValue: 0xf12711),
        UIColor(colorWithHexValue: 0xff4b2b),
    ]
    
    static let defaultTitle = UIColor(colorWithHexValue: 0x242323)
    
    static let defaultSubTitle = UIColor(colorWithHexValue: 0x666666)
    
    static let defaultContent = UIColor(colorWithHexValue: 0x878787)
    
    static let defaultBackground = UIColor(colorWithHexValue: 0xF2F2F2)
    
    
    
}








