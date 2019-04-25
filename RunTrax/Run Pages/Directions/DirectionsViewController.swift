//  SharedRunViewController.swift
//  RunTrax
//
//  Code to calculate the direction from the saved run data for the chosen run
//
//  Created by Kelsey Henrichsen on 1/24/19.
//  Copyright © 2019 Kelsey Henrichsen. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase


class DirectionsViewController: UIViewController {
    
    //Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var runDetails: UIButton!
    
    var routeSteps = [String]()
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var previousLocation: CLLocation?
    var ref = Database.database().reference()
    let geoCoder = CLGeocoder()
    var runKey : String?
    
    var directionsArray: [MKDirections] = []
    var coordinateArray = [CLLocationCoordinate2D]()
    var locationList = [CLLocation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        checkLocationServices()
        getRunInformation()
        
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //centers in on users current location
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //checks for the correctness of location
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
    
    //checks for the correctness of location
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            startTackingUserLocation()
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
    
    //starts tracking the users location
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
    //centers in on location
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //gets the run information from the database for chosen run
    func getRunInformation()
    {
        ref.child("runs/\(runKey!)").observe( .value, with: { (snapshot) in
            
            if let value = snapshot.value as? NSDictionary
            {
                if let location = value["location"] as? NSArray
                {
                    for index in 1 ..< location.count
                    {
                        let temp = location[index] as! [Double]
                        self.locationList.append(CLLocation(latitude: temp[0], longitude: temp[1]))
                        let coordinate = CLLocationCoordinate2DMake(temp[0], temp[1]);
                        self.coordinateArray.append(coordinate)
                        
                    }
                }
            }
            
            
        })
    }
    
    //adds the little start and finish marks
    func addAnnotations()
    {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = locationList.first!.coordinate
        startAnnotation.title = "Start"
        mapView.addAnnotation(startAnnotation)
        
        let finishAnnotation = MKPointAnnotation()
        finishAnnotation.coordinate = locationList.last!.coordinate
        finishAnnotation.title = "Finish!"
        
        mapView.addAnnotation(finishAnnotation)
    }
    
    //gets the directions from the run dictionary from the database
    func getDirections()
    {
        var test = 1
        
        //makes sure we have users location
        guard let location = locationManager.location
            else
        {
            //alerts the user if we don't have their location
            let alert = UIAlertController(title: "Location error",
                                          message: "We need your location to open run directions",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        
        //checks to make sure there are directions
        if locationList.count > 0
        {
            //checks if the user is close enough to begin run
            if location.distance(from: locationList[0]) < 1000
            {
                // starts going through the directions
                for coordinates in coordinateArray
                {
                    let request = createDirectionsRequest(from: coordinates)
                    let directions = MKDirections(request: request)
                    
                    resetMapView(withNew: directions)
                    directions.calculate { [unowned self] (response, error) in
                        
                        //checks that the directions are over or not, if they are over it stops reprinting the directions
                        if test == 1
                        {
                            if let response = response
                            {
                                for route in response.routes {
                                    self.mapView.addOverlay(route.polyline)
                                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                    for step in route.steps
                                    {
                                        let trash = step.instructions
                                        
                                        if trash != ""
                                        {
                                            self.routeSteps.append(step.instructions)
                                        }
                                        
                                    }
                                }
                                
                                test = 2
                            }
                        }
                    }
                    
                }
                
            }
            else
            {
                let alert = UIAlertController(title: "You are not at the starting location", message: "Please procede to the starting location)", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                self.present(alert, animated: true, completion: nil)
                
            }
            addAnnotations()
        }
    }
    
    
    
    //shows the tableview of directions
    @IBAction func detailsClicked(_ sender: Any) {
        let directions = storyboard?.instantiateViewController(withIdentifier: "DirectionsTableView") as! DirectionsTableViewController
        directions.directionsData = DirectionsDataSource(directions: routeSteps)
        //put on navstack and display
        let nav = self.navigationController
        
        self.navigationController?.pushViewController(directions, animated: true)
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .walking
        return request
    }
    
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    
    @IBAction func goButtonTapped(_ sender: Any) {
        //getRunInformation()
        getDirections()
    }
    
    
}


extension DirectionsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension DirectionsViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.black
        renderer.lineWidth = 5
        return renderer
    }
}
