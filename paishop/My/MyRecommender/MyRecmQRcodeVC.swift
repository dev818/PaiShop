//
//  MyRecmQRcodeVC.swift
//  paishop
//
//  Created by Admin on 8/25/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyRecmQRcodeVC: UIViewController {
   
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }  

    private func setupNavBar() {
        navBar.lblTitle.text = "二维码分享"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }

}

extension MyRecmQRcodeVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
