//
//  NearbyTopCell.swift
//  paishop
//
//  Created by SeniorCorder on 6/14/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NearbyTopCell: UITableViewCell {
    
    @IBOutlet weak var loadStoreBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.ts_registerCellNib(NearbyBottomCollectionCell.self)
        }
    }
    
    @IBOutlet weak var noDataView: UIView! {
        didSet {
            noDataView.isHidden = true
        }
    }
    @IBOutlet weak var mapView: BMKMapView!
    @IBOutlet weak var mapFrame: UIView! {
        didSet {
            mapFrame.isHidden = true
        }
    }
    
    
    
    var parentVC: NearbyVC!
    var storeList: [StoreDetailModel] = []
    var storeAnnotations: [BMKPointAnnotation] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mapView.viewWillAppear()
        mapView.delegate = self
    }

    func setCellContent(_ vc: NearbyVC, storeList: [StoreDetailModel]) {
        self.parentVC = vc
        self.storeList = storeList
        self.collectionView.reloadData()
        
        if storeList.count > 0 {
            noDataView.isHidden = true
        } else {
            noDataView.isHidden = false
        }
        
        
        setupMarkers(storeList)
        
        if parentVC.isDisplayModeMap {
            mapFrame.isHidden = false
        } else {
            mapFrame.isHidden = true
        }
        
    }
    
    @IBAction func selectZoomIn(_ sender: Any) {
        mapView.zoomIn()
    }
    
    //select zoom out button
    @IBAction func selectZoomOut(_ sender: Any) {
        mapView.zoomOut()
    }
    
    @IBAction func selectMyLocation(_ sender: Any) {
        parentVC.isSelectedUserLocation = true
        parentVC.getUserLocation()
    }
    
    func setupMarkers(_ storeList: [StoreDetailModel]) {
        if storeAnnotations.count > 0 {
            self.mapView.removeAnnotations(storeAnnotations)
            self.storeAnnotations = []
        }
        
        if parentVC.isSelectedUserLocation && parentVC.userLocationCoordinate != nil {
            parentVC.isSelectedUserLocation = false
            let userAnnotation = BMKPointAnnotation()
            userAnnotation.coordinate = parentVC.userLocationCoordinate
            userAnnotation.title = "我的位置"
            self.storeAnnotations.append(userAnnotation)
        }
        
        if storeList.count < 1 {
            ProgressHUD.showWarningWithStatus("没有商店可供展示!")
            return
        }
        
        
        
        for i in 0..<storeList.count {
            let store = storeList[i]
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
        if parentVC.isSelectedUserLocation && parentVC.userLocationCoordinate != nil {
            self.showMarkersWithUserLocation(self.storeAnnotations, userLocation: parentVC.userLocationCoordinate)
        } else {
            self.mapView.showAnnotations(self.storeAnnotations, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.mapView.zoomLevel = self.mapView.zoomLevel - 0.2
        }
        
    }
    
    
    private func showMarkersWithUserLocation(_ annotations: [BMKPointAnnotation], userLocation: CLLocationCoordinate2D) {
        let centerCoordinate = userLocation
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


extension NearbyTopCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NearbyBottomCollectionCell = collectionView.ts_dequeueReusableCell(NearbyBottomCollectionCell.self, forIndexPath: indexPath)
        cell.setCellContent(storeList[indexPath.item], userLocation: parentVC.userLocationCoordinate)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height*9/7, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let store = storeList[indexPath.item]
        parentVC.selectedStoreId = store.storeId!
        parentVC.loadStoreItems(store.storeId!, resetData: true)
    }
    
}




extension NearbyTopCell: BMKMapViewDelegate {
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
        let subTitle = view.annotation.subtitle!()
        if let index = subTitle, let storeId = Int64(index) {
            parentVC.selectedStoreId = storeId
            parentVC.loadStoreItems(storeId, resetData: true)
        }
        
    }
}








