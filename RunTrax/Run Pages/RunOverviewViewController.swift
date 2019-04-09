/*
 RunDetailsViewController.swift
 RunTrax
 
 Created by Kelsey Henrichsen on 11/21/18.
 Copyright © 2018 Kelsey Henrichsen. All rights reserved.
 
 What to do in this view controller:
 -Have distance, time, and pace totals displayed
 -Show map with finished run (maybe with colors for speeds?)
 -When share button is clicked bring up display of sharing options
 */

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase

class RunOverviewViewController: UIViewController {
    //Properties
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var runKey : String?
    var shareRunKey : String?
    var handle : AuthStateDidChangeListenerHandle!
    var currentUser : User!
    
    var ref = Database.database().reference()
    var locationList = [CLLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFields()
        loadMap()
    }
    
    
    func loadMap()
    {
        ref.child("runs/\(runKey!)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let location = value?["location"] as? NSArray
            let count = location!.count
            for index in 1 ..< count
            {
                let temp = location![index] as! [Double]
//
                self.locationList.append(CLLocation(latitude: temp[0], longitude: temp[1]))
//
                
            }
            
            self.addRouteToMap(locations: self.locationList)
            
//            for route in self.locationList
//            {
//                self.mapView.addOverlay(route.polyline)
//                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//            }
            
        })
    }
    
    private func addRouteToMap(locations: [CLLocation])
    {
        let coordinates = locations.map { $0.coordinate }
        let geodesic = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(geodesic)
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    private func loadFields() -> Void
    {
        ref.child("runs/\(runKey!)").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let distance = value?["mileage"] as? String ?? "yeet"
            self.distanceLabel.text = "Total Distance: \(distance)"
            let time = value?["time"] as? String ?? "nopers"
            self.timeLabel.text = "Total Time: \(time)"
            let pace = value?["pace"] as? String ?? "ahhhh"
            self.paceLabel.text = "Pace: \(pace)"
            let date = value?["date"] as? String ?? "lol"
            self.dateLabel.text = "Date: \(date)"
            
        }) { (error) in
            print("hello error")
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func shareMenu()
    {
        let alert = UIAlertController(title: "Sharing Run", message: "How would you like to share?", preferredStyle: .actionSheet)
      
        alert.addAction(UIAlertAction(title: "Other User", style: .default, handler: { (_) in
            print("User click User button")
           
            self.shareRun()

        }))
        
        alert.addAction(UIAlertAction(title: "Messaging", style: .default, handler: { (_) in
            print("User click Messaging button")
        }))
        
        alert.addAction(UIAlertAction(title: "Other", style: .default, handler: { (_) in
            print("User click Other button")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func returnButton(_ sender: Any) {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "AccountNavigator") as! UINavigationController
        self.present(nav,animated: true, completion: nil)
    }
    func shareRun()
    {
        /*let nav = self.storyboard!.instantiateViewController(withIdentifier: "RunOverview") as! RunOverviewViewController
         nav.runKey = sendKey
         self.present(nav,animated: true, completion: nil)*/
        
        
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "shareFriends") as! SharePageViewController
        nav.shareRunKey = runKey ?? "derps"
        self.present(nav,animated: true, completion: nil)
        
        
    }
    
 
}

//adds line
//add an if to change colors?? for speed?
extension RunOverviewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 10
        return renderer
    }
}
