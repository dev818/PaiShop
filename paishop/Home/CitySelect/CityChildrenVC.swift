
import UIKit
import SwiftyJSON

class CityChildrenVC: UIViewController {
    
    var mode = HomeVC.nameOfClass // GuideVC.nameOfClass
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }        
    }
    
    var cityRootId: Int!
    var cityChildren: [CityModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        
        /*tableView.isHidden = true
        ProgressHUD.showWithStatus()
        
        let parameters: [String: Any] = [
            "id" : cityRootId
        ]
        
        HomeAPI.shared.cityChildren(params: parameters) { (json, success) in
            if success {
                self.tableView.isHidden = false
                ProgressHUD.dismiss()
                self.cityChildren = CityModel.getCitiesFromJson(json["cities"])
                self.tableView.ts_reloadData {  }
            } else {
                //load again...
                HomeAPI.shared.cityChildren(params: parameters, completion: { (json, success1) in
                    self.tableView.isHidden = false
                    ProgressHUD.dismiss()
                    if success1 {
                        self.cityChildren = CityModel.getCitiesFromJson(json["cities"])
                        self.tableView.ts_reloadData {  }
                    } else {
                        let errors = json["errors"].dictionaryValue
                        if let error = errors.values.first {
                            if let firstError =  error.arrayObject?.first as? String {
                                ProgressHUD.showErrorWithStatus(firstError)
                            } else {
                                ProgressHUD.showErrorWithStatus("失败.")
                            }
                        } else {
                            ProgressHUD.showErrorWithStatus("失败.")
                        }
                    }
                })
            }
        }*/
        
        self.cityChildren = self.getCityChildrenFromJson()
        self.tableView.reloadData()
    }

    
    private func setupNavBar() {
        navBar.lblTitle.text = "选择市"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    

    func getCityChildrenFromJson() -> [CityModel] {
        guard let JSONData = Data.ts_dataFromJSONFile("cities") else {
            return []
        }
        
        do {
            let json = try JSON(data: JSONData)
            let allCities = CityModel.getCitiesFromJson(json)
            var cities: [CityModel] = []
            for city in allCities {
                if city.parent! == cityRootId {
                    cities.append(city)
                }
            }
            return cities
        } catch {
            return []
        }
    }

}


extension CityChildrenVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityChildren.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cityChildren[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //let city = self.cityChildren[indexPath.row]
        let city: [String: Any] = ["mode" : self.mode, "city" : self.cityChildren[indexPath.row] ]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.HOME_CITY_SELECT), object: nil, userInfo: city)
         
        
        if self.mode == MyStoreProductPostVC.nameOfClass {
            let vcs: [UIViewController] = self.navigationController!.viewControllers
            for vc in vcs {
                if vc is MyStoreProductPostVC {
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        
    }
}


extension CityChildrenVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}














