//
//  MyOrderMineRefundVC.swift
//  paishop
//
//  Created by SeniorCorder on 6/12/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MyOrderMineRefundVC: UIViewController {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            tableView.ts_registerCellNib(MyOrderMineRefundCell.self)
        }
    }
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "售后/退款"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    
}


extension MyOrderMineRefundVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyOrderMineRefundCell = tableView.ts_dequeueReusableCell(MyOrderMineRefundCell.self)
        
        return cell
    }
}

extension MyOrderMineRefundVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}












