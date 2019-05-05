
import UIKit

class MyStoreAddressVC: UIViewController {
    
    var senderVC = MyStoreStorePostVC.nameOfClass
    
    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: BMKMapView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var confirmButtonBg: GradientView!
    
    
    var locationService: BMKLocationService!
    var geocodeSearch: BMKGeoCodeSearch!
    var storeLocation: CLLocationCoordinate2D!
    var storeAnnotation: BMKPointAnnotation!
    var isSelectMyLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()
        self.setupTheme()
        
        locationService = BMKLocationService()
        geocodeSearch = BMKGeoCodeSearch()
    }
    
    private func setupTheme() {
        let selectedTheme = UserDefaultsUtil.shared.getSelectedTheme()
        confirmButtonBg.startColor = MainColors.themeStartColors[selectedTheme]
        confirmButtonBg.endColor = MainColors.themeEndColors[selectedTheme]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationService.delegate = self
        geocodeSearch.delegate = self
        mapView.viewWillAppear()
        mapView.delegate = self
        
        if self.storeLocation != nil {
            self.setupStoreMarker()
        } else {
            self.getUserLocation()
        }        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationService.delegate = nil
        geocodeSearch.delegate = nil
        mapView.viewWillDisappear()
        mapView.delegate = nil
        locationService.stopUserLocationService()
    }

    private func setupNavBar() {
        navBar.lblTitle.text = "地址定位中"
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
    }
    
    @IBAction func selectMyLocation(_ sender: UIButton) {
        self.isSelectMyLocation = true
        self.getUserLocation()
    }
    
    @IBAction func selectZoomIn(_ sender: UIButton) {
        mapView.zoomIn()
    }
    
    @IBAction func selectZoomOut(_ sender: UIButton) {
        mapView.zoomOut()
    }
    
    @IBAction func selectConfirm(_ sender: UIButton) {
        if self.storeLocation == nil {
            ProgressHUD.showWarningWithStatus("请选择位置!")
            return
        }
        confirmButton.isEnabled = false
        self.reverseGeoSearch(storeLocation)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // check location authorization state and start location service
    func getUserLocation() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            print("Authorized Always...")
            self.locationService.startUserLocationService()
        case .authorizedWhenInUse:
            print("Authorized When In Use...")
            self.locationService.startUserLocationService()
        case .denied:
            print("Denied...")
            self.presentAlert("尊敬的用户，请先开启您的定位", completion: {
                // Go to Settings...
                if let url = URL(string: "App-prefs:root=Privacy&path=LOCATION/" + Bundle.main.bundleIdentifier!) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
        case .notDetermined:
            print("Not Determined...")
        case .restricted:
            print("Restricted...")
        }
    }
    
    func setupStoreMarker() {
        if self.storeAnnotation != nil {
            self.mapView.removeAnnotation(storeAnnotation)
        }
        
        if storeLocation == nil {
            return
        }
        
        storeAnnotation = BMKPointAnnotation()
        storeAnnotation.coordinate = storeLocation
        storeAnnotation.title = "目标位置"
        
        mapView.addAnnotation(storeAnnotation)
        mapView.showAnnotations([storeAnnotation], animated: true)
        
    }
    
    private func reverseGeoSearch(_ location: CLLocationCoordinate2D) {
        let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
        reverseGeocodeSearchOption.reverseGeoPoint = location
        let flag = geocodeSearch.reverseGeoCode(reverseGeocodeSearchOption)
        if flag {
            print("反geo 检索发送成功")
        } else {
            print("反geo 检索发送失败")
            ProgressHUD.showErrorWithStatus("无法获取位置详细信息!  请稍后再试")
            confirmButton.isEnabled = true
        }
    }

}


extension MyStoreAddressVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    }
}


extension MyStoreAddressVC: BMKMapViewDelegate {
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let AnnotationViewID = "renameMark"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewID) as! BMKPinAnnotationView?
        if annotationView == nil {
            annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewID)
            annotationView?.pinColor = UInt(BMKPinAnnotationColorRed)
            annotationView?.animatesDrop = true
            annotationView?.isDraggable = false
            annotationView?.canShowCallout = true
        }
        annotationView?.annotation = annotation
        return annotationView
    }
    
    func mapView(_ mapView: BMKMapView!, onClickedMapBlank coordinate: CLLocationCoordinate2D) {
        self.storeLocation = coordinate
        self.setupStoreMarker()
    }
    
    func mapView(_ mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) {
        self.storeLocation = mapPoi.pt
        self.setupStoreMarker()
    }
    
}


extension MyStoreAddressVC: BMKLocationServiceDelegate {
    func didUpdate(_ userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        if isSelectMyLocation {
            self.storeLocation = userLocation.location.coordinate
            self.setupStoreMarker()
            mapView.showsUserLocation = true
            mapView.updateLocationData(userLocation)
            isSelectMyLocation = false
            return
        }
        if storeLocation != nil {
            return
        }
        if userLocation.location != nil {
            self.storeLocation = userLocation.location.coordinate
            self.setupStoreMarker()
        }
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        ProgressHUD.showErrorWithStatus("无法获得您的位置")
        if isSelectMyLocation {
            isSelectMyLocation = false
        }
    }
    
}


extension MyStoreAddressVC: BMKGeoCodeSearchDelegate {
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetReverseGeoCodeResult error: \(error)")
        self.confirmButton.isEnabled = true
        if error == BMK_SEARCH_NO_ERROR {
            print("onGetReverseGeoCodeResult Success...")
            let addressComponent = result.addressDetail!
            print("adCode", addressComponent.adCode)
            print("city", addressComponent.city)
            print("country", addressComponent.country)
            print("district", addressComponent.district)
            print("province", addressComponent.province)
            print("streetName", addressComponent.streetName)
            print("streetNumber", addressComponent.streetNumber)
            
            let address = result.address!
            self.presentAlert("成功获取位置信息", message: address, completion: {
                let info: [String : Any] = [
                    "address" : result,
                    "senderVC" : self.senderVC
                ]
                NotificationCenter.default.post(name: NSNotification.Name(Notifications.SELECT_ADDRESS), object: nil, userInfo: info)
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            ProgressHUD.showErrorWithStatus("未能获取位置详情!")
        }
        
    }
}

























