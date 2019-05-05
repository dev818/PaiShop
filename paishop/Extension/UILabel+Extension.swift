

import Foundation

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
}

extension String {
    
    func toPointer() -> UnsafePointer<UInt8>? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        let stream = OutputStream(toBuffer: buffer, capacity: data.count)
        
        stream.open()
        data.withUnsafeBytes({ (p: UnsafePointer<UInt8>) -> Void in
            stream.write(p, maxLength: data.count)
        })
        
        stream.close()
        
        return UnsafePointer<UInt8>(buffer)
    }
}
