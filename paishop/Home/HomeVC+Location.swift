

import Foundation


/*
 extension HomeVC {
    
    
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
    
    private func reverseGeoSearch(_ userLocation: CLLocationCoordinate2D) {
        let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
        reverseGeocodeSearchOption.reverseGeoPoint = userLocation
        let flag = geocodeSearch.reverseGeoCode(reverseGeocodeSearchOption)
        if flag {
            //print("Reverse Geocode Search sent successfully")
        } else {
            print("Reverse Geocode Search sent failed...")
            //Set Default City and Get Data...
        }
    }
    
}


extension HomeVC: BMKLocationServiceDelegate {
    func willStartLocatingUser() {
        print("willStartLocatingUser...")
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if userLocation.location != nil {
            self.userLocationCoordinate = userLocation.location.coordinate
            print("didUpdateUserLocation lat:\(self.userLocationCoordinate.latitude) lon:\(self.userLocationCoordinate.longitude)")
            reverseGeoSearch(self.userLocationCoordinate)
        }
        
        locationService.stopUserLocationService()
    }
    
    func didStopLocatingUser() {
        print("didStopLocatingUser...")
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        print("didFailToLocateUserWithError...")
        //Set Default City and Get Data...
    }
}


extension HomeVC: BMKGeoCodeSearchDelegate {
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
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
            //self.locationLabel.text = addressComponent.city
        } else {
            print("onGetReverseGeoCodeResult Failed...")
            //Set Default City and Get Data...
        }
    }
}
*/





