//
//  CollapsibleTableViewHeader.swift
//  ios-swift-collapsible-table-section
//
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
    func didTapButtonFirstVisiteProfile(index: NSInteger)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var imgLevel: UIImageView!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblArrow: UILabel!
    
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
        
        self.initMainView()
     }
 
    func initMainView() {
        imgPhoto.layer.masksToBounds = true
        imgPhoto.layer.cornerRadius = imgPhoto.frame.size.width / 2
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
        
        
    }
    
    func setInfo(sec: Section) {
        var strName = String()
        var strPhoto = String()
        var intLevelId = 0
        var strCreatedAt = String()
        
        if (sec.firstInvite["pai_name"] is NSNull) || sec.firstInvite["pai_name"] == nil {
            strName = ""
        } else {
            strName = sec.firstInvite["pai_name"] as! String
        }
        
        if (sec.firstInvite["image"] is NSNull) || sec.firstInvite["image"] == nil {
            strPhoto = ""
        } else {
            strPhoto = sec.firstInvite["image"] as! String
        }
        
        if (sec.firstInvite["level_id"] is NSNull) || sec.firstInvite["level_id"] == nil {
            intLevelId = 0
        } else {
            intLevelId = sec.firstInvite["level_id"] as! NSInteger
        }

        if (sec.firstInvite["created_at"] is NSNull) || sec.firstInvite["created_at"] == nil {
            strCreatedAt = ""
        } else {
            strCreatedAt = sec.firstInvite["created_at"] as! String
        }
        
        lblName.text = strName
        imgPhoto.setImageWithURLStringNoCache(strPhoto,
                                              placeholderImage: ImageAsset.icon_avatar.image)
        
        imgLevel.image = levelImages[intLevelId]
        lblCreatedAt.text = strCreatedAt
        if intLevelId > 0 {
            lblLevel.text = levelNames2[intLevelId]
        } else {
            lblLevel.text = ""
        }
        
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        
        delegate?.toggleSection(self, section: cell.section)
    }
    
    
    func setCollapsed(_ collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        lblArrow.rotate(collapsed ? 0.0 : .pi / 2)
    }
    
    @IBAction func tapBtnBgPhoto(_ sender: Any) {
        self.delegate?.didTapButtonFirstVisiteProfile(index: section)
    }
}
