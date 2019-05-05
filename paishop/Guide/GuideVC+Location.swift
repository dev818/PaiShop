
import Foundation


extension GuideVC {
    
    // check location authorization state and start location service
    func getUserLocation() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways:
            print("Authorized Always...")
            self.locationService.startUserLocationService()
            self.mapView.showsUserLocation = true
            
        case .authorizedWhenInUse:
            print("Authorized When In Use...")
            self.locationService.startUserLocationService()
            self.mapView.showsUserLocation = true
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
    
    
    private func reverseGeoSearch(_ userLocation: CLLocationCoordinate2D) {
        let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
        reverseGeocodeSearchOption.reverseGeoPoint = userLocation
        let flag = geocodeSearch.reverseGeoCode(reverseGeocodeSearchOption)
        if flag {
            print("反geo 检索发送成功")
        } else {
            print("反geo 检索发送失败")
        }
    }
    
    func setupMarkers(_ userLoc: BMKUserLocation? = nil) {
        if storeAnnotations.count > 0 {
            self.mapView.removeAnnotations(storeAnnotations)
            self.storeAnnotations = []
        }
        
        if let userLocation = userLoc {
            self.searchBar.text = ""
            self.searchText = ""
            self.cityLabel.text = "请选择"
            
            let userAnnotation = BMKPointAnnotation()
            userAnnotation.coordinate = userLocation.location.coordinate
            userAnnotation.title = "我的位置"
            self.storeAnnotations.append(userAnnotation)
        }
        
        if self.mapStores.count < 1 {
            ProgressHUD.showWarningWithStatus("没有商店可供展示!")
            if userLoc == nil {
                return
            }
        }
        
        
        for i in 0..<(self.mapStores.count)  {
            let store = self.mapStores[i]
            let lat = store.lat
            let lon = store.lng
            if let latitude = lat, let longitude = lon {
                if latitude != 0.0 && longitude != 0.0 {
                    let storeCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let storeAnnotation = BMKPointAnnotation()
                    storeAnnotation.coordinate = storeCoordinate
                    storeAnnotation.title = "\(i)"
                    storeAnnotation.subtitle = "\(store.storeId!)"
                    self.storeAnnotations.append(storeAnnotation)
                }
            }
        }
        
        self.mapView.addAnnotations(self.storeAnnotations)
        
        if userLoc != nil && self.storeAnnotations.count > 1  {
            var annotations: [BMKPointAnnotation] = []
            for i in 1..<(self.storeAnnotations.count) {
                annotations.append(self.storeAnnotations[i])
            }
            self.showMarkersWithUserLocation(annotations, userLocation: userLoc!)
        } else {
            self.mapView.showAnnotations(self.storeAnnotations, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mapView.zoomLevel = self.mapView.zoomLevel - 0.2
        }
    }
    
    private func showMarkersWithUserLocation(_ annotations: [BMKPointAnnotation], userLocation: BMKUserLocation) {
        let centerCoordinate = userLocation.location.coordinate
        var maxLat = annotations.last!.coordinate.latitude
        var maxLon = annotations.last!.coordinate.longitude
        var minLat = annotations.last!.coordinate.latitude
        var minLon = annotations.last!.coordinate.longitude
        for annotation in annotations {
            let lat = annotation.coordinate.latitude
            let lon = annotation.coordinate.longitude
            if lat < minLat {
                minLat = lat
            }
            if lat > maxLat {
                maxLat = lat
            }
            if lon < minLon {
                minLon = lon
            }
            if lon > maxLon {
                maxLon = lon
            }
        }
        
        let maxLatDis = abs(centerCoordinate.latitude - maxLat)
        let minLatDis = abs(centerCoordinate.latitude - minLat)
        let maxLonDis = abs(centerCoordinate.longitude - maxLon)
        let minLonDis = abs(centerCoordinate.longitude - minLon)
        if maxLatDis < minLatDis {
            maxLat = minLat
        }
        if maxLonDis < minLonDis {
            maxLon = minLon
        }
        
        var spanLat = centerCoordinate.latitude
        var spanLon = centerCoordinate.longitude
        if centerCoordinate.latitude < maxLat {
            spanLat = 2 * (maxLat - centerCoordinate.latitude)
        } else {
            spanLat = 2 * (centerCoordinate.latitude - maxLat)
        }
        if centerCoordinate.longitude < maxLon {
            spanLon = 2 * (maxLon - centerCoordinate.longitude)
        } else {
            spanLon = 2 * (centerCoordinate.longitude - maxLon)
        }
        
        let span = BMKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        let region = BMKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: true)        
    }
    
}

