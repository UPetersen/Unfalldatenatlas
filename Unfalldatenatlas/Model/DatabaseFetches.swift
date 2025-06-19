////
////  DatabaseFetches.swift
////  Unfalldatenatlas
////
////  Created by Uwe Petersen on 17.06.25.
////
//
//import Foundation
//import GRDB
//
///// Fetches accidents from a single bounding box, applying all filters.
///// - Parameters:
/////   - box: The geographic bounding box for this query.
/////   - filters: Array of SQLExpressions for additional filtering.
/////   - limit: Maximum number of accidents to return.
/////   - db: GRDB Database instance.
///// - Returns: Array of AccidentStructGRDBs.
//func fetchAccidentsInBoundingBox(
//    _ box: BoundingBox,
//    filters: [SQLExpression],
//    limit: Int,
//    db: Database
//) throws -> [AccidentStructGRDB] {
//    // Combine all filter expressions with AND
//    let combinedFilter = filters.reduce(true.sqlExpression) { $0 && $1 }
//
////    print("BoundingBox: minLon100: \(box.minLon * 10_000_000), maxLon100: \(box.maxLon * 10_000_000), minLat100: \(box.minLat * 10_000_000), maxLat100: \(box.maxLat * 10_000_000)")
//    
//    return try AccidentStructGRDB
//        .select(
//            Column("id"),
//            Column("vehicleMask"),
//            Column("jahr"),
//            Column("latitude100"),
//            Column("longitude100"),
//            Column("lichtVerhaeltnisse"),
//            Column("monat"),
//            Column("strassenZustand"),
//            Column("stunde"),
//            Column("unfallArt"),
//            Column("unfallKategorie"),
//            Column("unfallTyp1"),
//            Column("wochentag")
//        )
////        .filter(Column("longitude100") >= box.minLon && Column("longitude100") < box.maxLon)
////        .filter(Column("latitude100") >= box.minLat && Column("latitude100") < box.maxLat)
//        .filter(Column("longitude100") >= box.minLon * 10_000_000 && Column("longitude100") < box.maxLon * 10_000_000)
//        .filter(Column("latitude100")  >= box.minLat  * 10_000_000 && Column("latitude100") < box.maxLat  * 10_000_000)
//        .filter(combinedFilter)
//        .order(sql: "RANDOM()")
////        .order(Column("id").desc)
//        .limit(limit)
//        .fetchAll(db)
//}
//
//
//
