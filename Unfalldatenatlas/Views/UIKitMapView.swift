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

/// MKAnnotation subclass representing an accident.
final class AccidentAnnotation: NSObject, MKAnnotation {
    let accident: AccidentStructGRDB
    let coordinate: CLLocationCoordinate2D

    init(accident: AccidentStructGRDB) {
        self.accident = accident
        self.coordinate = accident.coordinate
        super.init()
    }
}

/// SwiftUI UIViewRepresentable wrapper for MKMapView.
struct UIKitMapView: UIViewRepresentable {
    /// The region to display when the map is first shown.
    let initialRegion: MKCoordinateRegion
    /// The accident data to be shown as markers.
    let accidents: [AccidentStructGRDB]
    /// Standard or satellite map style.
    var mapStyleIsStandard: Bool
    /// 3D camera enabled or not.
    var show3D: Bool
    /// Callback when an accident is selected.
    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
    /// Callback when the map region was changed by user interaction.
    var onRegionChanged: ((MKCoordinateRegion) -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(initialRegion, animated: false)
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Accident")
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Cluster")
        mapView.register(SmallCircleAnnotationView.self, forAnnotationViewWithReuseIdentifier: "SmallCircle")
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsCompass = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        print("updateUIView heading: \(uiView.camera.heading), pitch: \(uiView.camera.pitch)")

        // --- Set the map type (standard or satellite) ---
        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
        if uiView.mapType != wantedType {
            uiView.mapType = wantedType
        }

//        // --- Set 3D/2D camera pitch ---
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        let wantedCamera = MKMapCamera(
//            lookingAtCenter: uiView.region.center,
//            fromDistance: 800,
//            pitch: wantedPitch,
//            heading: 0
//        )
//        if abs(uiView.camera.pitch - wantedPitch) > 0.1 {
//            uiView.setCamera(wantedCamera, animated: true)
//        }

        // --- Only set pitch (for 3D) but keep user heading! ---
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        if abs(uiView.camera.pitch - wantedPitch) > 0.1 {
//            let camera = uiView.camera.copy() as! MKMapCamera
//            camera.pitch = wantedPitch                // Set pitch for 2D/3D
//            // camera.heading stays unchanged!
//            uiView.setCamera(camera, animated: true)
//        }
//        
        let wantedPitch: CGFloat = show3D ? 60 : 0
        if abs(uiView.camera.pitch - wantedPitch) > 0.1 {
            // Only update the pitch, keep centerCoordinate, altitude, heading!
            let camera = uiView.camera.copy() as! MKMapCamera
            camera.pitch = wantedPitch
            uiView.setCamera(camera, animated: true)
        }
        
        // --- Update annotations only if data changed ---
        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
        let wantedIDs = Set(accidents.map { $0.id })
        if currentIDs != wantedIDs {
            uiView.removeAnnotations(uiView.annotations)
            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
            uiView.addAnnotations(annotations)
        }
        
        print("AFTER: heading: \(uiView.camera.heading), pitch: \(uiView.camera.pitch)")
    }
    
    /// MKMapViewDelegate implementation for SwiftUI integration.
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UIKitMapView

        init(_ parent: UIKitMapView) { self.parent = parent }

        // --- Callback for user-initiated map region change ---
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let region = mapView.region
            parent.onRegionChanged?(region)
        }

//        // --- Provide colored markers without clustering ---
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            if let accidentAnnotation = annotation as? AccidentAnnotation {
//                let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Accident", for: annotation) as? MKMarkerAnnotationView
////                view?.markerTintColor = colorForAccident(accidentAnnotation.accident.color)
//                view?.markerTintColor = UIColor(accidentAnnotation.accident.color)
//                view?.glyphText = "" // Or any symbol, or accidentAnnotation.accident.symbolString
//                view?.clusteringIdentifier = nil // Clustering disabled!
//                view?.canShowCallout = false
//                return view
//            }
//            return nil
//        }
        
        // Use custom annotation view: Small colored circle
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let accidentAnnotation = annotation as? AccidentAnnotation else { return nil }
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "SmallCircle", for: annotation) as! SmallCircleAnnotationView
            // Set color (dynamically based on accident properties)
            let color = UIColor(accidentAnnotation.accident.color)
            view.setCircleColor(color)
            return view
        }

        // --- Handle marker selection (if needed) ---
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let accidentAnnotation = view.annotation as? AccidentAnnotation {
                parent.onSelectAccident?(accidentAnnotation.accident)
            }
        }

