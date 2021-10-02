//
//  MapSearchResultsViewController.swift
//  Pangea
//
//  Created by Усман Туркаев on 17.02.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapSearchResultsViewController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    
    var mapView: MKMapView? = nil
    
    var handleMapSearchDelegate: HandleMapSearch?
    
    var selectedMark: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPin(selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@ %@ %@ %@ %@ %@ %@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

extension MapSearchResultsViewController: UISearchResultsUpdating, UISearchTextFieldDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
                let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

protocol HandleMapSearch {
    func dropPin(_ placemark: MKPlacemark)
}
