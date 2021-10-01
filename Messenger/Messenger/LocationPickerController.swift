//
//  LocationPickerController.swift
//  Pangea
//
//  Created by Усман Туркаев on 24.08.2021.
//

import UIKit
import MapKit

protocol LocationPickerControllerDelegate: AnyObject {
    func didSelectLocation(_ pickerController: LocationPickerController, location: Location)
}

final class LocationPickerController: UIViewController, CLLocationManagerDelegate {
    
    weak var delegate: LocationPickerControllerDelegate?
    
    var rightButton: UIBarButtonItem!
    
    var cancelButton: UIBarButtonItem!
    
    var rightButtonName = "Send"
    
    let mapView = MKMapView()
    
    var trackingButton: MKUserTrackingButton!
    
    let locationManager = CLLocationManager()
    
    var selectedMark: MKPlacemark? {
        didSet {
            rightButton?.isEnabled = selectedMark != nil
            if let mark = selectedMark {
                mapView.removeAnnotations(mapView.annotations)
                addAnnotationToMap(mark)
            } else {
                mapView.removeAnnotations(mapView.annotations)
                searchController?.searchBar.searchTextField.text = nil
            }
        }
    }
    
    let searchResultsController = MapSearchResultsViewController()
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = NSLocalizedString("Location", comment: "")
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        rightButton = UIBarButtonItem(title: NSLocalizedString(rightButtonName, comment: ""), style: .done, target: self, action: #selector(rightButtonTapped))
        rightButton.isEnabled = false
        navigationItem.rightBarButtonItem = rightButton
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController?.searchResultsUpdater = searchResultsController
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.searchBar.backgroundColor = .systemBackground
        view.backgroundColor = .systemBackground
        searchResultsController.mapView = mapView
        searchResultsController.handleMapSearchDelegate = self
            
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        
        setupMapView()
        checkPermissions()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        
        setupTrackingButton()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapRecognizer)
        
        if let mark = selectedMark {
            self.addAnnotationToMap(mark, animated: false)
        }
    }
    
    func setupTrackingButton() {
        let trackingButtonContainerView = UIView()
        trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.backgroundColor = .systemBackground
        
        trackingButtonContainerView.addSubview(trackingButton)
        trackingButton.topAnchor.constraint(equalTo: trackingButtonContainerView.topAnchor).isActive = true
        trackingButton.rightAnchor.constraint(equalTo: trackingButtonContainerView.rightAnchor).isActive = true
        trackingButton.heightAnchor.constraint(equalTo: trackingButtonContainerView.heightAnchor).isActive = true
        trackingButton.widthAnchor.constraint(equalTo: trackingButtonContainerView.widthAnchor).isActive = true
        
        trackingButtonContainerView.backgroundColor = .clear
        trackingButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackingButtonContainerView)

        trackingButtonContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        trackingButtonContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        trackingButtonContainerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        trackingButtonContainerView.widthAnchor.constraint(equalTo: trackingButton.heightAnchor).isActive = true
        
        trackingButton.layer.cornerRadius = 35
        trackingButton.clipsToBounds = true
        
        trackingButtonContainerView.layer.shadowColor = UIColor.black.cgColor
        trackingButtonContainerView.layer.shadowRadius = 10
        trackingButtonContainerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        trackingButtonContainerView.layer.shadowOpacity = 0.3
        trackingButtonContainerView.layer.masksToBounds = false
    }
    
    @objc
    func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationInView = gesture.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                guard let placeMark = placemarks?.first else { return }
                self.selectedMark = MKPlacemark(placemark: placeMark)
                self.addAnnotationToMap(self.selectedMark!)
            }
        }
    }
    
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        if selectedMark != nil {
            selectedMark = nil
        }
    }
    
    func addAnnotationToMap(_ mark: MKPlacemark, animated: Bool = true) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mark.coordinate
        annotation.title = mark.name
        if let city = mark.locality,
        let state = mark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        
        searchController?.searchBar.searchTextField.text = mark.name
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: mark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        if animated {
            mapView.setRegion(region, animated: true)
        } else {
            mapView.region = region
        }
    }
    
    func zoomIn() {
        if let coordinate = locationManager.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
            mapView.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(800), longitudinalMeters: 800), animated: true)
        }
    }
    
    func checkPermissions() {
        if !CLLocationManager.locationServicesEnabled() {
            let alertController = UIAlertController(title: "Ваша геопозиция недосупна", message: "Вы можете разрешить приложению получать данные о вашей геопозиции в настройках" , preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОK", style: .default) { _ in
                self.zoomIn()
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    @objc
    func rightButtonTapped() {
        guard let mark = selectedMark else { return }
        let location = Location(name: "", latitude: "\(mark.coordinate.latitude)", longitude: "\(mark.coordinate.longitude)")
        delegate?.didSelectLocation(self, location: location)
    }
    
    @objc
    func cancelButtonTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        let region = MKCoordinateRegion(center: locations[0].coordinate,span: span)
//
//        mapView.setRegion(region, animated: true)
//        mapView.showsUserLocation = true

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            return
        }
//        zoomIn()
    }
}

extension LocationPickerController: HandleMapSearch {
    
    func dropPin(_ placemark: MKPlacemark) {
        selectedMark = placemark
    }
}


