//
//  StatisticsView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 11.10.23.
//

import SwiftUI
import Charts

struct Unfalltyp1ChartData: Identifiable {
    var color: String
    var type: String
    var value: Double
    var id = UUID()
}

struct StatisticsView: View {
    //    var accidents: [Accident]
    
    var unfalltyp1ChartData: [Unfalltyp1ChartData] = [
        .init(color: "Fahrunfall", type: "Cube", value: 2),
        .init(color: "Abbiegen", type: "Sphere", value: 0),
        .init(color: "Einbiegen-/Kreuzen", type: "Pyramid", value: 1),
        .init(color: "Überschreiten", type: "Cube", value: 1),
        .init(color: "ruhender Verkehr", type: "Sphere", value: 1),
        .init(color: "im Längsverkehr", type: "Sphere", value: 1),
        .init(color: "Sonstige", type: "Sphere", value: 1),
    ]
    
    var body: some View {
        
        VStack(alignment: .trailing) {
            
            Text("Unfalltyp")
            //        if accidents.count >= 3 {
            Chart {
                BarMark(x: .value("WERT", 5))
                    .foregroundStyle(by: .value("Shape Color", "Fahrunfall"))
                BarMark(x: .value("WERT", 35))
                    .foregroundStyle(by: .value("Shape Color", "Abbiegen"))
                    .annotation(position: .overlay, alignment: .center) { // Plot values into the bars
                        Text("\(35, format: .number.precision(.fractionLength(0)))")
                            .foregroundColor(.white)
                            .bold()
                    }
                BarMark(x: .value("WERT", 10))
                    .foregroundStyle(by: .value("Shape ", "Einbiegen-/Kreuzen"))
                BarMark(x: .value("WERT", 30))
                    .foregroundStyle(by: .value("Shape Color", "Überschreiten"))
                BarMark(x: .value("WERT", 15))
                    .foregroundStyle(by: .value("Shape Color", "ruhender Verkehr"))
                BarMark(x: .value("WERT", 5))
                    .foregroundStyle(by: .value("Shape Color", "im Längsverkehr"))
                BarMark(x: .value("WERT", 5))
                    .foregroundStyle(by: .value("Shape Color", "Sonstige"))
                
                
                //                BarMark(x: .value("TYP", accidents[0].jahr.description) , y: .value("WERT", 1))
                //                    .foregroundStyle(by: .value("Shape Color", "2022"))
                //                BarMark(x: .value("TYP", UnfallTyp1.fahrUnfall.sectionText) , y: .value("WERT", 5))
                //                    .foregroundStyle(by: .value("Shape Color", "Purple"))
                //                BarMark(x: .value("TYP", UnfallTyp1.abbiegeUnfall.sectionText) , y: .value("WERT", 55))
                //                BarMark(x: .value("TYP", UnfallTyp1.einbiegenKreuzenUnfall.sectionText) , y: .value("WERT", 12))
                //                BarMark(x: .value("TYP", UnfallTyp1.ueberschreitenUnfall.sectionText) , y: .value("WERT", 33))
                //                BarMark(x: .value("TYP", UnfallTyp1.unfallDurchRuhendenVerkehr.sectionText) , y: .value("WERT", 7))
                //                BarMark(x: .value("TYP", UnfallTyp1.unfallImLaengsverkehr.sectionText) , y: .value("WERT", 0))
                //                BarMark(x: .value("TYP", UnfallTyp1.sonstigerUnfall.sectionText) , y: .value("WERT", 3))
            }
            .padding()
            .bold()
            .chartForegroundStyleScale([
                "Fahrunfall": .green,
                "Abbiegen": .yellow,
                "Einbiegen-/Kreuzen": .red,
                "Überschreiten": .white,
                "ruhender Verkehr": .blue,
                "im Längsverkehr": .orange,
                "Sonstige": .black,
            ])
            .frame(maxWidth: .infinity)
            //            .frame(width: 360, height: 150)
            .background(Color(.tertiarySystemBackground))
            //            .background(Color(.lightGray))
            
            //        }
            
            
        }
        
        
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

#Preview {
    StatisticsView()
}
