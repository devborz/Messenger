//
//  MapViewController.swift
//  Pangea
//
//  Created by Усман Туркаев on 30.01.2021.
//

import MapKit
import CoreLocation
//import ClusterKit
//
//class MapViewController: UIViewController {
//    
//    let mapView = MKMapView()
//    
//    var trackingButton: MKUserTrackingBarButtonItem!
//    
//    let locationManager = CLLocationManager()
//    
//    let searchResultsController = MapSearchResultsViewController()
//    
//    var searchController: UISearchController!
//    
//    var presentingVC: NavController!
//    
//    var events: [Event] = []
//    
//    var selectedMark: MKPlacemark? {
//        didSet {
//            if let mark = selectedMark {
//                mapView.removeAnnotations(mapView.annotations)
//                addAnnotationToMap(mark)
//            } else {
//                mapView.removeAnnotations(mapView.annotations)
//                searchController?.searchBar.searchTextField.text = nil
//            }
//        }
//    }
//    
//    var selectedView: EventAnnotationView? = nil {
//        didSet {
//            guard let selectedView = selectedView else { return }
//            let event = selectedView.viewModel.model
//            
//            if let presentingVC = presentingVC {
//                presentingVC.dismiss(animated: true, completion: { [weak self] in
//                    self?.showEventVC(event)
//                })
//            } else {
//                showEventVC(event)
//            }
//        }
//    }
//    
//    var annotations: [MKAnnotation] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mapView.register(EventAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
//        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: "cluster")
//        
//        navigationItem.title = NSLocalizedString("Map", comment: "")
//        navigationItem.backButtonTitle = " "
//        navigationItem.largeTitleDisplayMode = .never
//        
//        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
//        algorithm.cellSize = 200
//        mapView.clusterManager.algorithm = algorithm
//        mapView.clusterManager.marginFactor =  1
//        
//        searchController = UISearchController(searchResultsController: searchResultsController)
//        searchController.searchResultsUpdater = searchResultsController
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.searchBar.backgroundColor = .systemBackground
//        view.backgroundColor = .systemBackground
//        searchResultsController.mapView = mapView
//        searchResultsController.handleMapSearchDelegate = self
//        view.addSubview(mapView)
//        mapView.frame = view.bounds
//        checkPermissions()
//        
//        definesPresentationContext = true
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        
//        trackingButton = MKUserTrackingBarButtonItem(mapView: mapView)
//        navigationItem.rightBarButtonItems = [trackingButton]
//        
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        
//        mapView.delegate = self
//        loadEvents()
//    }
//    
//    let region = (center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423), delta: 0.1)
//    
//    func eventVCClosed(_ event: Event) {
//        guard let annotation = mapView.selectedAnnotations.first else { return }
//        DispatchQueue.main.async {
//            self.mapView.deselectAnnotation(annotation, animated: true)
//            self.selectedView = nil
//        }
//    }
//    
//    func showEventVC(_ event: Event) {
//        let vc = EventViewController()
//        vc.event = event
//        vc.delegate = self
//        self.presentingVC = NavController(rootViewController: vc)
//        self.presentingVC.modalTransitionStyle = .coverVertical
//        self.presentingVC.modalPresentationStyle = .formSheet
//        self.present(self.presentingVC, animated: true)
//    }
//    
//    func loadEvents() {
//        DBManager.shared.getAllUpcomingEvents { (events) in
//            self.events = events
//            var annotations: [MKAnnotation] = []
//            for event in events {
//                if let location = event.location {
//                    let annotation = EventAnnotation()
//                    annotation.viewModel = .init(event)
//                    annotation.coordinate = location.getPlacemark().coordinate
//                    annotations.append(annotation)
//                }
//            }
//            self.mapView.clusterManager.annotations = annotations
//        }
//    }
//    
//    func addAnnotationToMap(_ mark: MKPlacemark, animated: Bool = true) {
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = mark.coordinate
//        annotation.title = mark.name
//        if let city = mark.locality,
//        let state = mark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        mapView.addAnnotation(annotation)
//        
//        searchController.searchBar.searchTextField.text = mark.name
//        
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        let region = MKCoordinateRegion(center: mark.coordinate, span: span)
//        mapView.setRegion(region, animated: true)
//        if animated {
//            mapView.setRegion(region, animated: true)
//        } else {
//            mapView.region = region
//        }
//    }
//    
//    func zoomIn() {
//        if let coordinate = locationManager.location?.coordinate {
//            mapView.setCenter(coordinate, animated: true)
//            mapView.setRegion(MKCoordinateRegion(center: (locationManager.location?.coordinate)!, latitudinalMeters: CLLocationDistance(800), longitudinalMeters: 800), animated: true)
//        }
//    }
//    
//    func checkPermissions() {
//        if !CLLocationManager.locationServicesEnabled() {
//            let alertController = UIAlertController(title: "Ваша геопозиция недоступна", message: "Вы можете разрешить приложению получать данные о вашей геопозиции в настройках" , preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//                self.zoomIn()
//                alertController.dismiss(animated: true, completion: nil)
//            }
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//    
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        let region = MKCoordinateRegion(center: locations[0].coordinate,span: span)
//
//        mapView.setRegion(region, animated: true)
//        mapView.showsUserLocation = true
//
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .denied {
//            return
//        }
//        zoomIn()
//    }
//}
//
//extension MapViewController: HandleMapSearch {
//    
//    func dropPin(_ placemark: MKPlacemark) {
//        selectedMark = placemark
//    }
//}
//
//extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? CKCluster else { return nil }
//        if annotation.count > 1 {
//            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: annotation) as! ClusterView
//            view.countLabel.text = "\(annotation.annotations.count)"
//            return view
//        } else {
//            guard let annotation = annotation.annotations.first as? EventAnnotation else {
//                return nil
//            }
//            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation) as! EventAnnotationView
//            view.setup(annotation.viewModel)
//            return view
//        }
//    }
//    
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        mapView.clusterManager.updateClustersIfNeeded()
//        
//    }
//    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let annotationView = view as? EventAnnotationView {
//            selectedView = annotationView
//        }
//    
//    
//    }
//}
//
//extension MapViewController: EventViewControllerDelegate {
//    func openUserProfile(_ controller: EventViewController, uid: String) {
//        
//    }
//    
//    func didClosed(_ controller: EventViewController) {
//        eventVCClosed(controller.event)
//    }
//}
//
//class EventAnnotation: MKPointAnnotation {
//    var viewModel: EventAnnotationViewModel!
//}
