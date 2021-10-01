//
//  Location.swift
//  Pangea
//
//  Created by  AdamRouss🐺 on 10.02.2021.
//

import Foundation
import MapKit

struct Location: Equatable, Hashable {
    var name: String
    var latitude: String
    var longitude: String
    
    var dictionary: [String : Any]  {
        return [
            "latitude" : latitude,
            "longitude" : longitude
        ]
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: CLLocationDegrees(latitude)!,
            longitude: CLLocationDegrees(longitude)!)
    }
    
    func getPlacemark() -> MKPlacemark {
        let placemark = MKPlacemark(coordinate:
                                        CLLocationCoordinate2D(
                                            latitude: CLLocationDegrees(latitude)!,
                                            longitude: CLLocationDegrees(longitude)!)
        )
        return placemark
    }
    
    func getName(_ completion: @escaping (String?) -> Void) {
        let coordinate = getPlacemark().coordinate
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placeMark = placemarks?.first else { return }
            completion(placeMark.name)
        }
    }
    
    func getPlacemark(_ completion: @escaping (MKPlacemark) -> Void) {
        let coordinate = getPlacemark().coordinate
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placeMark = placemarks?.first else { return }
            let mkPlaceMark = MKPlacemark(placemark: placeMark)
            completion(mkPlaceMark)
        }
    }
}

struct UserLocation: Hashable {
    var name: String
    var latitude: String
    var longitude: String
    
    func getPlacemark() -> MKPlacemark {
        let placemark = MKPlacemark(coordinate:
                                        CLLocationCoordinate2D(
                                            latitude: CLLocationDegrees(latitude)!,
                                            longitude: CLLocationDegrees(longitude)!)
        )
        return placemark
    }
    
    func getName() -> String? {
        return getPlacemark().name
    }
}
