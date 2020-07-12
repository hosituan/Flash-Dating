//
//  AddressViewController.swift
//  Flash Dating
//
//  Created by Hồ Sĩ Tuấn on 7/12/20.
//  Copyright © 2020 Hồ Sĩ Tuấn. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddressViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let newPin = MKPointAnnotation()
    @IBOutlet var mkMapView: MKMapView!
    @IBOutlet var locationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        self.mkMapView.setRegion(region, animated: true)
        newPin.coordinate = location.coordinate
        mkMapView.addAnnotation(newPin)
    }



}
