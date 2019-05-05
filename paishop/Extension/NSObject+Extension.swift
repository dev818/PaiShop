
import Foundation
import UIKit

extension NSObject {
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    // Used to retrieve the reuse identifier of the cell
    class var customId: String {
        return String(format: "%@_identifier", self.nameOfClass)
    }
}
