//
//  LocationManager.swift
//  
//
//  Created by Alessandro Pavesi on 14/12/21.
//

import CoreLocation

/// Location manager used for the LocationSensor
open class LocationManagerRL: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    
    private let locationManager: CLLocationManager
    
    public override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.4
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }
    
    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
    }
}
