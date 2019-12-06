//
//  MapView.swift
//  CityWeatherApp
//
//  Created by Rafał on 17/11/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        guard let city = Storage.shared.cityToShowOnMap else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) { (placemarks, error) in
            guard let coordinate = placemarks?.first?.location?.coordinate else { return }
            
            let span = MKCoordinateSpan(latitudeDelta: 0.8,
                                        longitudeDelta: 0.8)
            let region = MKCoordinateRegion(center: coordinate,
             span: span)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func onCloseMapBtnClick(_ sender: UIButton) {
        self.presentingViewController!.dismiss(animated: true)
    }
}
