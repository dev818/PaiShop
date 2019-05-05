//
//  Nearby+Location.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation


extension NearbyVC {
    
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
    
}


extension NearbyVC: BMKLocationServiceDelegate {
    func willStartLocatingUser() {
        print("willStartLocatingUser...")
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if userLocation.location != nil {
            self.userLocationCoordinate = userLocation.location.coordinate
            print("didUpdateUserLocation lat:\(self.userLocationCoordinate.latitude) lon:\(self.userLocationCoordinate.longitude)")
        }
        
        locationService.stopUserLocationService()
        self.tableView.reloadData()
    }
    
    func didStopLocatingUser() {
        print("didStopLocatingUser...")
    }
    
    func didFailToLocateUserWithError(_ error: Error!) {
        print("didFailToLocateUserWithError...")
        //Set Default City and Get Data...
    }
}



/*extension NearbyVC: BMKMapViewDelegate {
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let AnnotationViewID = "renameMark"
        
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
    
    func mapView(_ mapView: BMKMapView!, didSelect view: BMKAnnotationView!) {
        
    }
}*/










