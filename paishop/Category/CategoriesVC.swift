//
//  CategoriesVC.swift
//  paishop
//
//  Created by Loyal Lauzier on 2018/09/02.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CategoriesVC: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDataSource
    
{

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableList: UITableView!
    @IBOutlet weak var collectionList: UICollectionView!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var imgBanner: UIImageView!
    
    var arrayFirst = NSArray()
    var arraySecond = NSArray()
    var arrayBanner = NSArray()
    var strBannerImage = String()
    var strBannerLink = String()
    
    var selectedCategoryIndex = NSInteger()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setupNavBar()
        self.initMainView()
        self.requestCategoryFirst()
        self.requestGetBanners()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func setupNavBar() {
        navBar.lblTitle.text = "商品分类"
        navBar.imgBack.isHidden = true
        navBar.btnBack.isHidden = true
        
//        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    func initMainView() {
        tableList.delegate = self
        tableList.dataSource = self
        tableList.showsVerticalScrollIndicator = false
        tableList.separatorColor = UIColor.clear
        tableList.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")

        collectionList.delegate = self
        collectionList.dataSource = self
        collectionList.alwaysBounceVertical = true
        collectionList.isScrollEnabled = true
        collectionList.register(UINib.init(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        self.automaticallyAdjustsScrollViewInsets = false

        arrayFirst = NSArray.init()
        arraySecond = NSArray.init()
        arrayBanner = NSArray.init()
        
        lblCategoryTitle.text = ""
        
    }
    
    // table view datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ((arrayFirst.count) > 0) {
            return (arrayFirst.count)
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        if arrayFirst.count > 0 {
            cell.selectionStyle = .none
            cell.setInfo(dic: arrayFirst[indexPath.row] as! NSDictionary)
        
            // set selected style
            if indexPath.row == selectedCategoryIndex {
                cell.bgView.isHidden = false
            } else {
                cell.bgView.isHidden = true
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectTableViewCell(index: indexPath.row)
    }
    
    // collection view datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arraySecond.count > 0 {
            return arraySecond.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        
        if arraySecond.count > 0 {
            cell.setInfo(dic: arraySecond[indexPath.row] as! NSDictionary)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.size.width
        let wi = (collectionWidth - 2 * 2) / 3
        let he = wi + 30
        
        return CGSize(width: wi, height: he)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dicSecondCategory = arraySecond[indexPath.row] as! NSDictionary
        let catId = dicSecondCategory["id"] as! Int64
        
        self.loadCategoryVC(categoryId: catId, productList: [ProductListModel](), isSub: true)
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func selectTableViewCell(index: NSInteger) {
        selectedCategoryIndex = index
        
        for i in 0...arrayFirst.count - 1 {
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = tableList.cellForRow(at: indexPath) as? CategoryTableViewCell {
                if i == index {
                    cell.bgView.isHidden = false
                } else {
                    cell.bgView.isHidden = true
                }
            }

        }

        // get first category's sub categories
        if arrayFirst.count > 0 && (arrayFirst[index] as! NSDictionary)["id"] != nil {
            let dicFirst = arrayFirst[index] as! NSDictionary
            lblCategoryTitle.text = String(format: "%@%@", dicFirst["name"] as! String, "列表")
            
            let caregoryId = dicFirst["id"] as! NSInteger
            self.requestCategorySub(index: caregoryId)
        }
    }
    
    @IBAction func tapBtnRank(_ sender: Any) {
        self.requestItemGood()
    }
    
    // MARK: - Load CategoryVC
    func loadCategoryVC(categoryId: Int64, productList: [ProductListModel], isSub: Bool) {
        let categoryVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryVC") as! CategoryVC
        categoryVC.isSub = isSub
        categoryVC.selectedCategoryId = categoryId
        categoryVC.productList = productList
        
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    @IBAction func tapBtnBanner(_ sender: Any) {
        if strBannerLink.count > 0 {
            let url = URL(string: strBannerLink)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            
        }
    }
    
    
    
    // MARK: - Request
    func requestCategoryFirst() {
        let parameters: Parameters = [:]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getCategoryFirst(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> first json:\n", json)
                self.arrayFirst = json["category"] as! NSArray
                self.tableList.reloadData()
                
                // select row
                self.selectTableViewCell(index: 0)
                
            }
            
        }
        
    }
    
    func requestCategorySub(index: NSInteger) {
        let parameters: Parameters = [
            "parent": index
        ]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getCategorySub(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> second json:\n", json)
                self.arraySecond = json["category"] as! NSArray
                self.collectionList.reloadData()
                
            } else {
                CategoryAPI.shared.getCategorySub(params: parameters) { (json, success) in
                    if success {
                        print(">>>> second json:\n", json)
                        self.arraySecond = json["category"] as! NSArray
                        self.collectionList.reloadData()
                        
                    } else {
                        return
                    }
                }
            }
            
        }
        
    }
    
    func requestGetBanners() {
        let parameters: Parameters = [:]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getBanners(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> banners json:\n", json)
                self.arrayBanner = json["banners"] as! NSArray
                let indexNumber = arc4random_uniform(UInt32(self.arrayBanner.count))
                
                // rand
                let dicBanner = self.arrayBanner[Int(indexNumber)] as! NSDictionary
                
                // set data
                if dicBanner["link"] != nil {
                    self.strBannerLink = dicBanner["link"] as! String
                }
                
                if dicBanner["image"] != nil {
                    self.strBannerImage = dicBanner["image"] as! String
                }

                self.imgBanner.sd_setImage(with: URL(string: self.strBannerImage), completed: nil)
            }
            
        }
        
    }
    
    func requestItemGood() {
        let parameters: Parameters = [:]
        
        ProgressHUD.showWithStatus()
        CategoryAPI.shared.getItemGood(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                print(">>>> items json:\n", json)
                let arrayGood = json["items"].arrayValue
                var productList = [ProductListModel]()
                
                for dicItem in arrayGood {
                    let model = ProductListModel.init(dicItem)
                    productList.append(model)
                    
                }
                
                // load CategoryVC
                self.loadCategoryVC(categoryId: 0, productList: productList, isSub: false)
                
            }
            
        }
        
    }
    
    
    
}






