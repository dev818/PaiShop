//
//  MyVCOrderCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/5/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyVCOrderCell: UITableViewCell {
    
    @IBOutlet weak var orderFrame1: UIView!
    @IBOutlet weak var orderFrame2: UIView!
    @IBOutlet weak var orderFrame3: UIView!
    @IBOutlet weak var orderFrame4: UIView!
    @IBOutlet weak var orderFrame5: UIView!
    
    @IBOutlet weak var orderImageView1: UIImageView! {
        didSet {
            orderImageView1.setTintColor(UIColor.init(colorWithHexValue: 0x818181))
        }
    }
    @IBOutlet weak var orderImageView2: UIImageView! {
        didSet {
            orderImageView2.setTintColor(UIColor.init(colorWithHexValue: 0x818181))
        }
    }
    @IBOutlet weak var orderImageView3: UIImageView! {
        didSet {
            orderImageView3.setTintColor(UIColor.init(colorWithHexValue: 0x818181))
        }
    }
    @IBOutlet weak var orderImageView4: UIImageView! {
        didSet {
            orderImageView4.setTintColor(UIColor.init(colorWithHexValue: 0x818181))
        }
    }
    @IBOutlet weak var orderImageView5: UIImageView! {
        didSet {
            orderImageView5.setTintColor(UIColor.init(colorWithHexValue: 0x818181))
        }
    }
    
    var parentVC: MyVC!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellContent(_ vc: MyVC) {
        self.parentVC = vc
    }
    
    //go to order all
    @IBAction func selectOrderAll(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
        vc.selectedIndex = 0
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to cart
    @IBAction func selectOrder1(_ sender: UIButton) {
        /*let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: ShoppingCartVC.nameOfClass) as! ShoppingCartVC
        parentVC.navigationController?.pushViewController(vc, animated: true)*/
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
        vc.selectedIndex = 1
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to pending order
    @IBAction func selectOrder2(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
        vc.selectedIndex = 2
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to delivering
    @IBAction func selectOrder3(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
        vc.selectedIndex = 3
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    //go to completed
    @IBAction func selectOrder4(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineVC.nameOfClass) as! MyOrderMineVC
        vc.selectedIndex = 4
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectOrder5(_ sender: UIButton) {
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: MyOrderMineRefundVC.nameOfClass)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}










