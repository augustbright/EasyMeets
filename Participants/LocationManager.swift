//
//  LocationManager.swift
//  Participants
//
//  Created by Валерий Бубенщиков on 27.12.2022.
//

import UIKit
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var region = MKCoordinateRegion()
    private let manager = CLLocationManager()
    
    init(mock: Bool) {
        super.init()
        if mock {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.715137, longitude: 44.827095),
                latitudinalMeters: 10000, longitudinalMeters: 10000
            )
        }
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }
}
