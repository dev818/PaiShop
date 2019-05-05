
import UIKit
import MapKit
import XLActionController

class GuideMapVC: UIViewController {
    
    var markerName: String = ""
    var markerLat: Double!
    var markerLon: Double!
    var makerDescription: String!
    var storeImage: String!
    var degree: Int?
        
    var storeId: Int64!
    var isFromStoreDetail = false

    @IBOutlet weak var navBar: NavBar!
    @IBOutlet weak var mapView: BMKMapView!
    @IBOutlet weak var myLocationImageView: UIImageView!
    @IBOutlet weak var zoomInImageView: UIImageView!
    @IBOutlet weak var zoomOutImageView: UIImageView!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navStoreNameLabel: UILabel!
    
    
    @IBOutlet weak var darkView: UIView! {
        didSet {
            darkView.isHidden = true
        }
    }
    @IBOutlet var customStoreView: UIView!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeDistanceNameTitle: UILabel!
    @IBOutlet weak var storeDistanceLabel: UILabel!
    @IBOutlet weak var storeDescriptionTextView: UITextView!
    @IBOutlet weak var degreeImageView: RoundImageView!
    
    
    var locationService: BMKLocationService!
    var userLocationCoordinate: CLLocationCoordinate2D!
    var userAnnotation: BMKPointAnnotation!
    
    var storeAnnotation: BMKPointAnnotation!
    var isSelectMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Nav bar set up
        navBar.lblTitle.text = self.markerName
        navBar.delegate = self
        if Utils.isIphoneX() {
            navBarHeightConstraint.constant = 88
        }
        
        locationService = BMKLocationService()
        //locationService.allowsBackgroundLocationUpdates = true
        
        userAnnotation = BMKPointAnnotation()
        
        self.setupMapButtons()
        self.setupUI()
        setupCustomView()
        
