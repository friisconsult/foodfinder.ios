//
//  MapViewController.swift
//  Food Finder
//
//  Created by Per Friis on 19/09/2017.
//  Copyright © 2017 Per Friis Consult ApS. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView:MKMapView!
    
    lazy var locationManager:CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        return locationManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if locationManager.location == nil{
            debugPrint(locationManager)
        }
        mapView.userTrackingMode = .follow

        
        let venues = Venue.find(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        mapView.addAnnotations(venues)
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: nil, queue: .main) { (notification) in
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(Venue.find(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext))
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
