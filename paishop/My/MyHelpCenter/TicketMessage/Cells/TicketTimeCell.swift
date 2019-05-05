//
//  TicketTimeCell.swift
//  paishop
//
//  Created by Mac on 2/6/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

private let kTicketTimeLabelMaxWdith : CGFloat = UIScreen.ts_width - 30*2
private let kTicketTimeLabelPaddingLeft: CGFloat = 6   // Set aside 6 pixels left and right respectively
private let kTicketTimeLabelPaddingTop: CGFloat = 3   // Set aside 3 pixels left and right respectively
private let kTicketTimeLabelMarginTop: CGFloat = 10   // Top 10 px

class TicketTimeCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.layer.cornerRadius = 4
            timeLabel.layer.masksToBounds = true
            timeLabel.textColor = UIColor.white
            timeLabel.backgroundColor = UIColor (red: 190/255, green: 190/255, blue: 190/255, alpha: 0.6 )
        }
    }
    
    var model: TicketMessageModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    func setCellContent(_ model: TicketMessageModel) {
        self.model = model
        self.timeLabel.text = String(format: "%@", model.message!)
    }
    
    override func layoutSubviews() {
        guard let message = self.model?.message else { return }
        self.timeLabel.ts_setFrameWithString(message, width: kTicketTimeLabelMaxWdith)
        self.timeLabel.width = self.timeLabel.width + kTicketTimeLabelPaddingLeft*2
        self.timeLabel.left =  (UIScreen.ts_width - self.timeLabel.width) / 2
        self.timeLabel.height = self.timeLabel.height + kTicketTimeLabelPaddingTop*2
        self.timeLabel.top = kTicketTimeLabelMarginTop
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func heightForCell() -> CGFloat {
        return 40
    }
    
}
