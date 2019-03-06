//
//  NewRunViewController.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 1/22/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.

import Foundation
import UIKit
import MapKit
import CoreLocation

class NewRunViewController: UIViewController, UITextFieldDelegate
{
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    //variables
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var run: Run?
    var seconds = 0
    var timer: Timer?
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var locationList: [CLLocation] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
     func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        
        distanceLabel.text = "Distance: \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
        paceLabel.text = "Pace: \(formattedPace)"
    }
    
   

    //KELSEY NOTE: I think I should have the locked screen only on this function
     func startRun() {
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        
    }
    
     func stopRun() {
      
        locationManager.stopUpdatingLocation()
    }
    
    
    @IBAction func startTapped(_ sender: UIButton) {
        
        startRun()
    }
   
    @IBAction func stopTapped(_ sender: Any) {
        
        stopRun()
    }
    
    
    
    
    //make it save to database for saved runs
    private func saveRun() {
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            //newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        run = newRun
    }
    
    
//    @IBAction func startTapped() {
//        startRun()
//    }
//
//    @IBAction func stopTapped() {
//        //NOTE need to add to stop button before the run complete to save, then in the final screen allow sharing
//        let alertController = UIAlertController(title: "Run Completed",
//                                                message: "Would you like to save or discard your run?",
//                                                preferredStyle: .actionSheet)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
//            self.stopRun()
//            self.saveRun()
//        })
//
//        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
//            self.stopRun()
//            _ = self.navigationController?.popToRootViewController(animated: true)
//        })
//
//        present(alertController, animated: true)
//
//    }
     func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
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

extension NewRunViewController: CLLocationManagerDelegate {
    //review l8r
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
                let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                mapView.setRegion(region, animated: true)
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }

            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }

            locationList.append(newLocation)
        }
}
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        // NOTE guard makes it so it has to "pass" before continuing to whatever is below it
//        guard let location = locations.last else { return }
//        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
//    }
//
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}



//adds line
extension NewRunViewController: MKMapViewDelegate {
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





//What to do in this view controller:
//  -Have distance, time, and pace update and displayed
//  -Show map with current path (?? need to look up)
//  -When end button is clicked:
//      *Have save/delete option pop up
//      *If run is saved, push to next screen (sharing run options, and totals)
//      *If run is deleted, return to home screen
