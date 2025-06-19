//
//  MapTiling.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 17.06.25.
//
//

import Foundation
import MapKit
import CoreLocation

/// Represents a geographic bounding box (rectangle) in WGS84 coordinates.
struct BoundingBox {
    let minLon: Double
    let maxLon: Double
    let minLat: Double
    let maxLat: Double
}

/// Divides a given map region into a raster of bounding boxes.
/// - Parameters:
///   - region: The MKCoordinateRegion to be subdivided.
///   - xTiles: Number of columns (longitude direction).
///   - yTiles: Number of rows (latitude direction).
/// - Returns: An array of BoundingBoxes covering the region.
func boundingBoxesFor(region: MKCoordinateRegion, xTiles: Int, yTiles: Int) -> [BoundingBox] {
    let lonDelta = region.span.longitudeDelta
    let latDelta = region.span.latitudeDelta
    let minLon = region.center.longitude - lonDelta / 2
    let minLat = region.center.latitude - latDelta / 2

    let lonStep = lonDelta / Double(xTiles)
    let latStep = latDelta / Double(yTiles)

    var boxes: [BoundingBox] = []
    for x in 0..<xTiles {
        for y in 0..<yTiles {
            let box = BoundingBox(
                minLon: minLon + Double(x) * lonStep,
                maxLon: minLon + Double(x + 1) * lonStep,
                minLat: minLat + Double(y) * latStep,
                maxLat: minLat + Double(y + 1) * latStep
            )
            boxes.append(box)
        }
    }
    return boxes
}
