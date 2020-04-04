//
//  MapViewController.swift
//  EKEventKit.Example
//
//  Created by Filip Němeček on 04/04/2020.
//  Copyright © 2020 Filip Němeček. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coordinate = coordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
            mapView.setRegion(region, animated: true)
            let annotation = MKPointAnnotation()
            annotation.title = title
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
}
