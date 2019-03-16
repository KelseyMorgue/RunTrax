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
import Firebase

class NewRunViewController: UIViewController, UITextFieldDelegate
{
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    
    var newRun = Database.database().reference()
    
    //variables
    let locationManager = CLLocationManager()
    //let currentUser :
    let regionInMeters: Double = 500
    var run: Run?
    var seconds = 0
    var timer: Timer?
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var locationList: [CLLocation] = []
    var handle : AuthStateDidChangeListenerHandle!
    var currentUser : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.newRun = Database.database().reference()//.child("run")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
         
            self.currentUser = Auth.auth().currentUser            // ...
        }
    }
    
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        let formattedSpeed = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: UnitSpeed.milesPerHour)
        
        distanceLabel.text = "Distance: \(formattedDistance)"
        timeLabel.text = "Time: \(formattedTime)"
        paceLabel.text = "Pace: \(formattedPace)"
        speedLabel.text = "Speed:  \(formattedSpeed)"
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
        let alert = UIAlertController(title: "Ending Run",
                                      message: "Would you like to save your run?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete: will return to main screen", style: .cancel, handler:
            {
                action in
                self.returnToMain()
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            self.saveRun()
            self.openOverview()
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
        /*
         let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
         self.present(nav,animated: true, completion: nil)
 */
    }
    
    func openOverview()
    {
        let nav = self.storyboard!.instantiateViewController(withIdentifier: "RunOverview")
        self.present(nav,animated: true, completion: nil)
    }
    
    func returnToMain()
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
    }
    
    
    //make it save to database for saved runs
    //    private func saveRun() {
    ////        let newRun = Run(context: CoreDataStack.context)
    ////        newRun.distance = distance.value
    ////        newRun.duration = Int16(seconds)
    ////        newRun.timestamp = Date()
    ////
    ////        for location in locationList {
    ////            let locationObject = Location(context: CoreDataStack.context)
    ////            locationObject.timestamp = location.timestamp
    ////            locationObject.latitude = location.coordinate.latitude
    ////            locationObject.longitude = location.coordinate.longitude
    ////            //newRun.addToLocations(locationObject)
    ////        }
    ////
    ////        CoreDataStack.saveContext()
    ////
    ////        run = newRun
    //    }
    /*
     let locationManager = CLLocationManager()
     let regionInMeters: Double = 500
     var run: Run?
     var seconds = 0
     var timer: Timer?
     var distance = Measurement(value: 0, unit: UnitLength.meters)
     var locationList: [CLLocation] = []
     */
    
    func saveRun()
    {
        //let currentUser = Auth.auth().currentUser
        let key = newRun.child("run").childByAutoId().key
        
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "mm dd yyyy"
        let result = df.string(from: date)
        
        var testy : Dictionary<String,Any> = Dictionary<String,Any>()
        testy["id"] = key
        testy["userId"] = currentUser?.uid as Any
        testy["mileage"] = FormatDisplay.distance(distance)
        testy["pace"] = FormatDisplay.pace(distance: distance,seconds: seconds, outputUnit: UnitSpeed.minutesPerMile)
        testy["date"] = result
        testy["time"] = FormatDisplay.time(seconds)
        testy["location"] = locationList
        
    
        
        let run = [
            "id" : key as Any,
              "userId" : currentUser?.uid as Any,  //need foreign for user key
                "mileage" : FormatDisplay.distance(distance),
                "pace" : FormatDisplay.pace(distance: distance,seconds: seconds, outputUnit: UnitSpeed.minutesPerMile),
                "date" : result,
               // "name" : "",
                "time" : FormatDisplay.time(seconds),
                "location" : locationList
                ] as [String : Any]
        
        
       // let userDbRef =  newRun.child("users").child(currentUser!.uid)
        newRun.child("run").setValue(testy)
        
    }
    
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
            let alert = UIAlertController(title: "Location Services Must Be Turned On",
                                          message: "Go to settings to turn on location",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            let alert = UIAlertController(title: "Location Services Must Be Turned On",
                                          message: "Go to settings to turn on location",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let alert = UIAlertController(title: "Location Services Must Be Turned On",
                                          message: "Go to settings to turn on location",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways:
            break
        }
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
