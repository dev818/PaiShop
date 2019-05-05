//
//  LiveVideoChatCell.swift
//  paishop
//
//  Created by SeniorCorder on 5/1/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class LiveVideoChatCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCellContent(_ liveChat: LiveChatModel) {
        if liveChat.message! == "" {
            messageLabel.text = (liveChat.user?.name)! + " 来了."
        } else {
            let name = (liveChat.user?.name)!
            let message = liveChat.message!
            let nameAttributes = [
                NSAttributedString.Key.foregroundColor: generateRandomColor(),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
            ]
            let messageAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            let nameString = NSMutableAttributedString(string: name + ":", attributes: nameAttributes)
            let messageString = NSMutableAttributedString(string: message, attributes: messageAttributes)
            
            let resultString = NSMutableAttributedString()
            resultString.append(nameString)
            resultString.append(messageString)
            
            messageLabel.attributedText = resultString
        }
        
        
    }
    
    func generateRandomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
}
