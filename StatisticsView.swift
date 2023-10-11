//
//  StatisticsView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 11.10.23.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    var accidents: [Accident]
    
    
    var body: some View {
        if accidents.count >= 3 {
            Chart {
                BarMark(x: .value("TYP", accidents[0].jahr.description) , y: .value("WERT", 1))
                    .foregroundStyle(by: .value("Shape Color", "2022"))
                BarMark(x: .value("TYP", UnfallTyp1.fahrUnfall.sectionText) , y: .value("WERT", 5))
                    .foregroundStyle(by: .value("Shape Color", "Purple"))
                BarMark(x: .value("TYP", UnfallTyp1.abbiegeUnfall.sectionText) , y: .value("WERT", 55))
                BarMark(x: .value("TYP", UnfallTyp1.einbiegenKreuzenUnfall.sectionText) , y: .value("WERT", 12))
                BarMark(x: .value("TYP", UnfallTyp1.ueberschreitenUnfall.sectionText) , y: .value("WERT", 33))
                BarMark(x: .value("TYP", UnfallTyp1.unfallDurchRuhendenVerkehr.sectionText) , y: .value("WERT", 7))
                BarMark(x: .value("TYP", UnfallTyp1.unfallImLaengsverkehr.sectionText) , y: .value("WERT", 0))
                BarMark(x: .value("TYP", UnfallTyp1.sonstigerUnfall.sectionText) , y: .value("WERT", 3))
            }
            .chartForegroundStyleScale([
                "2022": .green, "Purple": .purple, "Pink": .pink, "Yellow": .yellow
            ])
        }
       
//        Chart {
//                    ForEach(stackedBarNutrientData) { shape in
//                        BarMark(
//                            x: .value("Total Count", shape.value)
//                            //                        y: .value("Shape Type", shape.type)
//                        )
//                        .foregroundStyle(by: .value("Shape Color", shape.category.name))
//                        .annotation(position: .overlay, alignment: .center) { // Plot values into the bars
//                            if shape.value >= 5 {
//                                Text("\(shape.value, format: .number.precision(.fractionLength(0)))")
//                                    .foregroundColor(.white)
//                                    .bold()
//                            }
//                        }
//                    }
//                }
    }
    
    
    
    /// Returns the color to use for Unfall Type 1, as of https://de.wikipedia.org/wiki/Unfalltyp
    func colorForAccidentType1(accidentType1: UnfallTyp1) -> Color {
        switch accidentType1.rawValue {
        case 1: return Color.green   // 1 = Fahrunfall
        case 2: return Color.yellow  // 2 = Abbiegeunfall
        case 3: return Color.red     // 3 = Einbiegen / Kreuzen-Unfall
        case 4: return Color.white   // 4 = Überschreiten-Unfall
        case 5: return Color.blue    // 5 = Unfall durch ruhenden Verkehr
        case 6: return Color.orange  // 6 = Unfall im Längsverkehr
        case 7: return Color.black   // 7 = sonstiger Unfall
        default:
            fatalError("Wrong Unfalltyp 1: . Must be one out of 1 to 7.")
        }
    }

}

//#Preview {
//    StatisticsView()
//}
