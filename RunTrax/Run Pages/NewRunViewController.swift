//  NewRunViewController.swift
//  RunTrax
//
//  Page to start a new run
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
    let regionInMeters: Double = 500
    var run: Run?
    var seconds = 0
    var timer: Timer?
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var locationList: [CLLocation] = []
    let temp = CLLocation()
    var runDictionary : [String : [Double]] = [:]
    var sendKey : String?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    
    
    var handle : AuthStateDidChangeListenerHandle!
    var currentUser : User!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newRun = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
            self.currentUser = Auth.auth().currentUser
        }
    }
    
    //makes it so the tracking works even if app is in background while running
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    //ends the background tasks
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    //updates seconds and calls updateDisplay()
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    
    //takes the run information and displays the current information on the screen and constantly updates until endRun() is called
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
    
    
    //starts tracking the run
    func startRun() {
        registerBackgroundTask()
        
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
        
    }
    
    //stops tracking the run
    func stopRun() {
        endBackgroundTask()
        locationManager.stopUpdatingLocation()
    }
    
    //button
    @IBAction func startTapped(_ sender: UIButton) {
        
        startRun()
    }
    
    //button
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
        
        
        
    }
    
    //opens the next screen
    func openOverview()
    {
        let nav = self.storyboard!.instantiateViewController(withIdentifier: "RunOverview") as! RunOverviewViewController
        nav.runKey = sendKey
        self.present(nav,animated: true, completion: nil)
    }
    
    //opens the main screen
    func returnToMain()
    {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
    }
    
    //saves the run information into the database
    func saveRun()
    {
        
        
        let key = newRun.child("runs").childByAutoId().key
        
        self.sendKey = key
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let date = Date()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        
        //had to save the locations as a dictionary so firebase would save the info
        let run = [
            "id" : key as Any,
            "userId" : currentUser?.uid as Any,
            "mileage" : FormatDisplay.distance(distance),
            "pace" : FormatDisplay.pace(distance: distance,seconds: seconds, outputUnit: UnitSpeed.minutesPerMile),
            "date" : dateFormatter.string(from: date),
            "time" : FormatDisplay.time(seconds),
            "location" : runDictionary
        ]
        
        let updateRun = ["/\(key!)" : run]
        let updateUser = ["/\(currentUser!.uid)/runs/\(key!)" : run]
        
        newRun.child("users").updateChildValues(updateUser) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
        
        newRun.child("runs").updateChildValues(updateRun) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
        
    }
    
    //starts getting location updates
    func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //keeps the user's location as the center
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //makes sure location services are correctly on
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
    
    
    //again, checks correctness of location
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            let alert = UIAlertController(title: "Location Services Must Be Turned On",
                                          message: "Go to settings to turn on location",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            let alert = UIAlertController(title: "Location Services Must Be Turned On",
                                          message: "Go to settings to turn on location",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
        case .authorizedWhenInUse:
            let alert = UIAlertController(title: "Location Services must be available always",
                                          message: "This way we can track your run even when your screen is locked",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
}

//adds directions to the dictionary
extension NewRunViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let index = String(locationList.count)
        
        
        
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                let lat = Double(lastLocation.coordinate.latitude)
                let long = Double(lastLocation.coordinate.longitude)
                runDictionary.updateValue([lat, long], forKey: index)
                
                
            }
            
            locationList.append(newLocation)
            
        }
        
        
    }
    
    
    
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
