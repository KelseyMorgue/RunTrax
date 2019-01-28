//
//  SharedRunViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 1/24/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class SharedRunViewController: UIViewController {
    //Properties
    @IBOutlet var mapView: MKMapView!

let locationManager = CLLocationManager()
let regionInMeters: Double = 500

override func viewDidLoad() {
    super.viewDidLoad()
    checkLocationServices()
}


func setupLocationManager() {
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
}


func centerViewOnUserLocation() {
    if let location = locationManager.location?.coordinate {
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
}


func checkLocationServices() {
    if CLLocationManager.locationServicesEnabled() {
        setupLocationManager()
        checkLocationAuthorization()
    } else {
        // Show alert letting the user know they have to turn this on.
    }
}


func checkLocationAuthorization() {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedWhenInUse:
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        break
    case .denied:
        // Show alert instructing them how to turn on permissions
        break
    case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
    case .restricted:
        // Show an alert letting them know what's up
        break
    case .authorizedAlways:
        break
    }
}
func getLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10 //good balance so less zigzags)
        locationManager.startUpdatingLocation()

    
    }
}


extension SharedRunViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // NOTE guard makes it so it has to "pass" before continuing to whatever is below it
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension SharedRunViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
    }
}
