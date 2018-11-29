//
//  AppDelegate.swift
//  RunTrax
//
//  Created by Kelsey Henrichsen on 11/15/18.
//  Copyright © 2018 Kelsey Henrichsen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .black
        let locationManager = LocationManager.shared
        locationManager.requestWhenInUseAuthorization()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
}


