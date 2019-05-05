

import UIKit
import SwiftyJSON

class CityRootVC: UIViewController {
    
    var mode = HomeVC.nameOfClass
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    var cityRoots: [CityModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()

        /*tableView.isHidden = true
        ProgressHUD.showWithStatus()
        HomeAPI.shared.cityRoot { (json, success) in
            if success {
                self.tableView.isHidden = false
                ProgressHUD.dismiss()
                self.cityRoots = CityModel.getCitiesFromJson(json["cities"])
                self.tableView.ts_reloadData {  }
            } else {
                //load again...
                HomeAPI.shared.cityRoot(completion: { (json, success1) in
                    self.tableView.isHidden = false
                    ProgressHUD.dismiss()
                    if success1 {
                        self.cityRoots = CityModel.getCitiesFromJson(json["cities"])
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
        
        self.cityRoots = getCityRootsFromJson()
        self.tableView.reloadData()
        
    }
    
    private func setupNavBar() {
        navBar.lblTitle.text = "选择省"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }

    func getCityRootsFromJson() -> [CityModel] {
        guard let JSONData = Data.ts_dataFromJSONFile("cities") else {
            return []
        }
        
        do {
            let json = try JSON(data: JSONData)
            let allCities = CityModel.getCitiesFromJson(json)
            var cities: [CityModel] = []
            for city in allCities {
                if city.parent! == 0 {
                    cities.append(city)
                }
            }
            return cities
        } catch {
            return []
        }
        
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CityChildrenVC.nameOfClass {
            let id = sender as! Int
            let cityChildrenVC = segue.destination as! CityChildrenVC
            cityChildrenVC.cityRootId = id
            cityChildrenVC.mode = self.mode
        }
    }
 

}


extension CityRootVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if mode == HomeVC.nameOfClass {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == HomeVC.nameOfClass {
            if section == 0 {
                return 1
            } else {
                return self.cityRoots.count
            }
        } else {
            return self.cityRoots.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if mode == HomeVC.nameOfClass {
            if indexPath.section == 0 {
                cell.textLabel?.text = "全部"
            } else {
                cell.textLabel?.text = cityRoots[indexPath.row].name
            }
        } else {
            cell.textLabel?.text = cityRoots[indexPath.row].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if mode == HomeVC.nameOfClass {
            if indexPath.section == 0 {
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.HOME_WHOLE_SELECT), object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                let cityRootId = self.cityRoots[indexPath.row].id!
                self.performSegue(withIdentifier: CityChildrenVC.nameOfClass, sender: cityRootId)
            }
            
        } else {
            let cityRootId = self.cityRoots[indexPath.row].id!
            self.performSegue(withIdentifier: CityChildrenVC.nameOfClass, sender: cityRootId)
        }
    }
}




extension CityRootVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}








