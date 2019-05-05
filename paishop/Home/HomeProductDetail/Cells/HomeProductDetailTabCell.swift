//
//  HomeProductDetailTabCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class HomeProductDetailTabCell: UITableViewCell {
    
    @IBOutlet weak var tab1Label: UILabel!
    @IBOutlet weak var tab1BottomView: UIView!
    
    @IBOutlet weak var tab2Label: UILabel!
    @IBOutlet weak var tab2BottomView: UIView!
    
    
    var parentVC: HomeProductDetailVC!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: HomeProductDetailVC) {
        self.parentVC = vc
        
        if vc.isSelectedImageDetails {
            tab1Label.textColor = MainColors.themeEndColors[0]
            tab1BottomView.backgroundColor = MainColors.themeEndColors[0]
            tab2Label.textColor = UIColor.black
            tab2BottomView.backgroundColor = UIColor.white
        } else {
            tab1Label.textColor = UIColor.black
            tab1BottomView.backgroundColor = UIColor.white
            tab2Label.textColor = MainColors.themeEndColors[0]
            tab2BottomView.backgroundColor = MainColors.themeEndColors[0]
        }
    }
    
    @IBAction func selectTab1(_ sender: UIButton) {
        parentVC.changeTab(0)
    }
    
    @IBAction func selectTab2(_ sender: UIButton) {
        parentVC.changeTab(1)
    }
    
    
    
    
}
