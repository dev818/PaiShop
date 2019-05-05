//
//  FirstLevelMemberCell.swift
//  paishop
//
//  Created by Admin on 8/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class FirstLevelMemberCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var dropdownImage: UIImageView!
    @IBOutlet weak var droprightImage: UIImageView!
    
    var hideSecondLevel = true
    var parent: MyRecommenderDetailVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: MyRecommenderDetailVC) {
        self.parent = vc
    }
    
    @IBAction func dropShowBtnTapped(_ sender: UIButton) {
        self.dropdownImage.isHidden = !self.dropdownImage.isHidden
        self.droprightImage.isHidden = !self.droprightImage.isHidden
    }
    
    @IBAction func profileImageTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmMemberDetailVC.nameOfClass) as! MyRecmMemberDetailVC
        parent.navigationController?.pushViewController(vc, animated: true)
    }
    

}
