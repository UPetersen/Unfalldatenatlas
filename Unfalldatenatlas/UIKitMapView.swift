//
//  UIKitMapView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 10.06.25.
//
//
//
//




import SwiftUI
import MapKit

final class AccidentAnnotation: NSObject, MKAnnotation {
    let accident: AccidentStructGRDB
    let coordinate: CLLocationCoordinate2D
    init(accident: AccidentStructGRDB) {
        self.accident = accident
        self.coordinate = accident.coordinate
        super.init()
    }
}

struct UIKitMapView: UIViewRepresentable {
    // Nur einmal initial setzen, kein Binding nötig
    let initialRegion: MKCoordinateRegion
    let accidents: [AccidentStructGRDB]
    var mapStyleIsStandard: Bool
    var show3D: Bool
    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
    var onRegionChanged: ((MKCoordinateRegion) -> Void)? = nil
    @Binding var coordinatorRef: Coordinator?

    // << Gib Coordinator explizit nach außen frei >>
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView
        var lastRegion: MKCoordinateRegion? // Merkt sich die letzte echte Region
        
        init(_ parent: UIKitMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let region = mapView.region
            lastRegion = region // Merke die aktuelle Region
            parent.onRegionChanged?(region)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
                view?.markerTintColor = .systemBlue
                view?.glyphText = "\(cluster.memberAnnotations.count)"
                view?.clusteringIdentifier = "AccidentCluster"
                view?.canShowCallout = false
                return view
            }
            if annotation is AccidentAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
                view?.markerTintColor = .systemRed
                view?.glyphText = "!"
                view?.clusteringIdentifier = "AccidentCluster"
                view?.canShowCallout = false
                return view
            }
            return nil
        }
    }

//    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        // Setze Binding asynchron (wegen SwiftUI-Lifecycle)
        DispatchQueue.main.async {
            self.coordinatorRef = coordinator
        }
        return coordinator
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(initialRegion, animated: false)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsCompass = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // MapType
        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
        if uiView.mapType != wantedType { uiView.mapType = wantedType }
        // Camera
        let wantedPitch: CGFloat = show3D ? 60 : 0
        let wantedCamera = MKMapCamera(
            lookingAtCenter: uiView.region.center,
            fromDistance: 800,
            pitch: wantedPitch,
            heading: 0
        )
        if abs(uiView.camera.pitch - wantedPitch) > 0.1 {
            uiView.setCamera(wantedCamera, animated: true)
        }
        // Marker (wie immer)
        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
        let wantedIDs = Set(accidents.map { $0.id })
        if currentIDs != wantedIDs {
            uiView.removeAnnotations(uiView.annotations)
            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
            uiView.addAnnotations(annotations)
        }
    }
}





