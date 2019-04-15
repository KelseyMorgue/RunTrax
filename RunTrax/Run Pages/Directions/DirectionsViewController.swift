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
import Firebase


class DirectionsViewController: UIViewController {
    
    //Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
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
    
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        //previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getRunInformation()
    {
        print(runKey, "this is the runkey")
            ref.child("runs/\(runKey!)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary
            {
                if let location = value["location"] as? NSArray
                {
                //            let count = location!.count
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
    
    func addAnnotations()
    {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = locationList.first!.coordinate
        startAnnotation.title = "Start"
        mapView.addAnnotation(startAnnotation)
        
        let finishAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = locationList.last!.coordinate
        startAnnotation.title = "Finish!"
        
        print(startAnnotation.coordinate, "idk i guess")
        mapView.addAnnotation(finishAnnotation)
    }

    //TODO: Change to get the directions from a queried run (from runkey)
    func getDirections()
    {
        
        //makes sure we have users location
        //let coordinates = locationManager.location!.coordinate
        guard let location = locationManager.location
            else
        {
            //TODO: Inform user we don't have their current location
            return
        }
        
       // let check = location.distance(from: locationList[0])
        //start run
        
        if locationList.count > 0
        {
            if location.distance(from: locationList[0]) < 100
            {
                for coordinates in coordinateArray
                {
                    let request = createDirectionsRequest(from: coordinates)
                    let directions = MKDirections(request: request)
                    
                    resetMapView(withNew: directions)
                    directions.calculate { [unowned self] (response, error) in
                        //TODO: Handle error if needed
                        if let response = response
                        {
                            for route in response.routes {
                                self.mapView.addOverlay(route.polyline)
                                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                
                                
                                //here for direction steps
                                for step in route.steps
                                {
                                    self.routeSteps.append(step.instructions)
                                    print(step.instructions)
                                    
                                }
                            }
                        }
                    }
                   
                    
                    
                }
                
                        }
            else
            {
                print("in the else")
                
                let alert = UIAlertController(title: "You are not at the starting location", message: "Please procede to the starting location \(self.locationList.first!.coordinate)", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
                self.present(alert, animated: true, completion: nil)
                
                
//
            }
            addAnnotations()

            
        }
            
        
    
        
        
    }
    
    
    
    
    @IBAction func detailsClicked(_ sender: Any) {
        let directions = storyboard?.instantiateViewController(withIdentifier: "DirectionsTableView") as! DirectionsTableViewController
        directions.directionsList = self.routeSteps
        //put on navstack and display
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
        //        request.requestsAlternateRoutes = true
        
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
    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let center = getCenterLocation(for: mapView)
//
//        guard let previousLocation = self.previousLocation else { return }
//
//        guard center.distance(from: previousLocation) > 10 else { return }
//        self.previousLocation = center
//
//        geoCoder.cancelGeocode()
//
//        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
//            guard let self = self else { return }
//
//            if let _ = error {
//                //TODO: Show alert informing the user
//                return
//            }
//
//            guard let placemark = placemarks?.first else {
//                //TODO: Show alert informing the user
//                return
//            }
//
//            let streetNumber = placemark.subThoroughfare ?? ""
//            let streetName = placemark.thoroughfare ?? ""
//            let cityName = placemark.locality ?? ""
//            print("Here!!!!!: \(streetName)")
//            print(streetNumber)
//            print(cityName)
//
//            DispatchQueue.main.async {
//                print(streetName)
//                print(streetNumber)
//                print(cityName)
//                self.addressLabel.text = "\(streetNumber) \(streetName) \(cityName)"
//            }
//        }
//    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.black
        renderer.lineWidth = 5
        return renderer
    }
}
