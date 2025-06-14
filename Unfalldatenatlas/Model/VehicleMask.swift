//
//  Beteiligte.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 28.05.25.
//
import Foundation

struct VehicleMask: OptionSet, Hashable {
    let rawValue: Int16

    static let pkw         = VehicleMask(rawValue: 1 << 0)
    static let fahrrad     = VehicleMask(rawValue: 1 << 1)
    static let fussgaenger = VehicleMask(rawValue: 1 << 2)
    static let krad        = VehicleMask(rawValue: 1 << 3)
    static let gueterKfz   = VehicleMask(rawValue: 1 << 4)
    static let sonstige    = VehicleMask(rawValue: 1 << 5)

    static let all: [VehicleMask] = [.pkw, .fahrrad, .fussgaenger, .krad, .gueterKfz, .sonstige]
    
    static func from(stringFlags: [String: String]) -> VehicleMask {
        var mask: VehicleMask = []

        if stringFlags["pkw"] == "1"         { mask.insert(.pkw) }
        if stringFlags["fahrrad"] == "1"     { mask.insert(.fahrrad) }
        if stringFlags["fussgaenger"] == "1" { mask.insert(.fussgaenger) }
        if stringFlags["krad"] == "1"        { mask.insert(.krad) }
        if stringFlags["gueterKfz"] == "1"   { mask.insert(.gueterKfz) }
        if stringFlags["sonstige"] == "1"    { mask.insert(.sonstige) }

        return mask
    }
    
    // MARK: - Predicate Builder

    static func predicate(required: [VehicleMask], excluded: [VehicleMask] = []) -> NSPredicate {
        let requiredMask = required.reduce(0) { $0 | $1.rawValue }
        let excludedMask = excluded.reduce(0) { $0 | $1.rawValue }

        var predicates: [NSPredicate] = []

        if requiredMask != 0 {
            predicates.append(NSPredicate(format: "(vehicleMask & %d) == %d", requiredMask, requiredMask))
        }

        if excludedMask != 0 {
            predicates.append(NSPredicate(format: "(vehicleMask & %d) == 0", excludedMask))
        }

        if predicates.isEmpty {
            return NSPredicate(value: true)
        } else if predicates.count == 1 {
            return predicates[0]
        } else {
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
    }
}
