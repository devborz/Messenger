//
//  LocationViewerController.swift
//  Pangea
//
//  Created by Усман Туркаев on 25.08.2021.
//

import UIKit
import MapKit

final class LocationViewerController: UIViewController, CLLocationManagerDelegate {
    
    var location: Location?
    
    var cancelButton: UIBarButtonItem!
    
    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Location"
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setupMapView()
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        
        if let location = location {
            self.addAnnotationToMap(location, animated: false)
        }
    }
    
    func addAnnotationToMap(_ location: Location, animated: Bool = true) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = location.name
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        if animated {
            mapView.setRegion(region, animated: true)
        } else {
            mapView.region = region
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    @objc
    func cancelButtonTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
