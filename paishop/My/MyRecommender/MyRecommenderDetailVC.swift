//
//  MyRecommenderDetailVC.swift
//  paishop
//
//  Created by Admin on 8/24/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Alamofire

class MyRecommenderDetailVC: UIViewController, SecondLevelMemberTableViewCellDelegate {
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myProfileImage: UIImageView!
    @IBOutlet weak var myNameLabel: UILabel!
    @IBOutlet weak var myLevelImage: UIImageView!
    @IBOutlet weak var firstLevelCountLabel: UILabel!
    @IBOutlet weak var firstLevelIncomeLabel: UILabel!
    @IBOutlet weak var secondLevelCountLabel: UILabel!
    @IBOutlet weak var secondLevelIncomeLabel: UILabel!
    @IBOutlet weak var totalIncomeLabel: UILabel!
    @IBOutlet weak var levelMembersTableView: UITableView! {
        didSet {
            levelMembersTableView.ts_registerCellNib(FirstLevelMemberCell.self)
            levelMembersTableView.rowHeight = UITableView.automaticDimension
            levelMembersTableView.estimatedRowHeight = 44.0
            levelMembersTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            //levelMembersTableView.isUserInteractionEnabled = false
            
            levelMembersTableView.register(UINib(nibName: "CollapsibleTableViewHeader", bundle: nil),
                                           forHeaderFooterViewReuseIdentifier: "CollapsibleTableViewHeader")
            
            levelMembersTableView.register(UINib(nibName: "SecondLevelMemberTableViewCell", bundle: nil),
                                           forCellReuseIdentifier: "SecondLevelMemberTableViewCell")

        }
    }
    
//    var sections = sectionsData
    var sections = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLevel1Members()
        setupNavBar()
        setupUI()
        
        // Do any additional setup after loading the view.
        
        levelMembersTableView.estimatedRowHeight = 44.0
        levelMembersTableView.rowHeight = UITableView.automaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "合伙人"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    func setupUI() {
        self.myNameLabel.text = Utils.getNickName()
        let resizedUrl = Utils.getResizedImageUrlString(UserInstance.avatar!, width: "400")
        self.myProfileImage.setImageWithURLStringNoCache(resizedUrl, placeholderImage: ImageAsset.icon_avatar.image)
        self.myLevelImage.image = levelImages[UserInstance.level_id!]
        
    }
    
    func getLevel1Members() {
        
        var parameters: [String : Any] = [:]
        parameters["id"] = UserInstance.id!
        
        if !NetworkUtil.isReachable() {
            ProgressHUD.showWarningWithStatus("请检查您的互联网连接")
            return
        }
        ProgressHUD.showWithStatus()
        
        MyAPI.shared.getInvites(params: parameters) { (json, success) in
            if success {
                ProgressHUD.dismiss()
                //h.g.n
                //self.storeList = StoreDetailModel.getStoreDetailsFromJson(json["stores"])

                var intFirstp: Float = 0
                var intSecondp: Float = 0

                if json["first_p"] is String {
                    intFirstp = Float(json["first_p"] as! String) ?? 0
                } else if json["first_p"] is NSNumber {
                    intFirstp = Float(truncating: json["first_p"] as! NSNumber)
                }
                
                if json["second_p"] is String {
                    intSecondp = Float(json["second_p"] as! String) ?? 0
                } else if json["second_p"] is NSNumber {
                    intSecondp = Float(truncating: json["second_p"] as! NSNumber)
                }
                
                self.firstLevelCountLabel.text = String(format: "%li%@", json["first_count"] as! NSInteger, "人")
                self.secondLevelCountLabel.text = String(format: "%li%@", json["second_count"] as! NSInteger, "人")
                self.firstLevelIncomeLabel.text = String(format: "%@%.0f%@", "累计获得", intFirstp, "π")
                self.secondLevelIncomeLabel.text = String(format: "%@%.0f%@", "累计获得", intSecondp, "π")
                let totalIncome = intFirstp + intSecondp
                self.totalIncomeLabel.text = String(format: "%@%.0f%@", "(累计总获得", totalIncome, "π)")
                
                // -----------------------------------------
                var arrayFirstInvites = NSArray()
                arrayFirstInvites =  json["first_invites"] as! NSArray

                for dicFirst in arrayFirstInvites {
                    let sectionData = Section(firstInvite: dicFirst as! NSDictionary,
                                              items: [NSDictionary]())
                    self.sections.append(sectionData)
                }
                
                self.levelMembersTableView.reloadData()
                
            } else {
                MyAPI.shared.getInvites(params: parameters, completion: { (json1, success1) in
                    ProgressHUD.dismiss()
                    if success1 {
                        //self.storeList = StoreDetailModel.getStoreDetailsFromJson(json1["stores"])
                        //h.g.n
                        
                    } else {
//                        let errors = json1["errors"] as! NSDictionary
//                        if let error = errors.values.first {
//                            if let firstError =  error.arrayObject?.first as? String {
//                                ProgressHUD.showErrorWithStatus(firstError)
//                            } else {
//                                ProgressHUD.showErrorWithStatus("失败.")
//                            }
//                        } else {
//                            ProgressHUD.showErrorWithStatus("失败.")
//                        }
                    }
                })
            }
        }
    }
    
    
    // SecondLevelMemberCollectionViewCell delegate
    func didTapButtonSecondVisiteProfile(index: NSInteger, indexSection: NSInteger) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmMemberDetailVC.nameOfClass) as! MyRecmMemberDetailVC
        
        vc.dicUser = sections[indexSection].items[index]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension MyRecommenderDetailVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyRecommenderDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : 1
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CollapsibleTableViewHeader") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "CollapsibleTableViewHeader")
        
        header.setInfo(sec: sections[section])
        
        header.setCollapsed(sections[section].collapsed)
        header.section = section
        header.delegate = self
        
        return header
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SecondLevelMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SecondLevelMemberTableViewCell", for: indexPath) as! SecondLevelMemberTableViewCell

        if sections[indexPath.section].items.count > 0 {
            cell.delegate = self
            cell.indexSection = indexPath.section
            cell.arrayList = sections[indexPath.section].items as NSArray
            cell.collectionViewList.reloadData()
            
            return cell
            
        } else {
            
            return UITableViewCell.init()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

extension MyRecommenderDetailVC: CollapsibleTableViewHeaderDelegate {

    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        // get seconds
        var parameters: [String : Any] = [:]
        parameters["id"] = sections[section].firstInvite["indx"] as! NSInteger
        
        ProgressHUD.showWithStatus()
        MyAPI.shared.getSeconds(params: parameters) { (json, success) in
            ProgressHUD.dismiss()
            
            if success {
                let arraySecondes = json["first_invites"] as! NSArray
                
                // insert items with arraySeconds
                self.sections[section].items = arraySecondes as! [NSDictionary]
                print(">>>>>>>>>>>>> sections:\n", self.sections)
                
                let collapsed = !self.sections[section].collapsed
                
                // Toggle collapse
                self.sections[section].collapsed = collapsed
                header.setCollapsed(collapsed)
                
                self.levelMembersTableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
                
            }
        }

    }
    
    func didTapButtonFirstVisiteProfile(index: NSInteger) {
        let vc = UIStoryboard(name: "Recommender", bundle: nil).instantiateViewController(withIdentifier: MyRecmMemberDetailVC.nameOfClass) as! MyRecmMemberDetailVC
        
        vc.dicUser = sections[index].firstInvite
        self.navigationController?.pushViewController(vc, animated: true)

     }
    
    
}
