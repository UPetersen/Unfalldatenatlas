//
//  LocationManager.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 22.02.23.
//  Based on https://stackoverflow.com/questions/57681885/how-to-get-current-location-using-swiftui-without-viewcontrollers

import Foundation
import CoreLocation
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?


    // Middle of Germany as middle of the respective rectangle that contains Germany, see of https://de.wikipedia.org/wiki/Mittelpunkte_Deutschlands
    static let latitudMiddleOfGermany: CLLocationDegrees = 51.163361
    static let longitudeMiddleOfGermany: CLLocationDegrees = 10.447683
    
    // Width of Germany is ca. 636 km and length (north/south) ca. 874 km, see https://de.wikipedia.org/wiki/Geographie_Deutschlands
    static let widthOfGermany = 636_000.0
    static let lengthOfGermany = 874_000.0
    
    static let regionForGermany = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: LocationManager.latitudMiddleOfGermany,
            longitude: LocationManager.longitudeMiddleOfGermany
        ),
        latitudinalMeters: LocationManager.lengthOfGermany,
        longitudinalMeters: LocationManager.widthOfGermany
    )
//    static let regionForGermany = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.163361, longitude: 10.447683), latitudinalMeters: 874_000.0, longitudinalMeters: 636_000.0)

    var latitudeUserLocationOrMiddleOfGermany: CLLocationDegrees {
        locationManager.location?.coordinate.latitude ?? Self.latitudMiddleOfGermany
    }
    var longitudeUserLocationOrMiddleOfGermany: CLLocationDegrees {
        locationManager.location?.coordinate.longitude ?? Self.longitudeMiddleOfGermany
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var statusString: String {
        guard let status = authorizationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
//        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
//        print(#function, location)
    }
    
    func requestAuthorization() {
        if self.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    var isAuthorized: Bool {
        guard let status = authorizationStatus else {
            return false 
        }
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            return true
        } else {
            return false
            
        }
    }
    
}
