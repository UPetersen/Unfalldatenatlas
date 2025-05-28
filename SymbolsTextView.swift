//
//  SymbolsTextView.swift
//  Unfalldatenatlas
//
//  Created by Uwe Petersen on 30.09.23.
//

import SwiftUI

struct SymbolsTextView: View {
    
    var accident: AccidentStruct
//    var showSymbols: Bool
    
    var body: some View {
        // MARK: Todo: text is mainly gray since one of the latest changes. Should be black or white.
//        Text("\(accident.jahr - 2000)\("-")\(["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"][Int(accident.monat) - 1])\("-")\(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"][Int(accident.wochentag) - 1])\(":")\(accident.stunde)\("h ")\(symbolsForAccident(accident: accident))")
        Text("\(accident.stunde)\("h,")\(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"][Int(accident.wochentag) - 1])\(",")\(["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"][Int(accident.monat) - 1])\(accident.jahr - 2000)\(symbolsForAccident(accident: accident))")
            .padding(.horizontal, 5)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .padding(.top, 40)
            .frame(width: 400)
            .foregroundColor(.primary)
//            .opacity(showSymbols ? 1 : 0) // condition to display the text or not
        
    }
    
    func symbolsForAccident(accident: AccidentStruct) -> String {
        var symbol = ""
//        symbol.append(["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"][Int(accident.monat) - 1])
//        symbol.append(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"][Int(accident.wochentag) - 1])
        // Type of vehicles/persones involved. https://www.destatis.de/DE/ Themen/Gesellschaft- Umwelt/Verkehrsunfaelle/M ethoden/_inhalt.html#sprg37 1798
        
//        if accident.istPkw { symbol.append("🚗") }
//        if accident.istKrad { symbol.append("🏍️") }
//        if accident.istFahrrad { symbol.append("🚴") }
//        if accident.istFussgaenger { symbol.append("🚶‍♂️") }
//        // Güterkraffahrzeuge: Unfall mit Güterkraftfahrzeug (GKFZ): Unfall, an dem mindestens ein Lastkraftwagen mit
//        // Normalaufbau und einem Gesamtgewicht über 3,5 t, ein Lastkraftwagen mit Tankauflage bzw. Spezialaufbau,
//        // eine Sattelzugmaschine oder eine andere Zugmaschine beteiligt war (diese Kategorie ist in
//        // den Jahren 2016 und 2017 in "Unfall mit Sonstigen" enthalten)
//        if accident.istGueterKfz { symbol.append("🚚") }
//        // Unfall mit Sonstigen: Unfall, an dem mindestens ein oben nicht genanntes Verkehrsmittel beteiligt war, wie
//        // z. B. ein Bus oder eine Straßenbahn (2016 und 2017 einschließlich Unfall mit Güterkraftfahrzeug (GKFZ),
//        // ab 2018 ohne Unfall mit GKFZ)
//        if accident.istSonstige {
//            if accident.jahr >= 2018 {
//                symbol.append("🚌/🚃")
//            } else {
//                symbol.append("🚚/🚌/🚃")
//            }
//        }
        
        let mask = VehicleMask(rawValue: accident.vehicleMask)
        if mask.contains(.pkw)         { symbol.append("🚗") }
        if mask.contains(.fahrrad)     { symbol.append("🚲") }
        if mask.contains(.fussgaenger) { symbol.append("🚶") }
        if mask.contains(.krad)        { symbol.append("🏍") }
        if mask.contains(.gueterKfz)   { symbol.append("🚚") }
        if mask.contains(.sonstige)    {
            if accident.jahr >= 2018 {
                symbol.append("🚌/🚃")
            } else {
                symbol.append("🚚/🚌/🚃")
            }
        }
        
        // Light Conditions, not icon for twilight (Dämmerung) available, so just made it night, too.
        if accident.lichtVerhaeltnisse == 1 {
            symbol.append("🌛") // Dämmerung/Twilight (did not find any good icon)
        } else if accident.lichtVerhaeltnisse == 2 {
            symbol.append("🌝")  // Dunkelheit/Darkness
        }
        
        // Road conditions
        if accident.strassenZustand == 1 {
            symbol.append("🌧️")
        } else if accident.strassenZustand == 2 {
            symbol.append("❄️")
        }
        
        //Accident Category (Unfallkategorie): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        switch accident.unfallKategorie {
        case 1: symbol.append("✟")
        case 2: symbol.append("🏥")
        case 3: symbol.append("🩹")
        default: fatalError("Wrong Unfallkategorie: \(accident.unfallKategorie). Must be 1, 2 or 3.")
        }
     
        // Accident kind (Unfallart): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Zusammenstoß mit anfahrendem/ anhaltendem/ruhendem Fahrzeug
        // 2 = Zusammenstoß mit vorausfahrendem / wartendem Fahrzeug
        // 3 = Zusammenstoß mit seitlich in gleicher Richtung fahrendem Fahrzeug
        // 4 = Zusammenstoß mit entgegenkommendem Fahrzeug
        // 5 = Zusammenstoß mit einbiegendem / kreuzendem Fahrzeug
        // 6 = Zusammenstoß zwischen Fahrzeug und Fußgänger
        // 7 = Aufprall auf Fahrbahnhindernis
        // 8 = Abkommen von Fahrbahn nach rechts
        // 9 = Abkommen von Fahrbahn nach links Unfall
        // 0 = anderer Art
        symbol.append("A\(accident.unfallArt)")
        
        // Accident type (Unfalltyp1): https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Verkehrsunfaelle/Methoden/_inhalt.html#sprg371798
        // 1 = Fahrunfall (grün)
        // 2 = Abbiegeunfall (gelb)
        // 3 = Einbiegen / Kreuzen-Unfall (rot)
        // 4 = Überschreiten-Unfall (weiß)
        // 5 = Unfall durch ruhenden Verkehr (blau)
        // 6 = Unfall im Längsverkehr (orange)
        // 7 = sonstiger Unfall (schwarz)
//        symbol.append("T\(accident.unfallTyp1)")
        
        return symbol
    }
    
    
}



//#Preview {
//    SymbolsTextView()
//}