        self.trackUserLocation()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationService.delegate = self
        mapView.viewWillAppear()
        mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationService.delegate = nil
        mapView.viewWillDisappear()
        mapView.delegate = nil
    }
    
    private func setupUI() {
        if self.markerLat == 0 && self.markerLon == 0 {
            self.presentAlert("无法获取您的位置详细信息", completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            })
        } else {
            let coordinate = CLLocationCoordinate2D(latitude: self.markerLat, longitude: self.markerLon)
            mapView.setCenter(coordinate, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.storeAnnotation = BMKPointAnnotation()
                self.storeAnnotation.coordinate = coordinate
                self.storeAnnotation.title = self.markerName
                self.mapView.addAnnotation(self.storeAnnotation)
                self.mapView.showAnnotations([self.storeAnnotation], animated: true)
            })
        }
        
        navStoreNameLabel.text = self.markerName
    }
    
    private func setupCustomView() {
        self.view.addSubview(customStoreView)
        customStoreView.translatesAutoresizingMaskIntoConstraints = false
        customStoreView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.centerX)
            make.height.equalTo(295)
            make.width.equalTo(280)
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
    }
    
    
    private func setUserMarker() {
        self.mapView.removeAnnotation(userAnnotation)
        userAnnotation.coordinate = self.userLocationCoordinate
        userAnnotation.title = "我的位置"
        self.mapView.addAnnotation(userAnnotation)
        /*if storeAnnotation != nil {
            self.mapView.showAnnotations([userAnnotation, storeAnnotation], animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.mapView.zoomLevel = self.mapView.zoomLevel - 0.2
            })
        } else {
            self.mapView.showAnnotations([userAnnotation], animated: true)
        }*/
        if storeAnnotation != nil {
            let centerCoordinate = userAnnotation.coordinate
            let storeCoordinate = storeAnnotation.coordinate
            
            var spanLat = centerCoordinate.latitude
            var spanLon = centerCoordinate.longitude
            
            if centerCoordinate.latitude < storeCoordinate.latitude {
                spanLat = 2 * (storeCoordinate.latitude - centerCoordinate.latitude)
            } else {
                spanLat = 2 * (centerCoordinate.latitude - storeCoordinate.latitude)
            }
            
            if centerCoordinate.longitude < storeCoordinate.longitude {
                spanLon = 2 * (storeCoordinate.longitude - centerCoordinate.longitude)
            } else {
                spanLon = 2 * (centerCoordinate.longitude - storeCoordinate.longitude)
            }
            
            let span = BMKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
            let region = BMKCoordinateRegion(center: centerCoordinate, span: span)
            
            self.mapView.setRegion(region, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.mapView.zoomLevel = self.mapView.zoomLevel - 0.2
            })
        }
        
    }
    
    private func setupMapButtons() {
        myLocationImageView.isUserInteractionEnabled = true
        let myLocationTap = UITapGestureRecognizer(target: self, action: #selector(selectMyLocation(_:)))
        myLocationImageView.addGestureRecognizer(myLocationTap)
        
        zoomInImageView.isUserInteractionEnabled = true
        let zoomInTap = UITapGestureRecognizer(target: self, action: #selector(selectZoomIn(_:)))
        zoomInImageView.addGestureRecognizer(zoomInTap)
        
        zoomOutImageView.isUserInteractionEnabled = true
        let zoomOutTap = UITapGestureRecognizer(target: self, action: #selector(selectZoomOut(_:)))
        zoomOutImageView.addGestureRecognizer(zoomOutTap)
    }

    
    @IBAction func selectNavigation(_ sender: UIButton) {
        if self.userLocationCoordinate == nil {
            ProgressHUD.showWarningWithStatus("无法获得您的位置!")
            return
        }
        
        let actionController = PeriscopeActionController()
        actionController.addAction(Action.init("通过苹果地图导航", style: .default, handler: { (action) in
            let coordinate = CLLocationCoordinate2D(latitude: self.markerLat, longitude: self.markerLon)
            let regionDistance: CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue.init(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue.init(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.markerName
            mapItem.openInMaps(launchOptions: options)
        }))
        actionController.addAction(Action.init("通过百度地图导航", style: .default, handler: { (action) in
            let urlString = String.init(format: "baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&rc=cab", self.userLocationCoordinate.latitude, self.userLocationCoordinate.longitude, self.markerLat, self.markerLon)
            //let urlString = String.init(format: "baidumap://map/direction?origin=%f,%f&destination=latlng:%f,%f|name=target&mode=driving", self.userLocationCoordinate.latitude, self.userLocationCoordinate.longitude, self.markerLat, self.markerLon)
            let url = URL.init(string: urlString)
            if url != nil {
                print("URL...", url!)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    ProgressHUD.showWarningWithStatus("请安装百度地图应用程序!")
                }
            }
        }))
        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action("取消", style: .cancel, handler:nil))
        
        
        self.present(actionController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func selectMyLocation(_ sender: Any) {
        applyTouchEffect(myLocationImageView)
        
        self.isSelectMyLocation = true
        self.trackUserLocation()
    }
    
    @objc func selectZoomIn(_ sender: Any) {
        applyTouchEffect(zoomInImageView)
        mapView.zoomIn()
    }
    
    @objc func selectZoomOut(_ sender: Any) {
        applyTouchEffect(zoomOutImageView)
        mapView.zoomOut()
    }
    
    private func applyTouchEffect(_ target: UIView) {
        target.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            target.alpha = 1.0
        }
    }
    
    private func trackUserLocation() {
        locationService.startUserLocationService()
        mapView.showsUserLocation = false
        mapView.userTrackingMode = BMKUserTrackingModeNone
        mapView.showsUserLocation = true
    }
    
    
    @IBAction func closeCustomView(_ sender: UIButton) {
        self.hideCustomStoreView()
    }
    
    @IBAction func selectToStore(_ sender: UIButton) {
        self.hideCustomStoreView()
        // go to Store Detail Page...
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
        vc.storeId = self.storeId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showDarkView(_ state: Bool) {
        if state {
            self.darkView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.8
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { (finished) in
                self.darkView.isHidden = true
            })
        }
    }
    
    func hideCustomStoreView() {
        customStoreView.snp.updateConstraints { (make) in
            if Utils.isIpad() {
                make.centerY.equalTo(self.view.centerY).offset(2000)
            } else {
                make.centerY.equalTo(self.view.centerY).offset(1000)
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(false)
    }
    
    

}


extension GuideMapVC: BMKMapViewDelegate {
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        let AnnotationViewID = "renameMark"
        let UserAnnotationViewID = "userMark"
        
        if annotation.title!() == "我的位置" {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: UserAnnotationViewID) as! BMKPinAnnotationView?
            if annotationView == nil {
                annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: UserAnnotationViewID)
                annotationView?.image = ImageAsset.my_location_pin.image
                annotationView?.animatesDrop = true
                annotationView?.isDraggable = false
                annotationView?.canShowCallout = true
            }
            annotationView?.annotation = annotation
            return annotationView
        } else {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationViewID) as! BMKPinAnnotationView?
            if annotationView == nil {
                annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: AnnotationViewID)
                annotationView?.pinColor = UInt(BMKPinAnnotationColorRed)
                annotationView?.animatesDrop = true
                annotationView?.isDraggable = false
                annotationView?.canShowCallout = false
            }
            annotationView?.annotation = annotation
            return annotationView
        }
    }
    
    func mapView(_ mapView: BMKMapView!, didSelect view: BMKAnnotationView!) {
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if view.annotation.title!() == "我的位置" {
            return
        }
        
        self.setUpStoreViewFields()
        self.customStoreView.snp.updateConstraints({ (make) in
            make.centerY.equalTo(self.view.centerY)
        })
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        self.showDarkView(true)
        
    }
    
    func setUpStoreViewFields() {
        storeNameLabel.text = self.markerName
        let resizedUrl = Utils.getResizedImageUrlString(self.storeImage, width: "200")
        storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        storeDescriptionTextView.text = self.makerDescription
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        degreeImageView.isHidden = true
        if let degreeId = self.degree {
            if degreeImages.count > 0 && degreeId > 0 {
                if degreeImages.count >= degreeId {
                    degreeImageView.isHidden = false
                    degreeImageView.setImageWithURLString(degreeImages[degreeId - 1])
                }
            }
        }        
        
        if self.userLocationCoordinate != nil {
            storeDistanceLabel.isHidden = false
            storeDistanceNameTitle.isHidden = false
            let distanceInKilo = Utils.distanceFromLatLon(lat1: markerLat, lon1: markerLon, lat2: userLocationCoordinate.latitude, lon2: userLocationCoordinate.longitude, unit: "K")
            if distanceInKilo >= 10 {
                storeDistanceLabel.text = "\(Int(distanceInKilo))km"
            } else {
                storeDistanceLabel.text = "\(Int(distanceInKilo * 1000))m"
            }
        } else {
            storeDistanceLabel.isHidden = true
            storeDistanceNameTitle.isHidden = true
        }
        
    }
    
    
}



extension GuideMapVC: BMKLocationServiceDelegate {
    func willStartLocatingUser() {
        print("GuideMapVC willStartLocatingUser...")
    }
    
    func didUpdateUserHeading(_ userLocation: BMKUserLocation!) {
        mapView.updateLocationData(userLocation)
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if userLocation.location != nil {
            self.userLocationCoordinate = userLocation.location.coordinate
            //self.mapView.setCenter(self.userLocationCoordinate, animated: true)
            self.mapView.updateLocationData(userLocation)
            self.locationService.stopUserLocationService()
            if self.isSelectMyLocation {
                self.setUserMarker()
            }
            
            print("Map State Changed...", mapView.centerCoordinate)
            let center = mapView.region.center
            let span = mapView.region.span
            print("Center.......", center)
            print("Span.........", span)
        }
    }
}



extension GuideMapVC: NavBarDelegate {
    func didSelectBack() {
        self.navigationController?.popViewController(animated: true)
    } 
}