//        // --- Optional: Show circles as overlays instead of markers ---
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let circle = overlay as? MKCircle {
//                let renderer = MKCircleRenderer(circle: circle)
//                renderer.fillColor = UIColor.systemRed.withAlphaComponent(0.3)
//                renderer.strokeColor = UIColor.systemRed
//                renderer.lineWidth = 2
//                return renderer
//            }
//            return MKOverlayRenderer(overlay: overlay)
//        }
        
        // To use overlays, see comments below in updateUIView.
    }
    
    
}

// MARK: - Custom AnnotationView: Small colored circle
class SmallCircleAnnotationView: MKAnnotationView {
    static let size: CGFloat = 18 // diameter in points
    private let circleLayer = CALayer()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        // Setup the circle
        let d = Self.size
        frame = CGRect(x: 0, y: 0, width: d, height: d)
        backgroundColor = .clear
        circleLayer.cornerRadius = d / 2
        circleLayer.masksToBounds = true
        circleLayer.borderWidth = 2
        circleLayer.borderColor = UIColor.white.cgColor // Optional: white ring
        circleLayer.frame = bounds
        circleLayer.backgroundColor = UIColor.systemRed.cgColor // Default, will be overridden
        layer.addSublayer(circleLayer)
        centerOffset = CGPoint(x: 0, y: 0)
        isUserInteractionEnabled = true
    }

    /// Update the circle color dynamically.
    func setCircleColor(_ color: UIColor) {
        circleLayer.backgroundColor = color.cgColor
    }

    /// Optionally, make circle larger when selected
    override var isSelected: Bool {
        didSet {
            let scale: CGFloat = isSelected ? 1.3 : 1.0
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            circleLayer.borderColor = isSelected ? UIColor.yellow.cgColor : UIColor.white.cgColor
        }
    }
}

// // --- (Optional) Show circles instead of markers ---
// // In updateUIView, remove all overlays and add circles for each accident:
// uiView.removeOverlays(uiView.overlays)
// let circles = accidents.map { MKCircle(center: $0.coordinate, radius: 50) }
// uiView.addOverlays(circles)
// // Don't forget to implement the rendererFor delegate in Coordinator (see above).
// // If you use only overlays, you can skip adding AccidentAnnotation and marker views.
//



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
//
//struct UIKitMapView: UIViewRepresentable {
//    // Nur einmal initial setzen, kein Binding nötig
//    let initialRegion: MKCoordinateRegion
//    let accidents: [AccidentStructGRDB]
//    var mapStyleIsStandard: Bool
//    var show3D: Bool
//    var onSelectAccident: ((AccidentStructGRDB) -> Void)? = nil
//    var onRegionChanged: ((MKCoordinateRegion) -> Void)? = nil
//    @Binding var coordinatorRef: Coordinator?
//
//    // << Gib Coordinator explizit nach außen frei >>
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: UIKitMapView
//        var lastRegion: MKCoordinateRegion? // Merkt sich die letzte echte Region
//        
//        init(_ parent: UIKitMapView) {
//            self.parent = parent
//        }
//
//        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//            let region = mapView.region
//            lastRegion = region // Merke die aktuelle Region
//            parent.onRegionChanged?(region)
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
//
////    func makeCoordinator() -> Coordinator { Coordinator(self) }
//    func makeCoordinator() -> Coordinator {
//        let coordinator = Coordinator(self)
//        // Setze Binding asynchron (wegen SwiftUI-Lifecycle)
//        DispatchQueue.main.async {
//            self.coordinatorRef = coordinator
//        }
//        return coordinator
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        mapView.setRegion(initialRegion, animated: false)
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
//        // MapType
//        let wantedType: MKMapType = mapStyleIsStandard ? .standard : .satellite
//        if uiView.mapType != wantedType { uiView.mapType = wantedType }
//        // Camera
//        let wantedPitch: CGFloat = show3D ? 60 : 0
//        let wantedCamera = MKMapCamera(
//            lookingAtCenter: uiView.region.center,
//            fromDistance: 800,
//            pitch: wantedPitch,
//            heading: 0
//        )
//        if abs(uiView.camera.pitch - wantedPitch) > 0.1 {
//            uiView.setCamera(wantedCamera, animated: true)
//        }
//        // Marker (wie immer)
//        let currentIDs = Set(uiView.annotations.compactMap { ($0 as? AccidentAnnotation)?.accident.id })
//        let wantedIDs = Set(accidents.map { $0.id })
//        if currentIDs != wantedIDs {
//            uiView.removeAnnotations(uiView.annotations)
//            let annotations = accidents.map { AccidentAnnotation(accident: $0) }
//            uiView.addAnnotations(annotations)
//        }
//    }
//}
//
//


