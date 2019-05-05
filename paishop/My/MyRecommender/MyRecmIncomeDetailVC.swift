//
//  MyRecmIncomeDetailVC.swift
//  paishop
//
//  Created by Admin on 8/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyRecmIncomeDetailVC: UIViewController, UIScrollViewDelegate {

    var arrayList = NSArray()

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tatolIncomeLabel: UILabel!
    @IBOutlet weak var outPointLabel: UILabel!
    @IBOutlet weak var levelIncomeLabel: UILabel!
    @IBOutlet weak var consumeIncomeLabel: UILabel!
    @IBOutlet weak var storeIncomeLabel: UILabel!
    @IBOutlet weak var totalIncomeBackView: RoundRectView! {
        didSet {
            totalIncomeBackView.dropShadow()
        }
    }
    @IBOutlet weak var incomesBackView: RoundRectView! {
        didSet {
            incomesBackView.dropShadow()
        }
    }
    @IBOutlet weak var incomeTableView: UITableView! {
        didSet {
            incomeTableView.ts_registerCellNib(MyRecmIncomeDetailCell.self)
            incomeTableView.rowHeight = UITableView.automaticDimension
            incomeTableView.estimatedRowHeight = 100
            incomeTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            //levelMembersTableView.isUserInteractionEnabled = false
            
            arrayList = NSArray.init()
        }
    }
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet var tabImages: [UIImageView]!
    @IBOutlet var tabLabels: [UILabel]!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var valueTotal = String()
    var valueLevel = String()
    var valueOrder = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        self.scrollView.delegate = self
        self.didTab1Tapped()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "累计收益"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @IBAction func pointConvertPageGo(_ sender: Any) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmConverterVC.nameOfClass) as! MyRecmConverterVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tab1Tapped(_ sender: UIButton) {
        self.didTab1Tapped()
    }
    
    func didTab1Tapped() {
        tabImages[0].isHidden = false
        tabLabels[0].textColor = UIColor.red
        for i in 1..<5 {
            tabImages[i].isHidden = true
            tabLabels[i].textColor = UIColor.darkGray
        }
        
        // request
        self.requestGetDetailAll()
    }
    
    
    @IBAction func tab2Tapped(_ sender: UIButton) {
        tabImages[1].isHidden = false
        tabLabels[1].textColor = UIColor.red
        for i in 0..<5 {
            if i != 1 {
                tabImages[i].isHidden = true
                tabLabels[i].textColor = UIColor.darkGray
            }
        }
        
        // request
        self.requestGetDetail(index: 2)
        
    }
    
    @IBAction func tab3Tapped(_ sender: UIButton) {
        tabImages[2].isHidden = false
        tabLabels[2].textColor = UIColor.red
        for i in 0..<5 {
            if i != 2 {
                tabImages[i].isHidden = true
                tabLabels[i].textColor = UIColor.darkGray
            }
        }
        
        // request
        self.requestGetDetail(index: 3)
    }
    
    @IBAction func tab4Tapped(_ sender: UIButton) {
        tabImages[3].isHidden = false
        tabLabels[3].textColor = UIColor.red
        for i in 0..<5 {
            if i != 3 {
                tabImages[i].isHidden = true
                tabLabels[i].textColor = UIColor.darkGray
            }
        }
        
        // request
        self.requestGetDetail(index: 4)
    }
    
    @IBAction func tab5Tapped(_ sender: UIButton) {
        tabImages[4].isHidden = false
        tabLabels[4].textColor = UIColor.red
        for i in 0..<5 {
            if i != 4 {
                tabImages[i].isHidden = true
                tabLabels[i].textColor = UIColor.darkGray
            }
        }
    }
}

extension MyRecmIncomeDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyRecmIncomeDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyRecmIncomeDetailCell = tableView.ts_dequeueReusableCell(MyRecmIncomeDetailCell.self)
        cell.setInfo(dic: arrayList[indexPath.row] as! NSDictionary)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    // MARK: - Rquest get detail all
    func requestGetDetailAll() {
        self.arrayList = NSArray()

        let userId = UserInstance.id
        let parameters: Parameters = [
            "id": userId ?? 0
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.getDetailAll(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {                
                
                var order_profit: Float = 0
                var level_profit: Float = 0
                var out_point: Float = 0
                var stores_profit: Float = 0
                var total: Float = 0
                
                if json["order_profit"] is String {
                    order_profit = Float(json["order_profit"] as! String) ?? 0
                } else if json["order_profit"] is NSNumber {
                    order_profit = Float(truncating: json["order_profit"] as! NSNumber)
                }

                if json["level_profit"] is String {
                    level_profit = Float(json["level_profit"] as! String) ?? 0
                } else if json["level_profit"] is NSNumber {
                    level_profit = Float(truncating: json["level_profit"] as! NSNumber)
                }
                
                if json["out_point"] is String {
                    out_point = Float(json["out_point"] as! String) ?? 0
                } else if json["out_point"] is NSNumber {
                    out_point = Float(truncating: json["out_point"] as! NSNumber)
                }
                
                if json["stores_profit"] is String {
                    stores_profit = Float(json["stores_profit"] as! String) ?? 0
                } else if json["stores_profit"] is NSNumber {
                    stores_profit = Float(truncating: json["stores_profit"] as! NSNumber)
                }
                
                if json["total"] is String {
                    total = Float(json["total"] as! String) ?? 0
                } else if json["total"] is NSNumber {
                    total = Float(truncating: json["total"] as! NSNumber)
                }
                
                print(">>> json:\n", json)
                
                self.valueTotal = String(format: "%.2f", total)
                self.valueLevel = String(format: "%.2f", level_profit)
                self.valueOrder = String(format: "%.2f", order_profit)
                
//                self.tatolIncomeLabel.text = String(format: "%li%@", self.valueTotal, "π")
                self.tatolIncomeLabel.text = String(format: "%@%@", "总收益 : ",self.valueTotal)
                self.outPointLabel.text = String(format: "%@%.2f", "已转π : ", out_point)
                self.levelIncomeLabel.text = String(format: "%@%@", "推广：", self.valueLevel)
                self.consumeIncomeLabel.text = String(format: "%@%@%@", "| 消费奖金：", self.valueOrder, " |")
                self.storeIncomeLabel.text = String(format: "%@%.2f", "商家奖金：", stores_profit)

                self.arrayList = json["transactions"] as! NSArray
            }
            
            self.incomeTableView.reloadData()

        }
    }
    
    // MARK: - Rquest get detail
    func requestGetDetail(index: NSInteger) {
        self.arrayList = NSArray.init()
        
        let userId = UserInstance.id
        let parameters: Parameters = [
            "id": userId ?? 0,
            "type": index
        ]
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.getDetail(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
//                self.valueTotal = json["total"] as! NSInteger
//                self.valueLevel = json["level_profit"] as! NSInteger
//                self.valueOrder = json["order_profit"] as! String
//
//                self.tatolIncomeLabel.text = String(format: "%li%@", self.valueTotal, "π")
//                self.levelIncomeLabel.text = String(format: "%@%li", "推荐奖金：", self.valueLevel)
//                self.consumeIncomeLabel.text = String(format: "%@%@%@", "| 消费奖金：", self.valueOrder, "|")
//                self.storeIncomeLabel.text = String(format: "%@%li", "推荐商家奖金：", 0)
                print(json)
                self.arrayList = json["transactions"] as! NSArray
                
            }
            
            self.incomeTableView.reloadData()

        }
    }
    
    
    
}
