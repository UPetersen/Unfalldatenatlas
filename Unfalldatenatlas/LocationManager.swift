//
//  LocationManager.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 22.02.23.
//  Based on https://stackoverflow.com/questions/57681885/how-to-get-current-location-using-swiftui-without-viewcontrollers

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?

    // Middle of Germany as middle of the respective rectangle that contains Germany, as of https://de.wikipedia.org/wiki/Mittelpunkte_Deutschlands
//    var lastLatitudeOrMiddleOfGermany: CLLocationDegrees {
//        lastLocation?.coordinate.latitude ?? 51.163361
//    }
//    var lastLongitudeOrMiddleOfGermany: CLLocationDegrees {
//        lastLocation?.coordinate.longitude ?? 10.447683
//    }
    var latitudeOrMiddleOfGermany: CLLocationDegrees {
        locationManager.location?.coordinate.latitude ?? 51.163361
    }
    var longitudeOrMiddleOfGermany: CLLocationDegrees {
        locationManager.location?.coordinate.longitude ?? 10.447683
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

   
    
    var statusString: String {
        guard let status = locationStatus else {
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
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
    }
    
    func requestAuthorization() {
        if self.locationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    var isAuthorized: Bool {
        guard let status = locationStatus else {
            return false 
        }
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            return true
        } else {
            return false
            
        }
    }
    
}