//import SwiftUI
//import MapKit
//
//final class AccidentAnnotation: NSObject, MKAnnotation {
//    let accident: AccidentStructGRDB
//    let coordinate: CLLocationCoordinate2D
//    init(accident: AccidentStructGRDB) {
//        self.accident = accident
//        self.coordinate = accident.coordinate
//        super.init()
//    }
//}
//
//struct UIKitMapView: UIViewRepresentable {
//    @Binding var region: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var mapStyleIsStandard: Bool
//    var show3D: Bool
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//    var onRegionChanged: ((MKCoordinateRegion) -> Void)? = nil
//
//    func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(region, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//        mapView.showsUserLocation = false
//        mapView.isRotateEnabled = false
//        mapView.pointOfInterestFilter = .excludingAll
//        mapView.showsCompass = true
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // --- DEBUG: Print current/target region and pending state
//        print("updateUIView: region=\(region), uiView.region=\(uiView.region), pending=\(context.coordinator.isPendingRegionChange)")
//
//        // Set MapType
//        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
//        if uiView.mapType != wantedType { uiView.mapType = wantedType }
//
//        // Camera (2D/3D)
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        let wantedCamera = MKMapCamera(
//            lookingAtCenter: region.center,
//            fromDistance: 800,
//            pitch: wantedPitch,
//            heading: 0
//        )
//        if abs(uiView.camera.pitch - wantedPitch) > 0.1 ||
//            abs(uiView.camera.centerCoordinate.latitude - region.center.latitude) > 0.0001 ||
//            abs(uiView.camera.centerCoordinate.longitude - region.center.longitude) > 0.0001 {
//            uiView.setCamera(wantedCamera, animated: true)
//        }
//
//        // Nur setzen, wenn NICHT gerade User-Interaktion läuft UND signifikanter Unterschied
//        guard !context.coordinator.isPendingRegionChange else { return }
//        if !uiView.region.isApproximatelyEqual(to: region, tolerance: 0.0015) {
//            print("updateUIView: setRegion!")
//            uiView.setRegion(region, animated: true)
//        }
//
//        // Annotations optimiert updaten
//        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
//        let wantedIDs = Set(accidents.map { $0.id })
//        if currentIDs != wantedIDs {
//            uiView.removeAnnotations(uiView.annotations)
//            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//            uiView.addAnnotations(annotations)
//        }
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        var isPendingRegionChange = false
//        init(_ parent: UIKitMapView) { self.parent = parent }
//
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            // --- DEBUG: Print new region after user interaction
//            print("regionDidChangeAnimated: new region=\(mapView.region)")
//            isPendingRegionChange = true
//            let region = mapView.region
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                // Nur setzen, wenn sich die Region signifikant geändert hat (verhindert Mini-Feedbacks)
//                if !self.parent.region.isApproximatelyEqual(to: region, tolerance: 0.0015) {
//                    print("regionDidChangeAnimated: write to Binding!")
//                    self.parent.region = region
//                    self.parent.onRegionChanged?(region)
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                    self.isPendingRegionChange = false
//                }
//            }
//        }
//
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let cluster = annotation as? MKClusterAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemBlue
//                view?.glyphText = "\(cluster.memberAnnotations.count)"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            if annotation is AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemRed
//                view?.glyphText = "!"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            return nil
//        }
//    }
//}
//
//// Relative Region-Vergleich als Extension
//extension MKCoordinateRegion {
//    func isApproximatelyEqual(to other: MKCoordinateRegion, tolerance: Double) -> Bool {
//        let dLat = abs(center.latitude - other.center.latitude)
//        let dLon = abs(center.longitude - other.center.longitude)
//        let sLat = max(span.latitudeDelta, other.span.latitudeDelta)
//        let sLon = max(span.longitudeDelta, other.span.longitudeDelta)
//        let relLat = sLat > 0 ? dLat / sLat : 0
//        let relLon = sLon > 0 ? dLon / sLon : 0
//        let relSpanLat = sLat > 0 ? abs(span.latitudeDelta - other.span.latitudeDelta) / sLat : 0
//        let relSpanLon = sLon > 0 ? abs(span.longitudeDelta - other.span.longitudeDelta) / sLon : 0
//        return relLat < tolerance && relLon < tolerance && relSpanLat < tolerance && relSpanLon < tolerance
//    }
//}
//
//


//
//import SwiftUI
//import MapKit
//
//// MARK: - Unfall-Marker als MKAnnotation
//
//final class AccidentAnnotation: NSObject, MKAnnotation {
//    let accident: AccidentStructGRDB
//    let coordinate: CLLocationCoordinate2D
//
//    init(accident: AccidentStructGRDB) {
//        self.accident = accident
//        self.coordinate = accident.coordinate
//        super.init()
//    }
//
//    var title: String? { "Unfall" }
//    var subtitle: String? { "ID: \(accident.id)" }
//}
//
//// MARK: - UIViewRepresentable-Wrapper für MKMapView
//
//struct UIKitMapView: UIViewRepresentable {
//    // State aus SwiftUI
//    @Binding var region: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var mapStyleIsStandard: Bool         // true = Standard, false = Satellit
//    var show3D: Bool                     // true = 3D (Pitch > 0), false = 2D (Pitch = 0)
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//    var onRegionChanged: ((MKCoordinateRegion) -> Void)? = nil // Callback für Debounce, Fetches etc.
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(region, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//        mapView.showsUserLocation = false
//        mapView.isRotateEnabled = false
//        mapView.pointOfInterestFilter = .excludingAll
//        mapView.showsCompass = true
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // 1. Kartentyp setzen (Standard/Satellit)
//        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
//        if uiView.mapType != wantedType {
//            uiView.mapType = wantedType
//        }
//
//        // 2. Kamera setzen (Pitch für 3D)
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        let wantedCamera = MKMapCamera(
//            lookingAtCenter: region.center,
//            fromDistance: 800,
//            pitch: wantedPitch,
//            heading: 0
//        )
//        if uiView.camera.pitch != wantedPitch ||
//            abs(uiView.camera.centerCoordinate.latitude - region.center.latitude) > 0.0001 ||
//            abs(uiView.camera.centerCoordinate.longitude - region.center.longitude) > 0.0001 {
//            uiView.setCamera(wantedCamera, animated: true)
//        }
//
//        // 3. Region setzen – ABER: NICHT wenn gerade User-Event läuft!
//        guard !context.coordinator.isPendingRegionChange else { return }
//        if !uiView.region.isApproximatelyEqual(to: region, tolerance: 0.015) {
//            uiView.setRegion(region, animated: true)
//        }
//
//        // 4. Marker nur bei Änderung updaten (gegen Flackern)
//        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
//        let wantedIDs = Set(accidents.map { $0.id })
//        if currentIDs != wantedIDs {
//            uiView.removeAnnotations(uiView.annotations)
//            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//            uiView.addAnnotations(annotations)
//        }
//    }
//
//    // MARK: - Coordinator für MapView-Delegate-Methoden
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        var isPendingRegionChange = false // Flag zur Vermeidung von Schwingung/Endlosschleifen
//
//        init(_ parent: UIKitMapView) {
//            self.parent = parent
//        }
//
//        // Marker und Cluster
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let cluster = annotation as? MKClusterAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemBlue
//                view?.glyphText = "\(cluster.memberAnnotations.count)"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            if annotation is AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemRed
//                view?.glyphText = "!"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            return nil
//        }
//
//        // Marker-Tap → Callback nach SwiftUI
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            if let accidentAnnotation = view.annotation as? AccidentAnnotation {
//                parent.onSelectAccident?(accidentAnnotation.accident)
//            }
//        }
//
//        // User bewegt/zoomt die Karte: Region ins Binding & Callback (z.B. für Debounce/Fetchen)
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            // 1. Flag setzen, um Endlosschleife zu verhindern
//            isPendingRegionChange = true
//            let region = mapView.region
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                self.parent.region = region
//                self.parent.onRegionChanged?(region) // Debounce/Fetch im SwiftUI-Code
//                // 2. Flag nach kurzem Delay zurücksetzen (damit updateUIView einmal blockiert)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                    self.isPendingRegionChange = false
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Region-Vergleich als Extension (toleranzbasiert, relativ zum aktuellen Ausschnitt)
//
//extension MKCoordinateRegion {
//    /// Vergleicht Regionen relativ zum Kartenausschnitt. tolerance = Anteil der Span (z.B. 0.015 = 1,5%)
//    func isApproximatelyEqual(to other: MKCoordinateRegion, tolerance: Double) -> Bool {
//        let dLat = abs(center.latitude - other.center.latitude)
//        let dLon = abs(center.longitude - other.center.longitude)
//        let sLat = max(span.latitudeDelta, other.span.latitudeDelta)
//        let sLon = max(span.longitudeDelta, other.span.longitudeDelta)
//        let relLat = sLat > 0 ? dLat / sLat : 0
//        let relLon = sLon > 0 ? dLon / sLon : 0
//        let relSpanLat = sLat > 0 ? abs(span.latitudeDelta - other.span.latitudeDelta) / sLat : 0
//        let relSpanLon = sLon > 0 ? abs(span.longitudeDelta - other.span.longitudeDelta) / sLon : 0
//        return relLat < tolerance && relLon < tolerance && relSpanLat < tolerance && relSpanLon < tolerance
//    }
//}
//
//
//




//import SwiftUI
//import MapKit
//
//// MARK: - Dein Unfall-Annotationstyp
//
//final class AccidentAnnotation: NSObject, MKAnnotation {
//    let accident: AccidentStructGRDB
//    let coordinate: CLLocationCoordinate2D
//
//    init(accident: AccidentStructGRDB) {
//        self.accident = accident
//        self.coordinate = accident.coordinate
//        super.init()
//    }
//
//    var title: String? { "Unfall" }
//    var subtitle: String? { "ID: \(accident.id)" }
//}
//
//// MARK: - UIViewRepresentable-Wrapper für MKMapView
//
//struct UIKitMapView: UIViewRepresentable {
//    @Binding var region: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var mapStyleIsStandard: Bool           // true = Standard, false = Satellit
//    var show3D: Bool                       // true = 3D (Pitch > 0), false = 2D (Pitch = 0)
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//    var onRegionChanged: ((MKCoordinateRegion) -> Void)? = nil // ← NEU: Callback für Regionwechsel
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(region, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//        mapView.showsUserLocation = false
//        mapView.isRotateEnabled = false
//        mapView.pointOfInterestFilter = .excludingAll
//        mapView.showsCompass = true
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // --- Kartentyp (Standard/Satellit) ---
//        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
//        if uiView.mapType != wantedType {
//            uiView.mapType = wantedType
//        }
//
//        // --- 3D/2D Umschaltung ---
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        let wantedCamera = MKMapCamera(
//            lookingAtCenter: region.center,
//            fromDistance: 800,
//            pitch: wantedPitch,
//            heading: 0
//        )
//        if uiView.camera.pitch != wantedPitch ||
//            abs(uiView.camera.centerCoordinate.latitude - region.center.latitude) > 0.0001 ||
//            abs(uiView.camera.centerCoordinate.longitude - region.center.longitude) > 0.0001 {
//            uiView.setCamera(wantedCamera, animated: true)
//        }
//
//        // --- Region synchronisieren (Flackern vermeiden) ---
//        if !coordinateRegionEquals(uiView.region, region) && !context.coordinator.isUpdatingRegion {
//            uiView.setRegion(region, animated: true)
//        }
//
//        // --- Marker optimiert updaten (kein Flackern) ---
//        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
//        let wantedIDs = Set(accidents.map { $0.id })
//        if currentIDs != wantedIDs {
//            uiView.removeAnnotations(uiView.annotations)
//            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//            uiView.addAnnotations(annotations)
//        }
//    }
//
//    // --- Helper zum Regionsvergleich ---
////    private func coordinateRegionEquals(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion) -> Bool {
////        let epsilon = 0.0001
////        return abs(a.center.latitude - b.center.latitude) < epsilon &&
////            abs(a.center.longitude - b.center.longitude) < epsilon &&
////            abs(a.span.latitudeDelta - b.span.latitudeDelta) < epsilon &&
////            abs(a.span.longitudeDelta - b.span.longitudeDelta) < epsilon
////    }
//    private func coordinateRegionEquals(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion, tolerance: Double = 0.02) -> Bool {
//        // tolerance ist 2% (0.02)
//        let latDelta = abs(a.center.latitude - b.center.latitude)
//        let lonDelta = abs(a.center.longitude - b.center.longitude)
//        let spanLat = max(a.span.latitudeDelta, b.span.latitudeDelta)
//        let spanLon = max(a.span.longitudeDelta, b.span.longitudeDelta)
//        
//        let relLat = latDelta / spanLat
//        let relLon = lonDelta / spanLon
//        let spanLatDelta = abs(a.span.latitudeDelta - b.span.latitudeDelta) / spanLat
//        let spanLonDelta = abs(a.span.longitudeDelta - b.span.longitudeDelta) / spanLon
//        
//        return relLat < tolerance &&
//               relLon < tolerance &&
//               spanLatDelta < tolerance &&
//               spanLonDelta < tolerance
//    }
//
//    // MARK: - Coordinator
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        var isUpdatingRegion = false
//
//        init(_ parent: UIKitMapView) {
//            self.parent = parent
//        }
//
//        // --- Clustering und Marker-Views ---
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let cluster = annotation as? MKClusterAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemBlue
//                view?.glyphText = "\(cluster.memberAnnotations.count)"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            if annotation is AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemRed
//                view?.glyphText = "!"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false // Bei Bedarf auf true
//                return view
//            }
//            return nil
//        }
//
//        // Marker-Tap → Callback nach SwiftUI
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            if let accidentAnnotation = view.annotation as? AccidentAnnotation {
//                parent.onSelectAccident?(accidentAnnotation.accident)
//            }
//        }
//
//        // Kartenbewegung → SwiftUI-Binding aktualisieren und Callback auslösen
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            isUpdatingRegion = true
//            let newRegion = mapView.region
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                self.parent.region = newRegion
//                self.parent.onRegionChanged?(newRegion)
//                // Mit minimalem Delay Flag zurücksetzen
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self.isUpdatingRegion = false
//                }
//            }
//        }
//    }
//}
//


//
//import SwiftUI
//import MapKit
//
//// MARK: - Dein Unfall-Annotationstyp
//
//final class AccidentAnnotation: NSObject, MKAnnotation {
//    let accident: AccidentStructGRDB
//    let coordinate: CLLocationCoordinate2D
//
//    init(accident: AccidentStructGRDB) {
//        self.accident = accident
//        self.coordinate = accident.coordinate
//        super.init()
//    }
//
//    var title: String? { "Unfall" }
//    var subtitle: String? { "ID: \(accident.id)" }
//}
//
//// MARK: - UIViewRepresentable-Wrapper für MKMapView
//
//struct UIKitMapView: UIViewRepresentable {
//    @Binding var region: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var mapStyleIsStandard: Bool           // true = Standard, false = Satellit
//    var show3D: Bool                       // true = 3D (Pitch > 0), false = 2D (Pitch = 0)
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(region, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//        mapView.showsUserLocation = false
//        mapView.isRotateEnabled = false
//        mapView.pointOfInterestFilter = .excludingAll
//        mapView.showsCompass = true
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // --- Kartentyp (Standard/Satellit) ---
//        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
//        if uiView.mapType != wantedType {
//            uiView.mapType = wantedType
//        }
//
//        // --- 3D/2D Umschaltung ---
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        let wantedCamera = MKMapCamera(
//            lookingAtCenter: region.center,
//            fromDistance: 800,
//            pitch: wantedPitch,
//            heading: 0
//        )
//        if uiView.camera.pitch != wantedPitch ||
//            abs(uiView.camera.centerCoordinate.latitude - region.center.latitude) > 0.0001 ||
//            abs(uiView.camera.centerCoordinate.longitude - region.center.longitude) > 0.0001 {
//            uiView.setCamera(wantedCamera, animated: true)
//        }
//
//        // --- Region synchronisieren (Flackern vermeiden) ---
//        if !coordinateRegionEquals(uiView.region, region) && !context.coordinator.isUpdatingRegion {
//            uiView.setRegion(region, animated: true)
//        }
//
//        // --- Marker optimiert updaten (kein Flackern) ---
//        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
//        let wantedIDs = Set(accidents.map { $0.id })
//        if currentIDs != wantedIDs {
//            uiView.removeAnnotations(uiView.annotations)
//            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//            uiView.addAnnotations(annotations)
//        }
//    }
//
//    // --- Helper zum Regionsvergleich ---
//    private func coordinateRegionEquals(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion) -> Bool {
//        let epsilon = 0.0001
//        return abs(a.center.latitude - b.center.latitude) < epsilon &&
//            abs(a.center.longitude - b.center.longitude) < epsilon &&
//            abs(a.span.latitudeDelta - b.span.latitudeDelta) < epsilon &&
//            abs(a.span.longitudeDelta - b.span.longitudeDelta) < epsilon
//    }
//
//    // MARK: - Coordinator
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        var isUpdatingRegion = false
//
//        init(_ parent: UIKitMapView) {
//            self.parent = parent
//        }
//
//        // --- Clustering und Marker-Views ---
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let cluster = annotation as? MKClusterAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemBlue
//                view?.glyphText = "\(cluster.memberAnnotations.count)"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            if annotation is AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemRed
//                view?.glyphText = "!"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false // Bei Bedarf auf true
//                return view
//            }
//            return nil
//        }
//
//        // Marker-Tap → Callback nach SwiftUI
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            if let accidentAnnotation = view.annotation as? AccidentAnnotation {
//                parent.onSelectAccident?(accidentAnnotation.accident)
//            }
//        }
//
//        // Kartenbewegung → SwiftUI-Binding aktualisieren
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            isUpdatingRegion = true
//            let newRegion = mapView.region
//            DispatchQueue.main.async { [weak self] in
//                self?.parent.region = newRegion
//                self?.isUpdatingRegion = false
//            }
//        }
//    }
//}
//




//
//import SwiftUI
//import MapKit
//
//// MARK: - Deine Unfall-Annotation als MKAnnotation
//
//final class AccidentAnnotation: NSObject, MKAnnotation {
//    let accident: AccidentStructGRDB
//    let coordinate: CLLocationCoordinate2D
//
//    init(accident: AccidentStructGRDB) {
//        self.accident = accident
//        self.coordinate = accident.coordinate
//        super.init()
//    }
//
//    var title: String? { "Unfall" }
//    var subtitle: String? { "ID: \(accident.id)" }
//}
//
//// MARK: - UIViewRepresentable-Wrapper für MKMapView
//
//struct UIKitMapView: UIViewRepresentable {
//    // SwiftUI-State
//    @Binding var region: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(region, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//        mapView.showsUserLocation = false
//        mapView.isRotateEnabled = false
//        mapView.pointOfInterestFilter = .excludingAll
//        mapView.showsCompass = true
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // Kartenregion synchronisieren (Schleifen vermeiden!)
//        if !coordinateRegionEquals(uiView.region, region) && !context.coordinator.isUpdatingRegion {
//            uiView.setRegion(region, animated: true)
//        }
//
//        // Bestehende Annotationen entfernen und neue hinzufügen (Optimierung möglich)
//        uiView.removeAnnotations(uiView.annotations)
//        let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//        uiView.addAnnotations(annotations)
//    }
//    
//    
//    
//    
//
//    // Helper-Vergleich für Kartenregion
//    private func coordinateRegionEquals(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion) -> Bool {
//        let epsilon = 0.0001
//        return abs(a.center.latitude - b.center.latitude) < epsilon &&
//            abs(a.center.longitude - b.center.longitude) < epsilon &&
//            abs(a.span.latitudeDelta - b.span.latitudeDelta) < epsilon &&
//            abs(a.span.longitudeDelta - b.span.longitudeDelta) < epsilon
//    }
//
//    // MARK: - Coordinator
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        var isUpdatingRegion = false
//
//        init(_ parent: UIKitMapView) {
//            self.parent = parent
//        }
//
//        // MARK: - Clustering und Marker-Views
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let cluster = annotation as? MKClusterAnnotation {
//                // Cluster-Marker
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemBlue
//                view?.glyphText = "\(cluster.memberAnnotations.count)"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false
//                return view
//            }
//            if annotation is AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemRed
//                view?.glyphText = "!"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false // Setze true, falls Callout gewünscht
//                return view
//            }
//            return nil
//        }
//
//        // Marker-Tap → Callback nach SwiftUI
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            if let accidentAnnotation = view.annotation as? AccidentAnnotation {
//                parent.onSelectAccident?(accidentAnnotation.accident)
//            }
//        }
//
//        // User bewegt Karte: Region ins Binding spiegeln (Flag schützt vor Endlosschleifen)
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            isUpdatingRegion = true
//            let newRegion = mapView.region
//            DispatchQueue.main.async { [weak self] in
//                self?.parent.region = newRegion
//                self?.isUpdatingRegion = false
//            }
//        }
//    }
//}








//import SwiftUI
//import MapKit
//
///// Ein Marker-Struct für die Map
//final class AccidentAnnotation: NSObject, MKAnnotation {
//    let accident: AccidentStructGRDB
//    let coordinate: CLLocationCoordinate2D
//
//    init(accident: AccidentStructGRDB) {
//        self.accident = accident
//        self.coordinate = accident.coordinate
//        super.init()
//    }
//
//    var title: String? { "Unfall" }
//    var subtitle: String? { "ID: \(accident.id)" }
//}
//
//struct UIKitMapView: UIViewRepresentable {
//    // MARK: - Bindings und Daten
//    
//    @Binding var region: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//    
//    // MARK: - UIViewRepresentable
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView(frame: .zero)
//        mapView.delegate = context.coordinator
//
//        mapView.setRegion(region, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//
//        mapView.showsUserLocation = false
//        mapView.isRotateEnabled = false
//        mapView.pointOfInterestFilter = .excludingAll
//        mapView.showsCompass = true
//
//        // Clustering aktivieren
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
//
//        return mapView
//    }
//    
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        // Region setzen, aber nur wenn sie sich wirklich geändert hat
//        if !coordinateRegionEquals(uiView.region, region) {
//            uiView.setRegion(region, animated: true)
//        }
//        
//        // Bestehende Annotationen entfernen und neue hinzufügen (optimierbar)
//        uiView.removeAnnotations(uiView.annotations)
//        let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//        uiView.addAnnotations(annotations)
//    }
//    
//    // MARK: - Helper
//    private func coordinateRegionEquals(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion) -> Bool {
//        let epsilon = 0.0001
//        return abs(a.center.latitude - b.center.latitude) < epsilon &&
//            abs(a.center.longitude - b.center.longitude) < epsilon &&
//            abs(a.span.latitudeDelta - b.span.latitudeDelta) < epsilon &&
//            abs(a.span.longitudeDelta - b.span.longitudeDelta) < epsilon
//    }
//    
//    // MARK: - Coordinator
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        
//        init(_ parent: UIKitMapView) {
//            self.parent = parent
//        }
//
//        // MARK: - Annotation Views mit Clustering
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let cluster = annotation as? MKClusterAnnotation {
//                // Cluster-Ansicht
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster", for: cluster) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemBlue
//                view?.glyphText = "\(cluster.memberAnnotations.count)"
//                view?.clusteringIdentifier = "AccidentCluster"
//                return view
//            }
//            if annotation is AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
//                view?.markerTintColor = .systemRed
//                view?.glyphText = "!"
//                view?.clusteringIdentifier = "AccidentCluster"
//                view?.canShowCallout = false // Kein Callout, lässt sich einfach anpassen
//                return view
//            }
//            return nil
//        }
//
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            // Marker-Tap → Callback ins SwiftUI
//            if let accidentAnnotation = view.annotation as? AccidentAnnotation {
//                parent.onSelectAccident?(accidentAnnotation.accident)
//            }
//        }
//
//        // Optionale Synchronisation: Karte bewegt sich → SwiftUI-State updaten
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            let newRegion = mapView.region
//            // Hier könnten wir parent.region setzen, wenn das gewünscht ist (Binding).
//            // Aber Achtung: Endlosschleifen vermeiden!
//        }
//    }
//}