extension GuideVC: BMKLocationServiceDelegate {
    func willStartLocatingUser() {
        print("willStartLocatingUser...")
    }
    
    func didUpdateUserHeading(_ userLocation: BMKUserLocation!) {
        //print("heading is \(userLocation.heading)")
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if userLocation.location != nil {
            self.userLocationCoordinate = userLocation.location.coordinate
            print("didUpdateUserLocation lat:\(self.userLocationCoordinate.latitude) lon:\(self.userLocationCoordinate.longitude)")
            reverseGeoSearch(self.userLocationCoordinate)
            self.tableView.ts_reloadData { } // update tableview for displaying distance
            
            self.mapView.setCenter(self.userLocationCoordinate, animated: true)
            self.mapView.updateLocationData(userLocation)
            
            if !isCalledCity {
                var parameters: [String :Any] = [
                    "lng": self.userLocationCoordinate.longitude,
                    "lat": self.userLocationCoordinate.latitude,
                    "radius": 8000000
                ]
                if self.isSelectedMyLocation {
                    parameters["radius"] = 20000
                }
                GuideAPI.shared.storeLocation(params: parameters) { (json, success) in
                    if success {
                        print("Store Location...")
                        print(json)
                        self.mapStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                        self.setupMarkers(userLocation)
                    } else {
                        // try again...
                        GuideAPI.shared.storeLocation(params: parameters, completion: { (json, success1) in
                            if success1 {
                                self.mapStores = StoreDetailModel.getStoreDetailsFromJson(json["stores"])
                                self.setupMarkers(userLocation)
                            }
                        })
                    }
                }
            }
            
        }
        
        locationService.stopUserLocationService()
    }
    
    func didStopLocatingUser() {
        print("didStopLocatingUser...")
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        print("Fail User Locating...")
    }
}


extension GuideVC: BMKGeoCodeSearchDelegate {
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetReverseGeoCodeResult error: \(error)")
        
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
            let streetName = addressComponent.streetName!
            let streetNumber = addressComponent.streetNumber!
            let message = address + ":" + streetName + ":" + streetNumber
            let alertView = UIAlertController(title: "反向地理编码", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertView.addAction(okAction)
            //self.present(alertView, animated: true, completion: nil)
            //cityLabel.text = addressComponent.city
        }
        
    }
}


extension GuideVC: BMKMapViewDelegate {
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        let AnnotationViewID = "renameMark"
        let UserAnnotationViewID = "uesrMark"
        
        if annotation.title!() == "我的位置" {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: UserAnnotationViewID) as! BMKPinAnnotationView?
            annotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: UserAnnotationViewID)
            annotationView?.animatesDrop = true
            annotationView?.isDraggable = false
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "my_location_pin.png")
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
        /*let subtitle = view.annotation.subtitle!()
        if let storeId = subtitle {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                mapView.deselectAnnotation(view.annotation, animated: true)
                self.isSelectedCityView = true
                let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: HomeStoreDetailVC.nameOfClass) as! HomeStoreDetailVC
                vc.storeId = Int64(storeId)
                self.pushAndHideTabbar(vc)
            })
        }*/
        let title = view.annotation.title!()
        if let indexString = title, let index = Int(indexString) {
            //show custom store view...
            if index > self.mapStores.count - 1 {
                return
            }
            let store = self.mapStores[index]
            self.selectedStoreId = store.storeId!
            self.selectedStore = store
            self.setUpStoreViewFields(store)
            mapView.deselectAnnotation(view.annotation, animated: true)
            self.customStoreView.snp.updateConstraints({ (make) in
                make.centerY.equalTo(self.view.centerY)
            })
            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            self.showDarkView(true)
        }
        
    }
    
    func setUpStoreViewFields(_ store: StoreDetailModel) {
        storeNameLabel.text = store.name
        let resizedUrl = Utils.getResizedImageUrlString(store.image!, width: "200")
        storeImageView.setImageWithURLString(resizedUrl, placeholderImage: ImageAsset.icon_store.image)
        storeDescriptionTextView.text = store.introduction
        
        let degreeImages = UserDefaultsUtil.shared.getDegreeImageArray()
        degreeImageView.isHidden = true
        if let user = store.user, let degreeId = user.degreeId {
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
            let distanceInKilo = Utils.distanceFromLatLon(lat1: (store.lat)!, lon1: (store.lng)!, lat2: userLocationCoordinate.latitude, lon2: userLocationCoordinate.longitude, unit: "K")
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
















